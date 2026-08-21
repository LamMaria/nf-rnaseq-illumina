process FASTP {
    tag "$sample_id"

    container 'community.wave.seqera.io/library/fastp:1.1.0--08aa7c5662a30d57'

    publishDir "${params.outdir}/fastp", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_R{1,2}.trimmed.fastq.gz"), emit: reads
    tuple val(sample_id), path("${sample_id}.fastp.html"), emit: html
    tuple val(sample_id), path("${sample_id}.fastp.json"), emit: json

    script:
    """
    fastp \
        --in1 ${reads[0]} \
        --in2 ${reads[1]} \
        --out1 ${sample_id}_R1.trimmed.fastq.gz \
        --out2 ${sample_id}_R2.trimmed.fastq.gz \
        --html ${sample_id}.fastp.html \
        --json ${sample_id}.fastp.json \
        --thread ${task.cpus} \
        --detect_adapter_for_pe
    """
}