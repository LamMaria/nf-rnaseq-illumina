nextflow.enable.dsl = 2

include { FASTQC } from './modules/local/fastqc'
include { FASTQC as FASTQC_TRIMMED } from './modules/local/fastqc'
include { FASTP } from './modules/local/fastp'
include { MULTIQC } from './modules/local/multiqc'

workflow {
    reads_ch = Channel.of(
        tuple(
            'test',
            [
                file(params.fastq_1, checkIfExists: true),
                file(params.fastq_2, checkIfExists: true)
            ]
        )
    )

    FASTQC(reads_ch)

    FASTP(reads_ch)

    FASTQC_TRIMMED(FASTP.out.reads)

    multiqc_input_ch = FASTQC.out.zip
        .mix(FASTQC_TRIMMED.out.zip)
        .mix(FASTP.out.html)
        .mix(FASTP.out.json)
        .map { sample_id, reports -> reports }
        .flatten()
        .collect()

    MULTIQC(multiqc_input_ch)
}