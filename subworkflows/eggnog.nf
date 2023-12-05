#!/usr/bin/env nextflow

include { EGGNOG as EGGNOG_TASK } from '../modules/eggnog'
include { EGGNOG_DB } from '../modules/eggnog'

params.eggnog_db = false

workflow EGGNOG {
    take: faa

    main:

    eggnog_db = params.eggnog_db ? file(params.eggnog_db) : EGGNOG_DB()
    EGGNOG_TASK(faa, eggnog_db)

    emit:
        EGGNOG_TASK.out
}