#!/usr/bin/env nextflow

params.samples = "samples.csv"
params.bakta_db = false
params.eggnog_db = false
params.output_dir = "out"

include { PRODIGAL } from "./modules/prodigal"
include { DBCAN } from "./subworkflows/dbcan"
include { GRODON } from "./modules/grodon"
include { BARRNAP } from "./modules/barrnap"
include { ANTISMASH } from "./modules/antismash"
include { ABRICATE } from "./modules/abricate"
include { PLATON } from "./subworkflows/platon"


process EGGNOG {
    conda 'bioconda::eggnog-mapper'

    input:
        tuple val(id), path(faa)
        path db
    output:
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

    eggnog_db = params.eggnog_db ? file(params.eggnog_db) : EGGNOG_DB()
    EGGNOG(faa, eggnog_db)

    bakta_db = params.bakta_db ? file(params.bakta_db) : BAKTA_DB()
    BAKTA(samples, bakta_db)

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