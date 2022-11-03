#!/bin/bash
#ls *.gz | cut -d "_" -f 1-3 | uniq > id_list.txt

#for line in $(cat id_list.txt); do
#    bowtie2 -p 10 -x reference_NC045512 -1 "$line"_R1_001.fastq.gz -2 "$line"_R2_001.fastq.gz -S "$line".sam
#    samtools view -Sb "$line".sam > "$line".bam
#    samtools sort "$line".bam -o "$line"_sorted.bam
#    samtools index "$line"_sorted.bam;
#done

ls *.bam | cut -d "." -f 1 > id_list.txt

for line in $(cat id_list.txt); do
    samtools consensus -f fasta "$line".bam -o "$line".cons.fa 
done
