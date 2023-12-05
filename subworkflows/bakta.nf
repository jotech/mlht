#!/usr/bin/env nextflow

include { BAKTA as BAKTA_TASK } from '../modules/bakta'
include { BAKTA_DB } from '../modules/bakta'

params.bakta_db = false

workflow BAKTA {
    take: samples
    
    main:

    bakta_db = params.bakta_db ? file(params.bakta_db) : BAKTA_DB()
    BAKTA_TASK(samples, bakta_db)

    emit:
        ffn = BAKTA_TASK.out.ffn
}