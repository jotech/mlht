#!/usr/bin/env nextflow

process GUTSMASH {
    container "nmendozam/gutsmash"

    publishDir "${params.output_dir}/gutsmash"

    input:
        tuple val(id), path(samples)
    output:
        path id
    script:
    """
    run_gutsmash.py \
        --cpus $task.cpus \
        --genefinding-tool prodigal \
        --cb-knownclusters \
        --cb-general \
        --enable-genefunctions \
        --output-dir $id $samples
    """
}
