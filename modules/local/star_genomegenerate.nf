process STAR_GENOMEGENERATE {
    tag "$reference_id"

    container 'community.wave.seqera.io/library/htslib_samtools_star_gawk:ae438e9a604351a4'

    publishDir "${params.outdir}/reference/star", mode: 'copy'

    input:
    tuple val(reference_id), path(fasta), path(gtf)

    output:
    tuple val(reference_id), path('star_index'), emit: index

    script:
    def sjdb_overhang = params.read_length - 1

    """
    mkdir star_index

    STAR \
        --runThreadN ${task.cpus} \
        --runMode genomeGenerate \
        --genomeDir star_index \
        --genomeFastaFiles ${fasta} \
        --sjdbGTFfile ${gtf} \
        --sjdbOverhang ${sjdb_overhang} \
        --genomeSAindexNbases ${params.star_sa_index_nbases} \
        --limitGenomeGenerateRAM 4000000000
    """
}