#!/usr/bin/env nextflow

process BARRNAP {
    conda 'barrnap-env.yaml'

    publishDir "out/barrnap"

    input:
        tuple val(id), path(fna)
    output:
        path "${id}_16S.fna"
    script:
    """
    unset PERL5LIB
    unset PERL_LOCAL_LIB_ROOT
    barrnap "$fna" \
        --threads $task.cpus \
        --outseq "${id}_16S.fna"
    """
}