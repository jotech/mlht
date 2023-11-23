
process GRODON {
    // codon usage bias (gRodon)
    // from: https://github.com/jlw-ecoevo/gRodon2
    container "nmendozam/grodon:latest"

    input:
        tuple val(id), path(ffn)
    output:
        path "grodon"
    script:
    """
    codon.R -i $ffn -o grodon
    """
}
