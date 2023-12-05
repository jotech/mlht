#!/usr/bin/env nextflow

include { ANTISMASH as ANTISMASH_TASK } from '../modules/antismash'
include { ANTISMASH_DB } from '../modules/antismash'

params.antismash_db = false

workflow ANTISMASH {
    take: samples

    main:

    if (params.antismash_db) {
        antismash_db = params.antismash_db
    } else {
        antismash_db = ANTISMASH_DB()
    }

    ANTISMASH_TASK(samples, antismash_db)

    emit:
        ANTISMASH_TASK.out
}