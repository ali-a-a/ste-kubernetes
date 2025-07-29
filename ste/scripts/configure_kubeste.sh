#!/bin/bash

# Kubeste alias
ALIAS_COMMAND='alias kubeste="kubectl --kubeconfig=/etc/ste-kubernetes/.kube/admin.kubeconfig"'

# Detect the shell
SHELL_NAME=$(basename "$SHELL")
case "$SHELL_NAME" in
  bash)
    SHELL_RC="$HOME/.bashrc"
    ;;
  zsh)
    SHELL_RC="$HOME/.zshrc"
    ;;
  fish)
    SHELL_RC="$HOME/.config/fish/config.fish"
    ALIAS_COMMAND='alias kubeste "kubectl --kubeconfig=/etc/ste-kubernetes/.kube/admin.kubeconfig"'
    ;;
  *)
    echo "Unsupported shell: $SHELL_NAME"
    exit 1
    ;;
esac

# Add alias if not already present
if ! grep -Fxq "$ALIAS_COMMAND" "$SHELL_RC"; then
  echo "$ALIAS_COMMAND" >> "$SHELL_RC"
  echo "Alias added to $SHELL_RC"
else
  echo "Alias already exists in $SHELL_RC"
fi
