process SAMTOOLS_INDEX {
    tag "$sample_id"

    container 'community.wave.seqera.io/library/htslib_samtools_star_gawk:ae438e9a604351a4'

    publishDir "${params.outdir}/samtools", mode: 'copy'

    input:
    tuple val(sample_id), path(bam)

    output:
    tuple val(sample_id), path("${sample_id}.Aligned.sortedByCoord.out.bam.bai"), emit: bai

    script:
    """
    samtools index \
        --threads ${task.cpus} \
        ${bam} \
        ${sample_id}.Aligned.sortedByCoord.out.bam.bai
    """
}