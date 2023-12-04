include { PLATON_DB, PLATON as PLATON_TASK } from '../modules/platon'
params.platon_db = false

workflow PLATON {
    take: samples

    main:

    if (params.platon_db) {
        platon_db = params.platon_db
    } else {
        db_gz = Channel.fromPath("https://zenodo.org/record/4066768/files/db.tar.gz")
        platon_db = PLATON_DB(db_gz)
    }

    PLATON(samples, plation_db)

    emit:
        PLATON.out
}