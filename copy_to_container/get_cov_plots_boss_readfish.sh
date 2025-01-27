#!/bin/bash

# This script requires at least two arguments:
#   - absolute path to the human reference genome (.mmi)
#   - one or more paths of directories containing output of readfish stats command

# Loop through each of the directories of readfish stats output passed as arguments to use the generated playback output to
#   calculate remaining read lengths and coverage of targeted regions from the adaptive sampling and control and
#   plot the coverage of the targeted regions from the adaptive sampling and control
for path in "${@:2}"; do
    echo "Checking: ${path}"
    if [ -f "${path}" ]; then
        echo "Result: ${path} is a file."
    elif [ -d "${path}" ]; then
        echo "Result: ${path} is a directory."

        # Start timing the generation of results
        start_time=$(date +%s)
        start_datetime=$(date +"%F %T")

        # Save the read lengths of all individual fastq reads to a file
        # If there multiple of the same read IDs then only save the length of the first ocurring one
        awk 'NR % 4 == 1 {id=substr($1, 2); if (seen[id]++) {skip=1} else {skip=0}} NR % 4 == 2 && skip == 0 {print id, length($1)}' ${path}/live_reads.fq | sort > ${path}/live_reads_lengths.txt

        # Save the read lengths of all complete "unblocked" reads from adaptive sampling with Readfish and BOSS-RUNS, named hum_test and boss_conf respectively
        zcat ${path}/hum_test_unblock.fastq.gz | awk 'NR % 4 == 1 {id=substr($1, 2)} NR % 4 == 2 {print id, length($1)}' | sort > ${path}/hum_test_unblock_read_lengths.txt
        zcat ${path}/boss_conf_unblock.fastq.gz | awk 'NR % 4 == 1 {id=substr($1, 2)} NR % 4 == 2 {print id, length($1)}' | sort > ${path}/boss_conf_unblock_read_lengths.txt

        # Save the remaining read lengths of the "unblocked" reads calculated as
        #   the complete length of the "unblocked" read substracted by
        #   the read length of the first segment of the corresponding read from live_reads.fq
        join ${path}/hum_test_unblock_read_lengths.txt ${path}/live_reads_lengths.txt | awk '{print $1, $2 - $3}' > ${path}/length_diff_hum_test_unblock_and_live.txt
        join ${path}/boss_conf_unblock_read_lengths.txt ${path}/live_reads_lengths.txt | awk '{print $1, $2 - $3}' > ${path}/length_diff_boss_conf_unblock_and_live.txt

        # Save the total number of bases and reads of remaining read lengths
        awk '{sum += $2} END {print sum"\t"NR"\t"sum/NR}' ${path}/length_diff_hum_test_unblock_and_live.txt > ${path}/remaining_reads_bases_hum_test.txt
        awk '{sum += $2} END {print sum"\t"NR"\t"sum/NR}' ${path}/length_diff_boss_conf_unblock_and_live.txt > ${path}/remaining_reads_bases_boss_conf.txt

        # Get the mean coverage of the four targeted regions from the adaptive sampling and control for given paths
        #   of the directory with the output of the readfish stats command and human reference genome (.mmi), respectively
        time bash /copy_to_container/get_cov_4genes_boss_readfish.sh ${path} $1

        # Get absolute path of readfish stats output file of the regions Readfish, BOSS-RUNS and control
        stats_file_path=$(realpath ${path}/* | grep readfish_stats)

        # Define the search strings
        search_strings=("boss_conf" "control" "hum_test")

        # Declare an array to add total reads for each region
        declare -A region_reads

        # Loop through each search string and save the total fastq reads of corresponding region into an array
        for key in "${search_strings[@]}"; do
            # Use grep to find the first line containing the key, then use awk to extract the number
            result=$(grep -m 1 "$key" "$stats_file_path" | awk -F'|' -v key="$key" '$0 ~ key {gsub(/[, ]/, "", $3); print $3}')
            # Check if a result was found
            if [[ -n "${result}" ]]; then
                echo "Found number for '${key}': ${result}"
                region_reads[${key}]=${result}
            else
                echo "No match found for '$key'"
            fi
        done

        # Serialize keys and values as delimited strings for region and total number of reads respectively
        keys=$(printf "%s," "${!region_reads[@]}")
        values=$(printf "%s," "${region_reads[@]}")

        # Check for known bulk names in directory name
        if [[ "${path}" == *"PAY00003_2A"* ]]; then
            echo "Argument '${path}' contains the string PAY00003_2A."
            bulk_name="PAY00003_2A"
        elif [[ "${path}" == *"PAY00016_2C"* || "${path}" == *"own_bulk"* ]]; then
            echo "Argument '${path}' contains the string PAY00016_2C."
            bulk_name="PAY00016_2C"
        else
            echo "Argument '${path}' does not contain any known bulk names."
            bulk_name="unknown"
        fi

        # Derive the adaptive sampling duration from the passed directory name
        if [[ "${path}" == *"2h"* ]]; then
            echo "Argument '${path}' contains the string 2h."
            duration="2h"
        elif [[ "${path}" == *"10h"* ]]; then
            echo "Argument '${path}' contains the string 10h."
            duration="10h"
        elif [[ "${path}" == *"24h"* ]]; then
            echo "Argument '${path}' contains the string 24h."
            duration="24h"
        else
            echo "Argument '${path}' does not contain the strings: 2h, 10h or 24h."
            duration="unknown_duration"
        fi

        # Plot the mean coverage for each of the 4 targeted regions for the control and adaptive sampling regions
        time python3 /copy_to_container/get_mean_cov_plot_boss_readfish.py ${path} ${duration} ${bulk_name} ${keys} ${values}

        # Calculate elapsed time in seconds
        end_time=$(date +%s)
        elapsed_time=$((end_time - start_time))

        # Convert seconds to hours, minutes, and seconds
        hours=$((elapsed_time / 3600))
        minutes=$(((elapsed_time % 3600) / 60))
        seconds=$((elapsed_time % 60))

        echo -e "Generating bam/coverage files and plots for ${path}\nIt took $hours hours, $minutes minutes, and $seconds seconds."
        echo -e "Started at:\t" $start_datetime "\nEnded at:\t" $(date +"%F %T")
    else
        echo "Result: ${path} does not exist."
    fi
    echo
done
