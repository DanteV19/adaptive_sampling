#!/bin/bash

# This script requires two arguments:
#   - absolute path to the  directory with output of readfish stats command
#   - absolute path to the human reference genome (.mmi)

### For BOSS-RUNS adaptive sampling run
# create sam file
#minimap2 -ax map-ont /project/clonevo/Share/dante/data/ncbi_dataset/data/GCF_000001405.40/human_ref.mmi /project/clonevo/Share/dante/seq_output/[readfish stats output directory]/boss_conf_stop_receiving.fastq.gz > /project/clonevo/Share/dante/seq_output/[readfish stats output directory]/alignments_boss_conf.sam
minimap2 -ax map-ont $2 $1/boss_conf_stop_receiving.fastq.gz > $1/alignments_boss_conf.sam

# create bam file
samtools view -S -b $1/alignments_boss_conf.sam > $1/alignments_boss_conf.bam
samtools sort $1/alignments_boss_conf.bam -o $1/alignments_boss_conf_sorted.bam
samtools index $1/alignments_boss_conf_sorted.bam

# get coverage depth from bed
samtools depth -a -b /copy_to_container/targets_4genes.bed $1/alignments_boss_conf_sorted.bam > $1/coverage_4genes_boss_conf.txt


### for adaptive sampling run
# create sam file
minimap2 -ax map-ont /project/clonevo/Share/dante/data/ncbi_dataset/data/GCF_000001405.40/human_ref.mmi $1/hum_test_stop_receiving.fastq.gz > $1/alignments_hum_test.sam

# create bam file
samtools view -S -b $1/alignments_hum_test.sam > $1/alignments_hum_test.bam
samtools sort $1/alignments_hum_test.bam -o $1/alignments_hum_test_sorted.bam
samtools index $1/alignments_hum_test_sorted.bam

# get coverage depth from bed
samtools depth -a -b /copy_to_container/targets_4genes.bed $1/alignments_hum_test_sorted.bam > $1/coverage_4genes_hum_test.txt


### for control run
# create sam file
minimap2 -ax map-ont /project/clonevo/Share/dante/data/ncbi_dataset/data/GCF_000001405.40/human_ref.mmi $1/control_stop_receiving.fastq.gz > $1/alignments_control.sam

# create bam file
samtools view -S -b $1/alignments_control.sam > $1/alignments_control.bam
samtools sort $1/alignments_control.bam -o $1/alignments_control_sorted.bam
samtools index $1/alignments_control_sorted.bam

# get coverage depth from bed
samtools depth -a -b /copy_to_container/targets_4genes.bed $1/alignments_control_sorted.bam > $1/coverage_4genes_control.txt


