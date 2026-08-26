nextflow.enable.dsl = 2

include { FASTQC } from './modules/local/fastqc'
include { FASTQC as FASTQC_TRIMMED } from './modules/local/fastqc'
include { FASTP } from './modules/local/fastp'
include { MULTIQC } from './modules/local/multiqc'
include { STAR_GENOMEGENERATE } from './modules/local/star_genomegenerate'
include { STAR_ALIGN } from './modules/local/star_align'
include { SAMTOOLS_FLAGSTAT } from './modules/local/samtools_flagstat'
include { SAMTOOLS_INDEX } from './modules/local/samtools_index'


workflow {
    samples_ch = Channel
        .fromPath(params.samplesheet, checkIfExists: true)
        .splitCsv(header: true)
        .map { row ->
            tuple(
                row.sample,
                [
                    file(row.fastq_1, checkIfExists: true),
                    file(row.fastq_2, checkIfExists: true)
                ]
            )
        }

    FASTQC(samples_ch)
    FASTP(samples_ch)
    FASTQC_TRIMMED(FASTP.out.reads)

    reference_ch = Channel.of(
        tuple(
            'arabidopsis_tair10_ensembl60',
            file(params.fasta, checkIfExists: true),
            file(params.gtf, checkIfExists: true)
        )
    )

    STAR_GENOMEGENERATE(reference_ch)

    star_alignment_input_ch = FASTP.out.reads.combine(STAR_GENOMEGENERATE.out.index)

    STAR_ALIGN(star_alignment_input_ch)
    SAMTOOLS_FLAGSTAT(STAR_ALIGN.out.bam)
    SAMTOOLS_INDEX(STAR_ALIGN.out.bam)

    multiqc_input_ch = FASTQC.out.zip
        .mix(FASTQC_TRIMMED.out.zip)
        .mix(FASTP.out.html)
        .mix(FASTP.out.json)
        .mix(STAR_ALIGN.out.log_final)
        .mix(SAMTOOLS_FLAGSTAT.out.flagstat)
        .map { sample_id, reports -> reports }
        .flatten()
        .collect()

    MULTIQC(multiqc_input_ch)
}