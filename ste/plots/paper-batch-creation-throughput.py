import matplotlib.pyplot as plt
import numpy as np

types = ("1", "5", "20", "50")
tiles = {
    'Native': (42.9, 141.1, 173.0, 164.8),
    'STE': (43.5, 159.3, 277.4, 300.9),
}

x = np.arange(len(types))
width = 0.28  # Slightly wider bars for better visibility
colors = ['#CC5151', '#A8D2FC']
hatches = [ "x" , "/"]


fig, ax = plt.subplots(figsize=(8, 5), layout='constrained')

for i, (label, values) in enumerate(tiles.items()):
    offset = width * i - width/2
    rects = ax.bar(x + offset, values, width, label=label, color=colors[i],
                   edgecolor='black', linewidth=1.2, alpha=0.85, hatch=hatches[i])
    # Add value labels on top of each bar
    for bar in rects:
        height = bar.get_height()
        ax.annotate(f'{height:.1f}',
                    xy=(bar.get_x() + bar.get_width() / 2, height),
                    xytext=(0, 3),  # 3 points vertical offset
                    textcoords="offset points",
                    ha='center', va='bottom', fontsize=10, fontweight='bold')

ax.set_ylabel('API Server response rate (RES/s)', fontsize=15)
ax.set_xlabel('Qps', fontsize=15)
ax.set_title('API Server Throughput - Batch Creation', fontsize=14, fontweight='bold')
ax.set_xticks(x, types, fontsize=12)
ax.set_ylim(0, 350)
ax.legend(loc='upper left', fontsize=13, frameon=True, edgecolor='black', prop={'weight': 'bold'})

plt.tick_params(axis='both', which='major', labelsize=14)
plt.tick_params(axis='both', which='minor', labelsize=12)

plt.show()
