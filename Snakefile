import pandas as pd

# Load the samples.csv file
samples = pd.read_csv("samples.csv")

# Ensure batch and sample are strings
samples["batch"] = samples["batch"].astype(str)
samples["sample"] = samples["sample"].astype(str)

# Config file
configfile: "config.yaml"

# Utility function to get FASTQ file paths
def get_fastq(sample, column):
    row = samples[samples["sample"] == sample]
    
    if row.empty:
        raise ValueError(f"ERROR: Sample '{sample}' not found in samples.csv.")
    
    return row.iloc[0][column]

# Rule all: Final outputs
rule all:
    input:
        # Raw FASTQ 파일을 DAG의 시작점으로 포함
        expand("{workdir}/{sample}.normalized.txt", workdir=config["workdir"], sample=samples["sample"]),
        expand("{workdir}/batch_correction/merged_normalized_data.txt", workdir=config["workdir"]),
        expand("{workdir}/batch_correction/batch_corrected_data.txt", workdir=config["workdir"]),
        #expand("{workdir}/multiqc/multiqc_report.html", workdir=config["workdir"]),
        expand("{workdir}/deg/heteroDE_results.txt", workdir=config["workdir"])
# Step 1: FastQC
rule fastqc:
    input:
        fastq1=lambda wildcards: get_fastq(wildcards.sample, "fastq1"),
        fastq2=lambda wildcards: get_fastq(wildcards.sample, "fastq2")
    output:
        qc_report1="{workdir}/{sample}_R1_fastqc.html",
        qc_report2="{workdir}/{sample}_R2_fastqc.html"
    shell:
        "fastqc {input.fastq1} {input.fastq2} -o {config[workdir]}"

# Step 2: Adapter trimming
rule Cutadapt:
    input:
        fastq1=lambda wildcards: get_fastq(wildcards.sample, "fastq1"),
        fastq2=lambda wildcards: get_fastq(wildcards.sample, "fastq2")
    output:
        trimmed_fastq1="{workdir}/{sample}_R1_trimmed.fastq.gz",
        trimmed_fastq2="{workdir}/{sample}_R2_trimmed.fastq.gz"
    params:
        quality=config["trim_quality"],
        min_length=config["trim_min_length"]
    shell:
        "cutadapt -q {params.quality} -m {params.min_length} -o {output.trimmed_fastq1} -p {output.trimmed_fastq2} {input.fastq1} {input.fastq2}"

# Step 3: Alignment
rule STAR_alignment:
    input:
        trimmed_fastq1="{workdir}/{sample}_R1_trimmed.fastq.gz",
        trimmed_fastq2="{workdir}/{sample}_R2_trimmed.fastq.gz"
    output:
        bam="{workdir}/{sample}_aligned.bam"
    params:
        ref_genome=config["reference_genome"]
    shell:
        "{config[alignment_tool]} --readFilesIn {input.trimmed_fastq1} {input.trimmed_fastq2} --genomeDir {params.ref_genome} "
        "--outFileNamePrefix {wildcards.workdir}/{wildcards.sample} --outSAMtype BAM SortedByCoordinate"

# Step 4: Mark duplicates
rule Mark_duplicates:
    input:
        bam="{workdir}/{sample}_aligned.bam"
    output:
        dedup_bam="{workdir}/{sample}_dedup.bam"
    shell:
        "picard MarkDuplicates I={input.bam} O={output.dedup_bam} M={wildcards.workdir}/{wildcards.sample}_metrics.txt REMOVE_DUPLICATES=true"

# Step 5: Post-alignment QC
rule post_alignment_qc:
    input:
        bam="{workdir}/{sample}_dedup.bam"
    output:
        qc_report="{workdir}/{sample}_alignment_qc.txt"
    shell:
        "samtools stats {input.bam} > {output.qc_report}"

# Step 6: Quantification
rule Quantification:
    input:
        bam="{workdir}/{sample}_dedup.bam"
    output:
        counts="{workdir}/{sample}_counts.txt"
    params:
        annotation=config["annotation_gtf"]
    shell:
        "featureCounts -a {params.annotation} -o {output.counts} {input.bam}"

# Step 7: Normalization
rule Normalization:
    input:
        counts="{workdir}/{sample}_counts.txt"
    output:
        normalized="{workdir}/{sample}.normalized.txt"
    params:
        method=config["normalization_method"]
    shell:
        "python rules/normalize_expression.py --input {input.counts} --output {output.normalized} --method {params.method}"

# Step 8: Merge Normalized Files into One
rule Merge:
    input:
        expand("{workdir}/{sample}.normalized.txt", workdir=config["workdir"], sample=samples["sample"])
    output:
        merged_data="{workdir}/batch_correction/merged_normalized_data.txt"
    shell:
        "python rules/merge_normalized.py --input {input} --output {output.merged_data}"

# Step 9: Batch Correction
rule Batch_correction:
    input:
        merged_data="{workdir}/batch_correction/merged_normalized_data.txt"
    output:
        corrected_data="{workdir}/batch_correction/batch_corrected_data.txt"
    params:
        batch_file="samples.csv"
    shell:
        "python rules/batch_correct.py --input {input.merged_data} --batch_file {params.batch_file} --output {output.corrected_data}"

# Step 10: DEG Analysis using HeteroDE
rule HeteroDE:
    input:
        corrected_data="{workdir}/batch_correction/batch_corrected_data.txt"
    output:
        deg="{workdir}/deg/heteroDE_results.txt"
    params:
        batch_file="samples.csv",
        condition_column="condition"
    shell:
        "python rules/heteroDE.py --input {input.corrected_data} --batch_file {params.batch_file} "
        "--condition_column {params.condition_column} --output {output.deg}"


# Step 11: MultiQC (Run Once for All Samples)
rule Multiqc:
    input:
        expand("{workdir}/{sample}_R1_fastqc.html", workdir=config["workdir"], sample=samples["sample"]),
        expand("{workdir}/{sample}_R2_fastqc.html", workdir=config["workdir"], sample=samples["sample"])
    output:
        report="{workdir}/multiqc_report.html"
    shell:
        "multiqc -o {output.report}"

