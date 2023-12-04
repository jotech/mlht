process PRODIGAL {
    conda 'bioconda::prodigal'

    publishDir "${params.output_dir}/prodigal", mode: 'copy'

    input:
        tuple val(id), path(fasta)
    output:
        tuple val(id), path("$id/*.ffn"), emit: ffn
        tuple val(id), path("$id/*.faa"), emit: faa
    script:
    """
    prodigal \
        -i $fasta \
        -o /dev/null \
        -a "$id.faa" \
        -d "$id.ffn" \
    """
}
