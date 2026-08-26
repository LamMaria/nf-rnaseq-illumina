process STAR_ALIGN {
    tag "$sample_id"

    container 'community.wave.seqera.io/library/htslib_samtools_star_gawk:ae438e9a604351a4'

    publishDir "${params.outdir}/star", mode: 'copy'

    input:
    tuple val(sample_id), path(reads), val(reference_id), path(index)

    output:
    tuple val(sample_id), path("${sample_id}.Aligned.sortedByCoord.out.bam"), emit: bam
    tuple val(sample_id), path("${sample_id}.Log.final.out"), emit: log_final
    tuple val(sample_id), path("${sample_id}.SJ.out.tab"), emit: splice_junctions

    script:
    """
    STAR \
        --genomeDir ${index} \
        --readFilesIn ${reads[0]} ${reads[1]} \
        --readFilesCommand zcat \
        --runThreadN ${task.cpus} \
        --outFileNamePrefix ${sample_id}. \
        --outSAMtype BAM SortedByCoordinate \
        --outSAMunmapped Within KeepPairs \
        --outSAMattributes NH HI AS nM XS
    """
}