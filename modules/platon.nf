
process PLATON_DB {
    conda 'platon'

    publishDir "dbs/platon", mode: 'copy'

    output:
        path "db"
    script:
    """
    tar -xzf db.tar.gz
    """
}

process PLATON {
    // platon (plasmids)
    conda 'platon'

    publishDir "${params.output_dir}/platon"

    input:
        tuple val(id), path(samples)
        path platon_db
    output:
        path id
    script:
    """
    platon \
        --db $platon_db \
        --threads $task.cpus \
        --output $id "$samples"
    """
}
