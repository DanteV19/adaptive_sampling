import argparse
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from matplotlib.ticker import FuncFormatter

# This script requires 6 arguments:
#   - path to the remaining read length file from adaptive sampling with BOSS-RUNS for 2 hours (e.g. seq_output/jan01_boss_and_rf_PAY00016_2C_4genes_9q_2h/remaining_reads_bases_boss_conf)
#   - path to the remaining read length file from adaptive sampling with BOSS-RUNS for 10 hours (e.g. seq_output/jan01_boss_and_rf_PAY00016_2C_4genes_9q_10h/remaining_reads_bases_boss_conf)
#   - path to the remaining read length file from adaptive sampling with BOSS-RUNS for 24 hours (e.g. seq_output/jan01_boss_and_rf_PAY00016_2C_4genes_9q_24h/remaining_reads_bases_boss_conf)
#   - path to the remaining read length file from adaptive sampling with Readfish for 2 hours (e.g. seq_output/jan01_boss_and_rf_PAY00016_2C_4genes_9q_2h/remaining_reads_bases_hum_test)
#   - path to the remaining read length file from adaptive sampling with Readfish for 10 hours (e.g. seq_output/jan01_boss_and_rf_PAY00016_2C_4genes_9q_10h/remaining_reads_bases_hum_test)
#   - path to the remaining read length file from adaptive sampling with Readfish for 24 hours (e.g. seq_output/jan01_boss_and_rf_PAY00016_2C_4genes_9q_24h/remaining_reads_bases_hum_test)


# Set up the argument parser
parser = argparse.ArgumentParser(description="Load numbers from multiple files into pandas DataFrames.")
parser.add_argument(
    "filepaths", 
    type=str, 
    nargs="+",  # Accept one or more file paths
    help="Paths to the data files containing numbers separated by tabs."
)

# Parse the arguments
args = parser.parse_args()

# Access the file paths from the arguments
file_paths = args.filepaths

try:
    # Combine data from all files
    combined_df = pd.concat(
        [pd.read_csv(fp, sep="\t", header=None) for fp in file_paths], 
        ignore_index=True
    )
    print("\nCombined DataFrame:")
    print(combined_df)

    # Add a new column with the calculated average
    combined_df['tot'] = combined_df[0]
    print("\nUpdated DataFrame:")
    print(combined_df)

except Exception as e:
    print(f"An error occurred while processing files: {e}")
    exit()

# Define labels for the groups
group_labels = ['2 hours', '10 hours', '24 hours']  # Labels for each group
bar_labels = ['BOSS-RUNS', 'Readfish']  # Labels for bars in each group

# Ensure the number of groups matches the data
if len(combined_df) % 2 != 0 or len(combined_df) // 2 != len(group_labels):
    print("Error: Data rows do not match the expected number of groups.")
    exit()

# Reshape the data to align with groups
tot_values = combined_df['tot'].values.reshape(-1, 2)  # Reshape into pairs for each group

# Create a grouped bar plot
x = np.arange(len(group_labels))  # The label locations
width = 0.45  # Width of the bars

fig, ax = plt.subplots(figsize=(8, 6))

# Plot the bars
rects1 = ax.bar(x - width / 2, tot_values[:, 0], width, label=bar_labels[0], color='blue')
rects2 = ax.bar(x + width / 2, tot_values[:, 1], width, label=bar_labels[1], color='green')

# Add labels, title, and legend
ax.set_xlabel('Duration per playback run', fontsize=14)
ax.set_ylabel('Total sequencing saved in nucleotides', fontsize=14)
ax.set_title('Total sequencing saved by unblocked reads using\ntwo adaptive sampling methods per playback run',
             fontsize=14)
ax.set_xticks(x)
ax.set_xticklabels(group_labels)  # Set group labels for the x-axis

ax.legend(fontsize=12)  # Adjust as needed

# Add bar value annotations
def add_labels(rects):
    for rect in rects:
        height = rect.get_height()
        ax.annotate(f'{height:.1e}',  # Format height using scientific notation
                    xy=(rect.get_x() + rect.get_width() / 2, height),
                    xytext=(0, 1),  # Offset text by 3 points above the bar
                    textcoords="offset points",
                    ha='center', va='bottom',
                    fontsize=12)

add_labels(rects1)
add_labels(rects2)

# Resize the bars to leave space for the legend
plt.ylim(top = float(max(combined_df['tot'].values)) * 1.20)

# Format y-axis with scientific notation
formatter = FuncFormatter(lambda x, _: f'{x:.1e}')
ax.yaxis.set_major_formatter(formatter)

# Set font size of numeric values for x and y to 12
plt.xticks(fontsize=12)
plt.yticks(fontsize=10)
plt.show()

plt.savefig("remaining_bases_tot.png")
print("Saved as PNG file!")
