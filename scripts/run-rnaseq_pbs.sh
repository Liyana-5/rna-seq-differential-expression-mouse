#! /bin/bash
#PBS -l nodes=1:ppn=4:centos7,cput=24:00:00,walltime=48:00:00
#PBS -N tux2dm
#PBS -m abe
#PBS -M your.email@domain.com
#PBS -q bioinf-stud
#


# NOTE:
# This script assumes that all required tools (scythe, sickle, hisat2, samtools,
# stringtie, and prepDE.py) are installed and available in the user's $PATH
# on the HPC system.

# RESOURCE FILES
adapter='/path/to/illumina_adapter.fa'
hs2index='/path/to/hisat2/index/chr2'
gtf='/path/to/annotations/chr2.gtf'
data='../data'
#
# MAKE FEW SUBDIRS UNLESS THEY EXIST
hisat_dir='./hisat2'
stringtie_dir='./stringtie'
mkdir -p ${hisat_dir}
mkdir -p ${stringtie_dir}
#
gtflist='list.gtf.txt'
rm -f ${gtflist}
#
# RUNNING a single LOOP for all the work
 for sample in s1.c2 s2.c2 s3.c2 s4.c2 s5.c2 s6.c2 s7.c2 s8.c2 s9.c2 s10.c2 s11.c2 s12.c2
 do
        # Define input and output file paths for the current sample
        fastq="${data}/${sample}.fq"
        trim1="${data}/${sample}.t1.fq"
        trim2="${data}/${sample}.t2.fq"
        bam="${hisat_dir}/${sample}.bam"
        sam="${hisat_dir}/${sample}.sam"
        sorted_bam="${hisat_dir}/${sample}.sort.bam"
        # Adapter trimming and quality trimming
        scythe -q sanger -a ${adapter} -o ${trim1} ${fastq}
        sickle se -f ${trim1} -t sanger -o ${trim2} -q 10 -l 50
        # Alignment
        hisat2 -p 4 --phred33 -x ${hs2index} -U ${trim2} -S ${sam}
        # # Convert SAM to BAM, sort alignments, and remove intermediate files
        # to reduce disk usage after successful processing
        # (can be retained for debugging if required)
        samtools view -b -o ${bam} ${sam}
        samtools sort -o ${sorted_bam} ${bam}
        rm ${sam} ${bam}
        rm ${trim1} ${trim2}
        # StringTie output
        str_smp_dir="${stringtie_dir}/${sample}"
        mkdir -p ${str_smp_dir}
        sample_tr_gtf="${str_smp_dir}/${sample}_transcripts.gtf"
        stringtie -p 4 -t -e -B -G ${gtf} -o ${sample_tr_gtf} ${sorted_bam}
        # Add sample-specific transcript GTF paths to a list file
        # required by prepDE.py to generate gene- and transcript-level
        # count matrices across all samples
        gtfline="${sample} ${sample_tr_gtf}"
        echo ${gtfline} >> ${gtflist}
 done

# Run prepDE.py (StringTie utility script; assumed to be in $PATH on the HPC system)
# to aggregate per-sample GTF files listed in ${gtflist}
# and generate gene_count_matrix.csv and transcript_count_matrix.csv
# for downstream differential expression analysis (DESeq2)
 prepDE.py -i ${gtflist}
