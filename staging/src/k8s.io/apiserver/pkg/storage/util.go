/*
Copyright 2015 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package storage

import (
	"context"
	"fmt"
	"hash/fnv"
	"strconv"
	"strings"
	"sync/atomic"

	"k8s.io/apimachinery/pkg/api/meta"
	"k8s.io/apimachinery/pkg/api/validation/path"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/fields"
	"k8s.io/apimachinery/pkg/labels"
	"k8s.io/apimachinery/pkg/runtime"
)

// TODO: Make the port configurable
const (
	// ShardProtocol is a protocol to connect to the dynamically added shard.
	ShardProtocol = "https://"
	// ShardPort is a port to connect to the dynamically added shard.
	ShardPort = ":2279"

	alphabet = "0123456789abcdefghijklmnopqrstuvwxyz"
	base     = uint64(len(alphabet))
	length   = 7
	space    = 78364164096 // 36^7
)

type SimpleUpdateFunc func(runtime.Object) (runtime.Object, error)

// SimpleUpdateFunc converts SimpleUpdateFunc into UpdateFunc
func SimpleUpdate(fn SimpleUpdateFunc) UpdateFunc {
	return func(input runtime.Object, _ ResponseMeta) (runtime.Object, *uint64, error) {
		out, err := fn(input)
		return out, nil, err
	}
}

func NamespaceKeyFunc(prefix string, obj runtime.Object) (string, error) {
	meta, err := meta.Accessor(obj)
	if err != nil {
		return "", err
	}
	name := meta.GetName()
	if msgs := path.IsValidPathSegmentName(name); len(msgs) != 0 {
		return "", fmt.Errorf("invalid name: %v", msgs)
	}
	return prefix + "/" + meta.GetNamespace() + "/" + name, nil
}

func NoNamespaceKeyFunc(prefix string, obj runtime.Object) (string, error) {
	meta, err := meta.Accessor(obj)
	if err != nil {
		return "", err
	}
	name := meta.GetName()
	if msgs := path.IsValidPathSegmentName(name); len(msgs) != 0 {
		return "", fmt.Errorf("invalid name: %v", msgs)
	}
	return prefix + "/" + name, nil
}

// HighWaterMark is a thread-safe object for tracking the maximum value seen
// for some quantity.
type HighWaterMark int64

// Update returns true if and only if 'current' is the highest value ever seen.
func (hwm *HighWaterMark) Update(current int64) bool {
	for {
		old := atomic.LoadInt64((*int64)(hwm))
		if current <= old {
			return false
		}
		if atomic.CompareAndSwapInt64((*int64)(hwm), old, current) {
			return true
		}
	}
}

// GetCurrentResourceVersionFromStorage gets the current resource version from the underlying storage engine.
// This method issues an empty list request and reads only the ResourceVersion from the object metadata
func GetCurrentResourceVersionFromStorage(ctx context.Context, storage Interface, newListFunc func() runtime.Object, resourcePrefix, objectType string) (uint64, error) {
	if storage == nil {
		return 0, fmt.Errorf("storage wasn't provided for %s", objectType)
	}
	if newListFunc == nil {
		return 0, fmt.Errorf("newListFunction wasn't provided for %s", objectType)
	}
	emptyList := newListFunc()
	pred := SelectionPredicate{
		Label: labels.Everything(),
		Field: fields.Everything(),
		Limit: 1, // just in case we actually hit something
	}

	err := storage.GetList(ctx, resourcePrefix, ListOptions{Predicate: pred}, emptyList)
	if err != nil {
		return 0, err
	}
	emptyListAccessor, err := meta.ListAccessor(emptyList)
	if err != nil {
		return 0, err
	}
	if emptyListAccessor == nil {
		return 0, fmt.Errorf("unable to extract a list accessor from %T", emptyList)
	}

	currentResourceVersion, err := strconv.Atoi(emptyListAccessor.GetResourceVersion())
	if err != nil {
		return 0, err
	}

	if currentResourceVersion == 0 {
		return 0, fmt.Errorf("the current resource version must be greater than 0")
	}
	return uint64(currentResourceVersion), nil
}

// AnnotateInitialEventsEndBookmark adds a special annotation to the given object
// which indicates that the initial events have been sent.
//
// Note that this function assumes that the obj's annotation
// field is a reference type (i.e. a map).
func AnnotateInitialEventsEndBookmark(obj runtime.Object) error {
	objMeta, err := meta.Accessor(obj)
	if err != nil {
		return err
	}
	objAnnotations := objMeta.GetAnnotations()
	if objAnnotations == nil {
		objAnnotations = map[string]string{}
	}
	objAnnotations[metav1.InitialEventsAnnotationKey] = "true"
	objMeta.SetAnnotations(objAnnotations)
	return nil
}

// HasInitialEventsEndBookmarkAnnotation checks the presence of the
// special annotation which marks that the initial events have been sent.
func HasInitialEventsEndBookmarkAnnotation(obj runtime.Object) (bool, error) {
	objMeta, err := meta.Accessor(obj)
	if err != nil {
		return false, err
	}
	objAnnotations := objMeta.GetAnnotations()
	return objAnnotations[metav1.InitialEventsAnnotationKey] == "true", nil
}

// ShouldKeyMoveToTheFastStorage checks whether the key is a pod key.
func ShouldKeyMoveToTheFastStorage(key string) bool {
	if strings.Contains(key, "/pods") {
		return true
	}

	return false
}

// GetNodeKeyByPodKey extracts the node key based on the pod key.
func GetNodeKeyByPodKey(key string) (string, bool) {
	parts := strings.Split(key, "-")

	if len(parts) >= 2 {
		return parts[len(parts)-1], true
	}

	return "", false
}

// HashIPPort returns a 7-char code for an "ip:port" string.
func HashIPPort(s string) string {
	// FNV-1a 64-bit hash
	h := fnv.New64a()
	_, _ = h.Write([]byte(s))
	n := h.Sum64() % space

	// Convert to fixed-length (left-pad with '0' if needed)
	var buf [length]byte
	for i := length - 1; i >= 0; i-- {
		buf[i] = alphabet[n%base]
		n /= base
	}

	return string(buf[:])
}
