# nf-rnaseq-illumina

A modular and reproducible paired-end Illumina RNA-seq pipeline built with Nextflow DSL2 and Docker.

> This project is under active development. It currently performs read quality control, adapter and quality trimming, STAR reference indexing, splice-aware alignment, and consolidated MultiQC reporting.

## Workflow

```text
Samplesheet
    │
    ├── FastQC (raw reads)
    │
    └── fastp
          │
          ├── FastQC (trimmed reads)
          │
          └── STAR alignment against an indexed reference genome
                    │
                    └── MultiQC report
```

## Features

- Modular Nextflow DSL2 architecture
- Docker containers with pinned tool versions
- Samplesheet-driven paired-end FASTQ input
- Raw and post-trimming quality control with FastQC
- Adapter detection and trimming with fastp
- STAR genome index generation from FASTA and GTF files
- Splice-aware RNA-seq alignment with STAR
- Coordinate-sorted BAM output
- BAM indexing with samtools for efficient alignment inspection.
- Consolidated quality and alignment reporting with MultiQC
- Gene-level paired-end quantification with featureCounts
- Task caching and restart support with `-resume`

## Software

| Tool | Version | Purpose |
|---|---:|---|
| Nextflow | 26.04.6 | Workflow orchestration |
| FastQC | 0.12.1 | FASTQ quality control |
| fastp | 1.1.0 | Adapter and quality trimming |
| STAR | 2.7.11b | Splice-aware alignment |
| samtools | 1.21 | Alignment quality control |
| MultiQC | 1.32 | Aggregated reporting |
| featureCounts | 2.0.6 | Gene-level quantification |
| Docker | Required | Container execution |

## Requirements

- Linux or Windows Subsystem for Linux 2 (WSL2)
- Java 21 or later
- Nextflow
- Docker

Verify the environment:

```bash
java -version
nextflow -version
docker --version
```

## Input samplesheet

```csv
sample,fastq_1,fastq_2
SRR8554919,data/raw/GSE126331/SRR8554919_1.fastq.gz,data/raw/GSE126331/SRR8554919_2.fastq.gz
```

- `sample` is the sample identifier.
- `fastq_1` and `fastq_2` are paths to paired-end compressed FASTQ files.
- Raw sequencing data are excluded from Git version control.

## Reference files

The default configuration uses the *Arabidopsis thaliana* TAIR10 reference genome and Ensembl Plants release 60 annotation.

```text
references/arabidopsis_tair10_ensembl60/
├── Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
└── Arabidopsis_thaliana.TAIR10.60.gtf
```

STAR builds the genome index automatically. For this 250 bp dataset:

```text
sjdbOverhang = 249
genomeSAindexNbases = 12
```

## Run the pipeline

```bash
nextflow run main.nf
```

Resume a previous execution:

```bash
nextflow run main.nf -resume
```

Use a custom samplesheet or output directory:

```bash
nextflow run main.nf \
    --samplesheet assets/samplesheet.csv \
    --outdir results
```

## Output structure

```text
results/
├── fastqc/
│   ├── Raw-read and post-trimming FastQC reports
├── fastp/
│   ├── Trimmed paired-end FASTQ files
│   ├── HTML report
│   └── JSON metrics
├── star/
│   ├── Coordinate-sorted BAM file
│   ├── STAR Log.final.out alignment metrics
│   └── Detected splice junctions
├── samtools/
│   ├── samtools flagstat alignment summary
│   └── BAM index (.bai)
├── featurecounts/
│   ├── Gene-level count table
│   └── Assignment summary
└── multiqc/
    ├── multiqc_report.html
    └── multiqc_report_data/
```

Generated results, raw data, reference files, and Nextflow work directories are excluded from Git version control.

## Validation with public RNA-seq data

The pipeline was validated with paired-end *Arabidopsis thaliana* RNA-seq data from the public study [GSE126331](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE126331), using ENA run `SRR8554919`.

| Metric | Before fastp | After fastp / STAR |
|---|---:|---:|
| Read pairs | 34.75 M | 34.21 M |
| Q30 rate | 94.07% | 94.75% |
| GC content | 47.03% | 47.02% |
| Adapter-trimmed reads | — | 560,198 |
| Uniquely mapped reads | — | 89.21% |
| Primary mapped reads (samtools) | — | 98.99% |
| Properly paired reads (samtools) | — | 98.99% |
| Singleton reads (samtools) | — | 255 |
| Multi-mapped reads | — | 9.78% |
| Mismatch rate per base | — | 0.12% |
| Annotated splice junctions | — | 99.6% |
| Fragments assigned to genes | — | 28.77 M |
| Unassigned multi-mapping fragments | — | 6.95 M |
| Unassigned ambiguous fragments | — | 1.07 M |

This validation run demonstrates workflow reproducibility and technical quality control. It is not presented as a biological differential-expression analysis.

## Project structure

```text
nf-rnaseq-illumina/
├── assets/
│   └── samplesheet.csv
├── modules/
│   └── local/
│       ├── fastp.nf
│       ├── fastqc.nf
│       ├── multiqc.nf
│       ├── star_align.nf
│       ├── star_genomegenerate.nf
│       ├── samtools_flagstat.nf
│       ├── samtools_index.nf
│       └── featurecounts.nf

├── .gitignore
├── main.nf
├── nextflow.config
└── README.md
```

## Roadmap

- [x] Raw-read FastQC
- [x] fastp trimming
- [x] Post-trimming FastQC
- [x] STAR genome index generation
- [x] STAR alignment
- [x] MultiQC aggregation
- [x] Alignment quality control with samtools
- [x] BAM indexing for alignment inspection
- [ ] Gene-level quantification
- [ ] Differential expression analysis with biological replicates
- [ ] Automated tests and continuous integration
- [ ] Pipeline notifications for successful and failed runs

## Author

Lamia Benghelima  
Bioinformatics Engineer | NGS Pipelines and Data Analysis