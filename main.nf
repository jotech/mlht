#!/usr/bin/env nextflow

params.samples = "samples.csv"
params.output_dir = "out"

include { PRODIGAL } from "./modules/prodigal"
include { DBCAN } from "./subworkflows/dbcan"
include { GRODON } from "./modules/grodon"
include { BARRNAP } from "./modules/barrnap"
include { ANTISMASH } from "./modules/antismash"
include { ABRICATE } from "./modules/abricate"
include { PLATON } from "./subworkflows/platon"
include { EGGNOG } from "./modules/eggnog"
include { BAKTA } from "./modules/bakta"

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
    tar -xvzf $profiles
    gunzip $ko_list
    exec_annotation \
        --cpu $task.cpus
        -f mapper
        -p profiles
        -k ko_list
        -o ${id}.txt "$faa"
    """
}

process GUTSMASH {
    container "nmendozam/gutsmash"
    input:
        tuple val(id), path(samples)
    output:
        path id
    script:
    """
    gutsmash \
        --cpus $task.cpus \
        --genefinding-tool prodigal \
        --cb-knownclusters \
        --cb-general \
        --enable-genefunctions \
        --output-dir $id $samples
    """
}

workflow {
    samples = Channel
        .fromPath( params.samples )
        .splitCsv( header: true)
        .map { row -> tuple( row.id, file(row.file)) }

    PRODIGAL(samples)
    faa = PRODIGAL.out.faa
    ffn = PRODIGAL.out.ffn

    EGGNOG(samples)

    BAKTA(samples)
    GRODON(BAKTA.out.ffn)

    BARRNAP(samples)
    DBCAN(samples)

    // kofam_profiles = Channel.fromPath("ftp://ftp.genome.jp/pub/db/kofam/profiles.tar.gz", type: 'file')
    // kofam_ko_list = Channel.fromPath("ftp://ftp.genome.jp/pub/db/kofam/ko_list.gz")
    // KOFAMSCAN(samples, kofam_profiles)

    ABRICATE(ffn)
    ANTISMASH(samples)
    GUTSMASH(samples)
    PLATON(samples)
}