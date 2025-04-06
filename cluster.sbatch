#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --mem=32000
#SBATCH --time=72:00:00
#SBATCH --output=/gpfs/home/sawang/HTGTS/code/%x_%j.out

#### set ----
## mind to change set before running the program!
PREFIX=07id07SS_S57_L001  # your sample prefix
WORK_PATH=~/HTGTS/data/output_data  # your main working path
MERGE_INPUT=${WORK_PATH}/merge_data  # the path to the folder where you can find merged fastq files
CLUSTER_OUTPUT=${WORK_PATH}/cluster_data/20241111  # the path to the folder where you can find final results

cd-hit-est -i ${MERGE_INPUT}/${PREFIX}_merge_flash.fastq \
-o ${CLUSTER_OUTPUT}/${PREFIX}_merge \
-c 0.95 -n 10 -M 3000 -T 0

total_num=`wc -l ${CLUSTER_OUTPUT}/${PREFIX}_merge.clstr | awk '{print $1}'`
awk '/Cluster/{print NR}' ${CLUSTER_OUTPUT}/${PREFIX}_merge.clstr > temp.line
clstr_num=`wc -l temp.line | awk '{print $1}'`
awk '{if(NR%4 == 2){print}}' ${CLUSTER_OUTPUT}/${PREFIX}_merge > temp.sequence
for i in `seq 1 $clstr_num`
do temp=(`awk 'NR=='$i'' temp.line`)
if [ $i -eq 1 ]
then let line1=$temp
continue
fi
let line2=$temp
let count=line2-line1-1
echo $count
let line1=line2
if [ $i -eq $clstr_num ]
then let count=total_num-line1
echo $count
fi
done > temp.count
paste temp.count temp.sequence | sort -g -r -k 1 > ${CLUSTER_OUTPUT}/${PREFIX}_merge.count
done
