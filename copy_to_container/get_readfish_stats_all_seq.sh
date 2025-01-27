#!/bin/bash

# Loop through each of the absolute paths passed as arguments to use the generated playback output to
#   calculate remaining read lengths and coverage of targeted regions from the adaptive sampling and control and
#   plot the coverage of the targeted regions from the adaptive sampling and control
for path in "$@"; do
    echo "Checking: $path"
    if [ -f "$path" ]; then
        echo "Result: $path is a file."
    elif [ -d "$path" ]; then
        echo "Result: $path is a directory."

        # change to a passed directory
        cd $path

        # Get absolute path of log file from BOSS-RUNS
        boss_log_file_path=$(ls $path | grep boss\.log)

        # Get absolute path of Minknow output directory
        minknow_path=$(grep -A 1 "Minknow's output path" $boss_log_file_path | tail -n1)

        # Indicate the specified duration of adaptive sampling in naming readfish stats output file
        if [[ "$path" == *"2h"* ]]; then
            echo "Argument '$path' contains the string 2h."
            duration="_2h"
        elif [[ "$path" == *"10h"* ]]; then
            echo "Argument '$path' contains the string 10h."
            duration="_10h"
        elif [[ "$path" == *"24h"* ]]; then
            echo "Argument '$path' contains the string 24h."
            duration="_24h"
        else
            echo "Argument '$path' does not contain the strings 2h, 10h or 24h."
            duration=""
        fi

        # Generate readfish stats results
        time readfish stats --toml /copy_to_container/R10_prom_4genes_boss_and_readfish.toml --fastq-directory $minknow_path/fastq_pass/ --log-level info --prom > $path/readfish_stats_4genes_9q${duration}.txt

    else
        echo "Result: $path does not exist."
    fi
    echo
done
