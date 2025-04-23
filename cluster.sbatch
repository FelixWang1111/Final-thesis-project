#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --mem=32000
#SBATCH --time=72:00:00
#SBATCH --output=/gpfs/home/sawang/HTGTS/code/%x_%j.out

#### set ----
## mind to change set before running the program!
PREFIX=<prefix>  # your sample prefix
WORK_PATH=<working path>  # your main working path containing the fastq file of processed reads
CLUSTER_OUTPUT=${WORK_PATH}/cluster_data/  # the path to the folder where you can find clustering results

cd-hit-est -i ${WORK_PATH}/${PREFIX}.fastq \
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
