!/bin/bash
ls *.gz | cut -d "_" -f 1-3 | uniq > id_list.txt
mkdir consensus_files

#BWA Mapping
bwa index reference.fasta

for line in $(cat id_list.txt);do
	bwa mem reference.fasta "$line"_R1_001.fastq.gz "$line"_R2_001.fastq.gz > "$line".sam
	samtools view -Sb "$line".sam > "$line".bam
	samtools sort "$line".bam -o "$line"_bwa_sorted.bam
	#samtools index "$line"_bwa_sorted.bam
	samtools consensus -m simple -c 0.5 -q -f fasta "$line"_bwa_sorted.bam -o "$line"_bwa_consensus.fasta
	rm "$line".bam
done

cat *.fasta > consensus_files/samples_bwa.fasta
mafft --maxiterate 8000 consensus_files/samples_bwa.fasta > consensus_files/aligned.samples_bwa.fasta
mv 22010101*.fasta consensus_files/
awk 'NR == FNR { o[n++] = $0; next } /^>/ && i < n { $0 = ">" o[i++] } 1' id_list.txt consensus_files/aligned.samples_bwa.fasta > consensus_files/aligned.samples_BWA.fasta
rm *.sam

#Bowtie2 Mapping
bowtie2-build reference.fasta ref

for line in $(cat id_list.txt);do
	bowtie2 -x ref -1 "$line"_R1_001.fastq.gz -2 "$line"_R2_001.fastq.gz -S "$line".sam
	samtools view -Sb "$line".sam > "$line".bam
	samtools sort "$line".bam -o "$line"_bowtie2_sorted.bam
	#samtools index "$line"_bowtie2_sorted.bam
	samtools consensus -m simple -c 0.5 -q -f fasta "$line"_bowtie2_sorted.bam -o "$line"_bowtie2_consensus.fasta
	rm "$line".bam
done

cat *.fasta > consensus_files/samples_bowtie2.fasta
mafft --maxiterate 8000 consensus_files/samples_bowtie2.fasta > consensus_files/aligned.samples_bowtie2.fasta
mv 22010101*.fasta consensus_files/
awk 'NR == FNR { o[n++] = $0; next } /^>/ && i < n { $0 = ">" o[i++] } 1' id_list.txt consensus_files/aligned.samples_bowtie2.fasta > consensus_files/aligned.samples_BOWTIE2.fasta
rm *.sam

mkdir mapping_files/ && mv *.bam mapping_files/
