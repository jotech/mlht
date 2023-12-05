#!/usr/bin/env nextflow

params.samples = "samples.csv"
params.output_dir = "out"

include { PRODIGAL } from "./modules/prodigal"
include { DBCAN } from "./subworkflows/dbcan"
include { GRODON } from "./modules/grodon"
include { BARRNAP } from "./modules/barrnap"
include { ANTISMASH } from "./subworkflows/antismash"
include { ABRICATE } from "./modules/abricate"
include { PLATON } from "./subworkflows/platon"
include { EGGNOG } from "./subworkflows/eggnog"
include { BAKTA } from "./subworkflows/bakta"
include { GUTSMASH } from "./modules/gutsmash"
include { KOFAMSCAN } from "./subworkflows/kofamscan"

workflow {
    samples = Channel
        .fromPath( params.samples )
        .splitCsv( header: true)
        .map { row -> tuple( row.id, file(row.file)) }

    PRODIGAL(samples)
    faa = PRODIGAL.out.faa
    ffn = PRODIGAL.out.ffn

    EGGNOG(faa)

    BAKTA(samples)
    GRODON(BAKTA.out.ffn)

    BARRNAP(samples)
    DBCAN(samples)

    KOFAMSCAN(samples)

    ABRICATE(ffn)
    ANTISMASH(samples)
    GUTSMASH(samples)
    PLATON(samples)
}