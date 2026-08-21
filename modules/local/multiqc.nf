process MULTIQC {
    container 'quay.io/biocontainers/multiqc:1.32--pyhdfd78af_0'

    publishDir "${params.outdir}/multiqc", mode: 'copy'

    input:
    path qc_files

    output:
    path 'multiqc_report.html', emit: report
    path 'multiqc*_data', emit: data

    script:
    """
    multiqc . --force --filename multiqc_report.html
    """
}