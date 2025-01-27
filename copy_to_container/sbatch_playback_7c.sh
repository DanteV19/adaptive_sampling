#!/bin/bash
#SBATCH --partition=gpu_a100_7c                  # Partition (queue) to submit to
#SBATCH --time=40:00:00                          # Max job run time
#SBATCH --gpus=a100:4                            # Number and type of GPUs to allocate (4 A100 GPUs)
#SBATCH --job-name=seq_7c                        # Optional: give your job a name
#SBATCH --output=my_gpu_job_playback.out   # Optional: specify an output file for logs
# Set configuration to output the sequencing in the current working directory
singularity exec --userns --bind $TMPDIR:/tmp --nv --overlay overlay.img bossruns.sif /opt/ont/minknow/bin/config_editor --conf user --filename /opt/ont/minknow/conf/user_conf --set output_dirs.logs="logs" --set output_dirs.base="$(pwd)/minknow_run"
# Set the path to the bulk file for playback
singularity exec --userns --bind $TMPDIR:/tmp --overlay overlay.img bossruns.sif sed -i "s|\(simulation=\"\)[^\"]*\(.*\)|\1$(realpath $1)\2|" /opt/ont/minknow/conf/package/sequencing/sequencing_PRO114_DNA_e8_2_400K.toml
# Start playback for 2, 10 and 24 hours, respectively
singularity exec --userns --bind $TMPDIR:/tmp --nv --overlay overlay.img bossruns.sif sed -i 's/--experiment-duration [0-9]\+/--experiment-duration 2/g' /simION/code/launch_playback_prom.sh $(realpath $1)
singularity exec --userns --bind $TMPDIR:/tmp --nv --overlay overlay.img bossruns.sif bash /copy_to_container/get_running_playback.sh 2h
cd /project/clonevo/Share/dante
singularity exec --userns --bind $TMPDIR:/tmp --nv --overlay overlay.img bossruns.sif sed -i 's/--experiment-duration [0-9]\+/--experiment-duration 10/g' /simION/code/launch_playback_prom.sh $(realpath $1)
singularity exec --userns --bind $TMPDIR:/tmp --nv --overlay overlay.img bossruns.sif bash /copy_to_container/get_running_playback.sh 10h
cd /project/clonevo/Share/dante
singularity exec --userns --bind $TMPDIR:/tmp --nv --overlay overlay.img bossruns.sif sed -i 's/--experiment-duration [0-9]\+/--experiment-duration 24/g' /simION/code/launch_playback_prom.sh $(realpath $1)
singularity exec --userns --bind $TMPDIR:/tmp --nv --overlay overlay.img bossruns.sif bash /copy_to_container/get_running_playback.sh 24h
