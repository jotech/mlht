#!/usr/bin/env nextflow

include { KOFAMSCAN as KOFAMSCAN_TASK } from '../modules/kofamscan'
include { KOFAMSCAN_PROFILES } from '../modules/kofamscan'
include { KOFAMSCAN_KO_LIST } from '../modules/kofamscan'

params.kofam_profiles = false
params.kofam_ko_list = false

workflow KOFAMSCAN {
    take: samples

    main:

    if (params.kofam_profiles) {
        kofam_profiles = params.kofam_profiles
    } else {
        kofam_profiles_gz = Channel.fromPath("ftp://ftp.genome.jp/pub/db/kofam/profiles.tar.gz", type: 'file')
        kofam_profiles = KOFAMSCAN_PROFILES(kofam_profiles_gz)
    }

    if (params.kofam_ko_list) {
        kofam_ko_list = params.kofam_ko_list
    } else {
        kofam_ko_list_gz = Channel.fromPath("ftp://ftp.genome.jp/pub/db/kofam/ko_list.gz")
        kofam_ko_list = KOFAMSCAN_KO_LIST(kofam_ko_list_gz)
    }

    KOFAMSCAN_TASK(samples, kofam_profiles, kofam_ko_list)

    emit:
        KOFAMSCAN_TASK.out
}