#!/usr/bin/env nextflow

process BAKTA_DB {
    conda 'bakta==1.9.0'
    // container "quay.io/biocontainers/bakta:1.8.2--pyhdfd78af_0"

    publishDir "dbs/", saveAs: { filename -> "bakta" }, mode: 'copy'

    output:
        path "$outdir/db"
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

    # Check for out-of-memory errors and exit with the appropriate code
    # This will help Nextflow to retry the task with more memory
    check_err() {
        error_output=\$(cat .command.err)
        if [[ \$error_output =~ "-9" ]]; then
            exit 127
        else
            exit 1
        fi
    }

    trap 'check_err' ERR

    bakta \
        --threads $task.cpus \
        --skip-trna \
        --prefix "$id" \
        --output $id \
        --db $db "$faa"
    """
}
