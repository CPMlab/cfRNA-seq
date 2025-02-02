# cfRNA-seq
# cfRNA-seq Pipeline

## **1. Introduction**
This repository contains a Snakemake-based pipeline for processing cell-free RNA sequencing (cfRNA-seq) data.  
The pipeline automates the preprocessing, alignment, quality control, quantification, normalization, batch correction, and differential expression analysis (DEG) of cfRNA-seq data.  

### **🔹 Key Features**
- Automated **end-to-end cfRNA-seq data analysis** using Snakemake.
- **Batch correction** to eliminate batch effects.
- Supports **multi-sample parallel processing**.
- **Modular design** for easy customization.

---

## **2. Environment Setup using `snakemake.yaml`**
To ensure reproducibility, the pipeline requires a specific computing environment defined in `snakemake.yaml`.

### **🔹 Install Conda & Mamba (if not installed)**
```bash
conda install -c conda-forge mamba
```
###  Create conda environment 
```bash
conda env create -f snakemake.yaml
```
###  Activate conda environment
```bash
conda activate snakemake
```
## **3. Pipeline Components**
![image](https://github.com/user-attachments/assets/bdf5c52f-b8ff-4703-b4b5-2d7e79e80852)

The pipeline consists of several key steps:

🔹 1. Quality Control

FastQC: Generates quality reports for raw reads.

MultiQC: Aggregates QC reports.


🔹 2. Read Trimming

Cutadapt: Removes adapter sequences and low-quality bases.


🔹 3. Read Alignment

STAR: Aligns reads to the reference genome.

Samtools: Sorts and indexes BAM files.


🔹 4. Post-alignment Processing

Picard (MarkDuplicates): Removes PCR duplicates.

Samtools stats: Generates alignment statistics.


🔹 5. Gene Expression Quantification

featureCounts: Counts mapped reads per gene.


🔹 6. Normalization

TPM, RPKM, or DESeq2 normalization applied.


🔹 7. Batch Correction

ComBat: Removes batch effects.

Batch information is obtained from samples.csv.


🔹 8. Differential Expression Analysis

HeteroDE: Identifies differentially expressed genes (DEGs).

## Run SnakeFile
```bash
snakemake --cores <num_cores>
```

## **4. Contact**
For any issues or questions, please contact jbhin@yuhs.ac or jabin1875@yuhs.ac
