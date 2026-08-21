nextflow.enable.dsl = 2

params.outdir = 'results'

process CHECK_SETUP {
    publishDir "${params.outdir}/setup", mode: 'copy'

    output:
    path 'setup_check.txt'

    script:
    """
    echo "RNA-seq pipeline environment is ready" > setup_check.txt
    """
}

workflow {
    CHECK_SETUP()
}