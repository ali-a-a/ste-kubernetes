import pandas as pd
import matplotlib.pyplot as plt

dfOT = pd.read_csv('throughput_results_ste.csv')
dfNT = pd.read_csv('throughput_results_native.csv')

dfNT['Time'] = range(1, 1+len(dfNT))
dfOT['Time'] = range(1, 1+len(dfOT))


# Compute relative time in seconds from the first timestamp
dfNT["Seconds"] = (dfNT["Time"] - dfNT["Time"].iloc[0])
dfOT["Seconds"] = (dfOT["Time"] - dfOT["Time"].iloc[0])


# Plot the time series with seconds on the x-axis
plt.figure(figsize=(12, 6))
plt.plot(dfNT["Seconds"], dfNT["201"], marker="", linestyle="-.", color="r", label="Native", linewidth=2.5)
plt.plot(dfOT["Seconds"], dfOT["201"], marker="", linestyle="--", color="b", label="STE", linewidth=2.5)

# Formatting the plot
plt.xlabel("Time (s)", fontsize=15)
plt.ylabel("API Server response rate (RES/s)", fontsize=15)
plt.title("Throughput - 20 Qps - 10 Replicas - Steady", fontsize=14, fontweight='bold')
plt.legend(fontsize=13, prop={'weight': 'bold'})
plt.grid()

# Make x and y axis numbers bigger
plt.tick_params(axis='both', which='major', labelsize=14)
plt.tick_params(axis='both', which='minor', labelsize=12)

# Show the updated plot
plt.show()
