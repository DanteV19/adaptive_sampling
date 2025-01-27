import pandas as pd
import scipy.stats as stats
import argparse

def perform_wilcoxon_test(path):
    """
    Perform a Wilcoxon signed-rank test on the second column of two input files.
    Also calculates and prints the means and medians of both groups.

    Args:
        file1 (str): Path to the first input file.
        file2 (str): Path to the second input file.
    """
    try:
        # Read the input files with space as delimiter using sep='\s+'
        data1 = pd.read_csv(path + '/length_diff_hum_test_unblock_and_live.txt', header=None, sep='\s+')
        data2 = pd.read_csv(path + '/length_diff_boss_conf_unblock_and_live.txt', header=None, sep='\s+')
        
        # Check if both files have at least 2 columns
        if data1.shape[1] < 2 or data2.shape[1] < 2:
            raise ValueError("One or both files do not have at least 2 columns.")
        
        # Extract the second column
        col1 = data1.iloc[:, 1]
        col2 = data2.iloc[:, 1]
        
        # Ensure that both columns are the same length for the paired test
        if len(col1) != len(col2):
            raise ValueError("The two columns must have the same number of values for the Wilcoxon signed-rank test.")
        
        # Calculate mean and median for each group
        mean1, mean2 = col1.mean(), col2.mean()
        median1, median2 = col1.median(), col2.median()
        
        print(f"Mean of group 1: {mean1}")
        print(f"Mean of group 2: {mean2}")
        print(f"Median of group 1: {median1}")
        print(f"Median of group 2: {median2}")
        
        # Perform the Wilcoxon signed-rank test using scipy.stats
        stat, p_value = stats.wilcoxon(col1, col2)
        
        # Print the results
        print(f"\nWilcoxon Signed-Rank Test Results:")
        print(f"Statistic: {stat}")
        print(f"P-value: {p_value}")
        
        if p_value < 0.05:
            print("Result: The difference between the groups is statistically significant (p < 0.05).")
        else:
            print("Result: The difference between the groups is not statistically significant (p ≥ 0.05).")
        
        # Infer which group is higher based on the means or medians
        if mean1 > mean2:
            print("\nGroup 1 has a higher mean.")
        elif mean2 > mean1:
            print("\nGroup 2 has a higher mean.")
        else:
            print("\nBoth groups have the same mean.")
        
        if median1 > median2:
            print("Group 1 has a higher median.")
        elif median2 > median1:
            print("Group 2 has a higher median.")
        else:
            print("Both groups have the same median.")
    
    except FileNotFoundError as e:
        print(f"Error: {e}. Please check the file path.")
    except ValueError as e:
        print(f"Error: {e}. Ensure the files are formatted correctly with at least two columns.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Perform a Wilcoxon signed-rank test on the second column of two files.")
    parser.add_argument("file1", help="Path to the first input file.")
    
    # Parse the arguments
    args = parser.parse_args()
    
    # Call the function with the provided file paths
    perform_wilcoxon_test(args.file1)
