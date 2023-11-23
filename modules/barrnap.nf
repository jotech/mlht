process BARRNAP {
    conda 'barrnap-env.yaml'

    input:
        tuple val(id), path(fna)
    output:
        path "${id}_16S.fna"
    script:
    """
    barrnap "$fna" \
        --threads $task.cpus \
        --outseq "${id}_16S.fna"
    """
}