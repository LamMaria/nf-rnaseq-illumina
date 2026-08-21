nextflow.enable.dsl = 2

include { FASTQC } from './modules/local/fastqc'
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


    multiqc_input_ch = FASTQC.out.zip
        .map { sample_id, reports -> reports }
        .flatten()
        .collect()

    MULTIQC(multiqc_input_ch)
}