#!/usr/bin/env nextflow

include { PLATON as PLATON_TASK } from '../modules/platon'
include { PLATON_DB } from '../modules/platon'
params.platon_db = false

workflow PLATON {
    take: samples

    main:

    if (params.platon_db) {
        platon_db = file(params.platon_db)
    } else {
        db_gz = Channel.fromPath("https://zenodo.org/record/4066768/files/db.tar.gz")
        platon_db = PLATON_DB(db_gz)
    }

    PLATON_TASK(samples, platon_db)

    emit:
        PLATON_TASK.out
}