#!/usr/bin/env nextflow

process GRODON {
    // codon usage bias (gRodon)
    // from: https://github.com/jlw-ecoevo/gRodon2
    container "nmendozam/grodon:latest"

    publishDir "results/grodon"

    input:
        tuple val(id), path(ffn)
    output:
        path "grodon"
    script:
    """
    mkdir -p grodon
    codon.R -i $ffn -o grodon
    """
}
