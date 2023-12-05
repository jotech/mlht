#!/usr/bin/env nextflow

process KOFAMSCAN_PROFILES {
    publishDir "dbs/kofam"

    input:
        path profiles_gz
    output:
        path "profiles", emit: profiles
    script:
    """
    tar -xvzf $profiles_gz
    """
}

process KOFAMSCAN_KO_LIST {
    publishDir "dbs/kofam"

    input:
        path ko_list_gz
    output:
        path "ko_list", emit: ko_list
    script:
    """
    gunzip $ko_list_gz
    """
}


process KOFAMSCAN {
    conda 'bioconda::kofamscan'

    publishDir "${params.output_dir}/kofam", mode: 'copy'

    input:
        tuple val(id), path(faa)
        path profiles
        path ko_list
    output:
        path "${id}.txt"
    script:
    """
    exec_annotation \
        --cpu $task.cpus
        -f mapper
        -p $profiles
        -k $ko_list
        -o ${id}.txt "$faa"
    """
}
