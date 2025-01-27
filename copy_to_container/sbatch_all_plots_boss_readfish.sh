#!/bin/bash
#SBATCH --partition=gpu_a100_7c                    # Partition (queue) to submit to
#SBATCH --time=8:00:00                             # Max job run time
#SBATCH --nodes=2
#SBATCH --gpus=a100:4                              # Number and type of GPUs to allocate (4 A100 GPUs)
#SBATCH --job-name=dv_plots                        # Optional: give your job a name
#SBATCH --output=plots_boss_readfish_exp.out       # Optional: specify an output file for logs
# Generate plots with the mean of the coverage for each position of targeted gene regions for
#   given paths of human reference genome (.mmi) and directories containing output of readfish stats command
singularity exec --userns --nv --overlay overlay.img bossruns.sif bash /copy_to_container/get_cov_plots_boss_readfish.sh $(realpath ${1}) $(realpath ${@:2})
