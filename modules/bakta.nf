#!/usr/bin/env nextflow

process BAKTA_DB {
    conda 'bakta==1.9.0'
    // container "quay.io/biocontainers/bakta:1.8.2--pyhdfd78af_0"

    publishDir "dbs/", mode: 'copy'

    output:
        path "$outdir"
    script:
    outdir = "bakta_db"
    """
    bakta_db download --output $outdir --type full
    """
}

process BAKTA {
    tag "$id"
    conda 'bakta==1.9.0'
    // container "quay.io/biocontainers/bakta:1.8.2--pyhdfd78af_0"

    memory '8 GB'

    publishDir "${params.output_dir}/bakta", mode: 'copy'

    input:
        tuple val(id), path(faa)
        path db
    output:
        path("${id}/")
        tuple val(id), path("$id/*.ffn"), emit: ffn
    script:
    """
    unset PERL5LIB
    unset PERL_LOCAL_LIB_ROOT
    bakta \
        --threads $task.cpus \
        --skip-trna \
        --prefix "$id" \
        --output $id \
        --db $db "$faa"
    """
}
