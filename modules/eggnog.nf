#!/usr/bin/env nextflow

process EGGNOG {
    conda 'bioconda::eggnog-mapper'

    publishDir "out/eggnog"

    input:
        tuple val(id), path(faa)
        path db
    output:
        path "*"
    script:
    """
    emapper.py -i $faa -o "$id" \
        --cpu $task.cpus \
        --data_dir $db \
        --override
    """
}

process EGGNOG_DB {
    conda 'bioconda::eggnog-mapper'

    publishDir "dbs/", mode: 'copy'

    output:
        path "eggnog"
    script:
    """
    mkdir -p eggnog
    download_eggnog_data.py -y \
        --data_dir eggnog
    """

}
