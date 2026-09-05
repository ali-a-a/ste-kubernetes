import matplotlib.pyplot as plt
import numpy as np

types = ("Native", "STE")
percentiles = ['50th', '90th', '99th']
latencies = {
    'Native': [0.911, 1.369, 2.033],
    'STE': [0.527, 0.944, 1.000],
}

x = np.arange(len(percentiles))
width = 0.28
colors = ['#CC5151', '#A8D2FC']
hatches = [  "x" , "/"]

fig, ax = plt.subplots(figsize=(8, 5), layout='constrained')

for i, (type_name, values) in enumerate(latencies.items()):
    offset = width * i - width / 2
    rects = ax.bar(x + offset, values, width, label=type_name, color=colors[i],
                   edgecolor='black', linewidth=1.2, alpha=0.85, hatch=hatches[i])
    for bar in rects:
        height = bar.get_height()
        ax.annotate(f'{height:.2f}',
                    xy=(bar.get_x() + bar.get_width() / 2, height),
                    xytext=(0, 3),
                    textcoords="offset points",
                    ha='center', va='bottom', fontsize=10, fontweight='bold')

ax.set_ylabel('Pod startup latency (s)', fontsize=12)
ax.set_title('100 deployments - 10 Replicas - 2 Qps - Batch Creation', fontsize=14, fontweight='bold')
ax.set_xticks(x, percentiles, fontsize=12)
ax.set_xlabel('Percentile', fontsize=12)
ax.set_ylim(0, 2.6)
ax.legend(loc='upper right', fontsize=11, frameon=True, edgecolor='black')

plt.show()
