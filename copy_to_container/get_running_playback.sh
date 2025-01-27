#!/bin/bash

#/opt/ont/minknow/bin/config_editor --conf user --filename /opt/ont/minknow/conf/user_conf --set output_dirs.logs="logs" --set output_dirs.base="$(pwd)/minknow_run"
#/opt/ont/minknow/bin/config_editor --conf application --filename /opt/ont/minknow/conf/app_conf --set disk_space_warnings.reads.minimum_space_mb=1000

sim_arg=$(grep "simulation=" /opt/ont/minknow/conf/package/sequencing/sequencing_PRO114_DNA_e8_2_400K.toml | grep -v "#")
duration=$(grep duration /simION/code/launch_playback_prom.sh | awk -F'--experiment-duration ' '{print $2}' | awk '{print $1}')
start_play=$(date +"%F %T")

bash /simION/code/launch_playback_prom.sh ${2}

echo -e "Playback is currently being performed for ${duration} hours using the following simulation argument indicating the path to the bulk file:
${sim_arg}"

if [[ "${sim_arg}" == *"PAY00003_2A"* ]]; then
    echo "Argument '${sim_arg}' contains the string PAY00003_2A."
    bulk_name="PAY00003_2A"
elif [[ "${sim_arg}" == *"PAY00016_2C"* ]]; then
    echo "Argument '${sim_arg}' contains the string PAY00016_2C."
    bulk_name="PAY00016_2C"
else
    echo "Argument '${sim_arg}' does not contain any known bulk names."
    bulk_name="unknown_bulk"
fi

# Create output directory for adaptive sampling
monthday=$(date +%b%d | tr '[:upper:]' '[:lower:]')
new_output_dir=$(echo $monthday"_boss_and_rf_${bulk_name}_4genes_9q_${1}")

path_output_dir=$(echo "seq_output/$new_output_dir/")

mkdir -p $path_output_dir

# Change into directory where adaptive sampling output will be generated
abs_path_output_dir=$(realpath "seq_output/$new_output_dir/")

cd $abs_path_output_dir

echo -e "Generating adaptive sampling results at:\n${abs_path_output_dir}"

# Get absolute path of Minknow output directory
minknow_path=$(grep -A 1 "Minknow's output path" $(realpath ${abs_path_output_dir}/* | grep boss\.log) | tail -n1)
echo -e "Used minknow path from the playback:\n${minknow_path}/fastq_pass/"

sleep 3m

start_datetime=$(date +"%F %T") && echo "Start with adaptive sampling for ${1} at:" ${start_datetime}

# Run adaptive sampling using BOSSRUNS, Readfish and Control with a timeout of passed argument
timeout $1 boss --toml /copy_to_container/boss_prom_rf_and_boss.toml --toml_readfish /copy_to_container/R10_prom_4genes_boss_and_readfish.toml

# Check the exit status to see if the command timed out
case $? in
    0) echo -e "Playback started at:\t${start_play}\nCommand completed successfully within the timeout at:" $(date +"%F %T") "while it started at: ${start_datetime}"
    echo -e "Used minknow path from the playback:\n${minknow_path}/fastq_pass/"
    echo -e "Number of fastq files in the minknow path:" $(ls ${minknow_path}/fastq_pass | wc -l)
    ;;
    124) echo -e "Playback started at:\t${start_play}\nAdaptive sampling started at:\t${start_datetime}\nCommand timed out after $1 at:\t" $(date +"%F %T")
    echo -e "Used minknow path from the playback:\n${minknow_path}/fastq_pass/"
    echo -e "Number of fastq files in the minknow path:" $(ls ${minknow_path}/fastq_pass | wc -l)
    ;;
    *) echo "Command failed with exit status $? at:" $(date +"%F %T");;
esac
