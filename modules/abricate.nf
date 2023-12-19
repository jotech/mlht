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
    unset PERL5LIB
    unset PERL_LOCAL_LIB_ROOT

    abricate --db vfdb "$ffn" > ${id}_vfdb.tbl
    abricate --db resfinder "$ffn" > ${id}_resfinder.tbl
    """
}
