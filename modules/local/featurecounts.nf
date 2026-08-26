process FEATURECOUNTS {
    tag "$sample_id"

    container 'quay.io/biocontainers/subread:2.0.6--he4a0461_1'

    publishDir "${params.outdir}/featurecounts", mode: 'copy'

    input:
    tuple val(sample_id), path(bam)
    path gtf

    output:
    tuple val(sample_id), path("${sample_id}.featureCounts.txt"), emit: counts
    tuple val(sample_id), path("${sample_id}.featureCounts.txt.summary"), emit: summary

    script:
    """
    featureCounts \
        -T ${task.cpus} \
        -a ${gtf} \
        -o ${sample_id}.featureCounts.txt \
        -t exon \
        -g gene_id \
        -p \
        --countReadPairs \
        -s ${params.strandedness} \
        ${bam}
    """
}