import sys
import pandas as pd
import matplotlib.pyplot as plt

# This script requires five arguments:
#   - absolute path of ouput directory of readfish stats command (path)
#   - duration of adaptive sampling (duration)
#   - name of the bulk file used for playback (bulk_name)
#   - gene region name (keys)
#   - total number of reads (values)

# Define a list of strings to search for
search_strings = ["hum_test", "boss_conf", "control"]

# Read delimited strings from passed arguments with region of adaptive sampling as key for
#   the value of total number of sequenced reads for the respective region
keys = sys.argv[4].strip(',').split(',')
values = sys.argv[5].strip(',').split(',')
values = [int(num) for num in values]

# Create a dictionary with region of adaptive sampling as key for
#   the value of total number of sequenced reads for the respective region
my_dct = dict(zip(keys, values))

# Load the coverage file
coverage_data1 = pd.read_csv(sys.argv[1] + '/coverage_4genes_hum_test.txt', sep='\t', header=None, names=['chrom', 'position', 'coverage1'])
coverage_data2 = pd.read_csv(sys.argv[1] + '/coverage_4genes_boss_conf.txt', sep='\t', header=None, names=['chrom', 'position', 'coverage2'])
coverage_data3 = pd.read_csv(sys.argv[1] + '/coverage_4genes_control.txt', sep='\t', header=None, names=['chrom', 'position', 'coverage3'])

mean_per_region1 = coverage_data1.groupby(['chrom'])['coverage1'].mean().reset_index()
mean_per_region2 = coverage_data2.groupby(['chrom'])['coverage2'].mean().reset_index()
mean_per_region3 = coverage_data3.groupby(['chrom'])['coverage3'].mean().reset_index()

# Merge the first two DataFrames
merged_data = pd.merge(mean_per_region1, mean_per_region2, on='chrom', how='inner')

# Merge the result with the third DataFrame
merged_data = pd.merge(merged_data, mean_per_region3, on='chrom', how='inner')

# Define your replacement dictionary
replacement_dict = {
    'chr11': 'KMT2A',
    'chr10': 'MLLT10',
    'chr9': 'MLLT3',
    'chr19': 'MLLT1'
}

# Replace values in the 'chrom' column
merged_data['chrom'] = merged_data['chrom'].replace(replacement_dict)

# Plot the mean coverage for both files
plt.figure(figsize=(10, 6))

# Define the width of the bars
bar_width = 0.25

# Define positions for each set of bars
positions1 = range(len(merged_data))
positions2 = [x + bar_width for x in positions1]
positions3 = [x + 2 * bar_width for x in positions1]


# Define label of readfish including total number of sequenced reads
formatted_number1 = f"{my_dct['hum_test']:,}".replace(',', '.')
label_readfish = f"Readfish ({formatted_number1} reads)"

# Plot the mean coverage for the first file
bars1 = plt.bar(positions1, merged_data['coverage1'], width=bar_width, label=label_readfish, color='skyblue')
# Annotate the bars
for bar in bars1:
    plt.text(bar.get_x() + bar.get_width() / 2,
             bar.get_height() + 0.5,
             f'{bar.get_height():.1f}',
             ha='center',
             fontsize=14)


# Define label of BOSS-RUNS including total number of sequenced reads
formatted_number2 = f"{my_dct['boss_conf']:,}".replace(',', '.')
label_boss = f"BOSS-RUNS ({formatted_number2} reads)"

# Plot the mean coverage for the second file
bars2 = plt.bar(positions2, merged_data['coverage2'], width=bar_width, label=label_boss, color='orange')
# Annotate the bars
for bar in bars2:
    plt.text(bar.get_x() + bar.get_width() / 2,
             bar.get_height() + 0.5,
             f'{bar.get_height():.1f}',
             ha='center',
             fontsize=14)


# Define label of control including total number of sequenced reads
formatted_number3 = f"{my_dct['control']:,}".replace(',', '.')
label_control = f"Control ({formatted_number3} reads)"

# Plot the mean coverage for the third file
bars3 = plt.bar(positions3, merged_data['coverage3'], width=bar_width, label=label_control, color='green')
# Annotate the bars
for bar in bars3:
    plt.text(bar.get_x() + bar.get_width() / 2,
             bar.get_height() + 0.5,
             f'{bar.get_height():.1f}',
             ha='center',
             fontsize=14)

# Add labels and title
duration = sys.argv[2].replace("h", "")
plt.xlabel('Chromosome', fontsize=16)
plt.ylabel('Mean Coverage', fontsize=16)
plt.title(f'Mean Coverage Comparison per Region of playback with\n{sys.argv[3]} for {duration} hours',
          fontsize=18)

# Set x-ticks to the middle of the grouped bars
plt.xticks([p + bar_width for p in positions1], merged_data['chrom'], rotation=45, ha="right",
           fontsize=14)
plt.yticks(fontsize=14)

# Add a legend
plt.legend(fontsize=14)

# Display the plot
plt.tight_layout()

# Filter for numeric columns
numeric_df = merged_data.select_dtypes(include=["number"])

# Using the max from the numeric column resize the bars to leave space for the legend
plt.ylim(top = float(numeric_df.max().max()) * 1.20)
plt.show()

# Save barplot as png file
fig_name = f"{sys.argv[1]}/coverage_4genes_{sys.argv[3]}_{sys.argv[2]}.png"
plt.savefig(fig_name)
print(fig_name)
print("Saved as PNG file!")