#!/bin/bash
#SBATCH --partition=gpu_a100_7c                             # Partition (queue) to submit to
#SBATCH --time=10:00:00                                     # Max job run time
#SBATCH --nodes=2
#SBATCH --gpus=a100:4                                       # Number and type of GPUs to allocate (4 A100 GPUs)
#SBATCH --job-name=7c_stats_dv                              # Optional: give your job a name
#SBATCH --output=readfish_stats_boss_and_rf.out             # Optional: specify an output file for logs
# Generate results from adaptive sampling on playback from the readfish stats command
#   when given the path(s) to the output directory of sbatch_playback_7c
singularity exec --userns --nv --overlay overlay.img bossruns.sif bash /copy_to_container/get_readfish_stats_all_seq.sh $(realpath $@)
