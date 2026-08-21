# nf-rnaseq-illumina

A modular and reproducible Illumina paired-end RNA-seq pipeline developed with Nextflow DSL2 and Docker.

> This project is under active development. The current version performs raw-read quality control, adapter and quality trimming, post-trimming quality control, and consolidated reporting.

## Current workflow

```text
Paired-end FASTQ
├── FastQC (raw reads) ────────────────────┐
└── fastp ──> trimmed FASTQ ──> FastQC ────┼──> MultiQC
                         fastp reports ─────┘
```

## Features

- Modular Nextflow DSL2 architecture
- Reproducible execution with versioned containers
- Raw-read quality control with FastQC
- Adapter detection and paired-end trimming with fastp
- Post-trimming quality control
- Consolidated HTML reporting with MultiQC
- Task caching and pipeline restart with `-resume`
- Lightweight public test data for local smoke testing

## Software

| Tool | Version | Purpose |
|---|---:|---|
| Nextflow | 26.04.6 | Workflow orchestration |
| FastQC | 0.12.1 | FASTQ quality control |
| fastp | 1.1.0 | Adapter and quality trimming |
| MultiQC | 1.32 | Aggregated quality report |
| Docker | Required | Container execution |

## Requirements

- Linux or Windows Subsystem for Linux 2
- Java 21 or later
- Nextflow
- Docker

Verify the environment:

```bash
java -version
nextflow -version
docker --version
```

## Quick start

Clone the repository and enter the project directory:

```bash
git clone <REPOSITORY_URL>
cd nf-rnaseq-illumina
```

Run the pipeline with the default public test data:

```bash
nextflow run main.nf
```

Resume a previous execution:

```bash
nextflow run main.nf -resume
```

## Custom paired-end input

```bash
nextflow run main.nf \
    --fastq_1 /path/to/sample_R1.fastq.gz \
    --fastq_2 /path/to/sample_R2.fastq.gz \
    --outdir results
```

Parameters beginning with `--` belong to the pipeline. Nextflow options such as `-resume` use a single dash.

## Public test data

The default smoke test uses small paired-end Illumina FASTQ files from the public [nf-core/test-datasets](https://github.com/nf-core/test-datasets) repository.

These files validate pipeline execution and are not intended for biological interpretation. A complete public RNA-seq study with biological replicates will be added later.

## Output structure

```text
results/
├── fastqc/
├── fastp/
└── multiqc/
    └── multiqc_report.html
```

Generated results and Nextflow working files are excluded from Git version control.

## Project structure

```text
nf-rnaseq-illumina/
├── main.nf
├── nextflow.config
├── modules/
│   └── local/
│       ├── fastp.nf
│       ├── fastqc.nf
│       └── multiqc.nf
├── .gitignore
└── README.md
```

## Roadmap

- [x] Raw-read FastQC
- [x] fastp trimming
- [x] Post-trimming FastQC
- [x] MultiQC aggregation
- [ ] Samplesheet validation
- [ ] Reference genome preparation
- [ ] STAR alignment
- [ ] Alignment quality control
- [ ] Gene-level quantification
- [ ] Differential expression analysis
- [ ] Automated tests and continuous integration

## Author

Lamia Benghelima  
Bioinformatics Engineer | NGS Pipelines and Data Analysis