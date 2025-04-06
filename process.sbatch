#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --mem=32000
#SBATCH --time=120:00:00
#SBATCH --output=/gpfs/home/sawang/HTGTS/code/%x_%j.out

#### set ----
## mind to change set before running the program!
PREFIX=07id07SS_S57_L001  # your sample prefix
WORK_PATH=~/HTGTS/data  # your main working path 
RAW_DATA=${WORK_PATH}/raw_data/20241111/raw  # the path to the folder where you can find your raw fastq files
INPUT_R1=${RAW_DATA}/${PREFIX}_R1_001.fastq.gz  # the path to the first fastq file
INPUT_R2=${RAW_DATA}/${PREFIX}_R2_001.fastq.gz  # the path to the second fastq file
RAW_FASTQC_OUTPUT=${WORK_PATH}/raw_data/20241111/qc/raw_qc  # the path to the folder where you can find initial quality control results
CLEAN_FASTQC_OUTPUT=${WORK_PATH}/raw_data/20241111/qc/clean_qc  # the path to the folfer where you can find quality control results after adaptor trimming
MERGE_FASTQC_OUTPUT=${WORK_PATH}/raw_data/20241111/qc/merge_qc  # the path to the folder where you can find quality control results after merging
CLEAN_OUTPUT=${WORK_PATH}/raw_data/20241111/processed  # the path to the folder where you can find processed fastq files
MERGE_OUTPUT=${WORK_PATH}/output_data/merge_data  # the path to the folder where you can find merged fastq files

## fastqc with raw data
fastqc -t 2 $INPUT_R1 $INPUT_R2 -o $RAW_FASTQC_OUTPUT

## triming and cleaning
trim_galore -j 4 \
--stringency 3 \
--paired $INPUT_R1 $INPUT_R2 \
--gzip -o $CLEAN_OUTPUT

## fastqc with clean data
fastqc -t 2 ${CLEAN_OUTPUT}/${PREFIX}_R1_001_val_1.fq.gz ${CLEAN_OUTPUT}/${PREFIX}_R2_001_val_2.fq.gz -o $CLEAN_FASTQC_OUTPUT

## merge PE data by flash
flash --min-overlap 10 --max-mismatch-density 0.25 -t 6 \
${CLEAN_OUTPUT}/${PREFIX}_R1_001_val_1.fq.gz \
${CLEAN_OUTPUT}/${PREFIX}_R2_001_val_2.fq.gz \
--output-prefix=${PREFIX}_merge_flash --output-directory=$MERGE_OUTPUT

## length selection by seqkit
seqkit seq -m 60 ${MERGE_OUTPUT}/${PREFIX}_merge_flash.extendedFrags.fastq -o ${MERGE_OUTPUT}/${PREFIX}_merge_flash.fastq

## fastqc with merged data
fastqc ${MERGE_OUTPUT}/${PREFIX}_merge_flash.fastq -o $MERGE_FASTQC_OUTPUT
