nextflow.enable.dsl = 2

include { FASTQC } from './modules/local/fastqc'

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
}