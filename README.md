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

### 🔹 1. Quality Control

FastQC: Generates quality reports for raw reads.

MultiQC: Aggregates QC reports.

### QC is performed based on the criteria listed in the table below.

<table border="1" style="border-collapse: collapse; width: 100%; text-align: center;">
  <thead>
    <tr>
      <th colspan="2" style="background-color: #F8CECC;">Sequencing Read Quality</th>
      <th colspan="2" style="background-color: #D5E8D4;">Conamination and Duplicate reads</th>
      <th colspan="2" style="background-color: #DAE8FC;">Alignment Quality</th>
    </tr>
    <tr>
      <th style="background-color: #F8CECC;">Category</th>
      <th style="background-color: #F8CECC;">Criteria</th>
      <th style="background-color: #D5E8D4;">Category</th>
      <th style="background-color: #D5E8D4;">Criteria</th>
      <th style="background-color: #DAE8FC;">Category</th>
      <th style="background-color: #DAE8FC;">Criteria</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Total Read Count</td>
      <td>≥ 10M(raw data) <br>≥ 5M(filtered data)  </td>
      <td>PCR Duplication Rate</td>
      <td> Remove PCR duplicate (Picard MarkDuplicates)</td>
      <td>Overall Mapping Rate</td>
      <td>≥ 80%</td>
    </tr>
    <tr>
      <td>Per-base Q-score Distribution</td>
      <td>≥ 30</td>
      <td>Adapter Sequence  Rate</td>
      <td>≤ 10%(Good)<br> ≤ 20%(Warning)</td>
      <td>Uniquely Mapped Rate</td>
      <td>≥ 60%</td>
    </tr>
      <tr>
      <td>Per-base Composition</td>
      <td>A,T:25~30%<br> G,C:20~25%</td>
      <td>Low-Quality Base</td>
      <td>Remove low-quality base (Q<30)</td>
      <td>Multi-mapped Rate</td>
      <td>≤ 20%</td>
    </tr>
    <tr>
      <td>GC Content</td>
      <td>40% ~ 60%</td>
      <td>External Contamination Rate</td>
      <td> Remove external mapped reads (e.g., Bacteria, Virus)</td>
      <td>rRNA Rate</td>
      <td>≤ 15%</td>
    </tr>
    <tr>
      <td>Read Length Distribution</td>
      <td>50 ~ 200bp</td>
      <td>Spike-in Read Rate</td>
      <td>≤ 5%</td>
      <td>Intron-spanning Read Count</td>
      <td> > 10k</td>
    </tr>

  </tbody>
</table>


### 🔹 2. Read Trimming

Cutadapt: Removes adapter sequences and low-quality bases.


### 🔹 3. Read Alignment

STAR: Aligns reads to the reference genome.

Samtools: Sorts and indexes BAM files.


### 🔹 4. Post-alignment Processing

Picard (MarkDuplicates): Removes PCR duplicates.

Samtools stats: Generates alignment statistics.


### 🔹 5. Gene Expression Quantification

featureCounts: Counts mapped reads per gene.


### 🔹 6. Normalization

TPM, RPKM, or DESeq2 normalization applied.


### 🔹 7. Batch Correction

ComBat: Removes batch effects.

Batch information is obtained from samples.csv.


### 🔹 8. Differential Expression Analysis

HeteroDE: Identifies differentially expressed genes (DEGs).

## Run SnakeFile
```bash
snakemake --cores <num_cores>
```

## **4. Contact**
For any issues or questions, please contact jbhin@yuhs.ac or jabin1875@yuhs.ac
