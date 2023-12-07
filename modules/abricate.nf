#!/usr/bin/env nextflow

process ABRICATE {
    conda 'abricate-env.yaml'

    publishDir "${params.output_dir}"

    input:
        tuple val(id), path(ffn)
    output:
        path "*"
    script:
    """
    abricate --db vfdb "$ffn" > ${id}_vfdb.tbl
    abricate --db resfinder "$ffn" > ${id}_resfinder.tbl
    """
}
