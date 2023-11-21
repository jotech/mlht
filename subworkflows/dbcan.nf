include { DBCAN_PREPARE } from '../modules/dbcan'
include { DBCAN_TASK } from '../modules/dbcan'


workflow DBCAN {
    // take:
    //     samples
    main:
        substrate_mapping = Channel.fromPath("https://bcb.unl.edu/dbCAN2/download/Databases/fam-substrate-mapping-08252022.tsv")
        pul = Channel.fromPath("https://bcb.unl.edu/dbCAN2/download/Databases/PUL.faa")
        dbCAN_pul_xlsx = Channel.fromPath("https://bcb.unl.edu/dbCAN2/download/Databases/dbCAN-PUL_07-01-2022.xlsx")
        dbCAN_pul_txt = Channel.fromPath("https://bcb.unl.edu/dbCAN2/download/Databases/dbCAN-PUL_07-01-2022.txt")
        dbCAN_pul = Channel.fromPath("https://bcb.unl.edu/dbCAN2/download/Databases/dbCAN-PUL.tar.gz")
        dbCAN_sub = Channel.fromPath("https://bcb.unl.edu/dbCAN2/download/Databases/dbCAN_sub.hmm")
        CAZyDB = Channel.fromPath("https://bcb.unl.edu/dbCAN2/download/Databases/V11/CAZyDB.08062022.fa")
        HMM = Channel.fromPath("https://bcb.unl.edu/dbCAN2/download/Databases/V11/dbCAN-HMMdb-V11.txt")
        tcdb = Channel.fromPath("https://bcb.unl.edu/dbCAN2/download/Databases/V11/tcdb.fa")
        tf1 = Channel.fromPath("https://bcb.unl.edu/dbCAN2/download/Databases/V11/tf-1.hmm")
        tf2 = Channel.fromPath("https://bcb.unl.edu/dbCAN2/download/Databases/V11/tf-2.hmm")
        stp = Channel.fromPath("https://bcb.unl.edu/dbCAN2/download/Databases/V11/stp.hmm")
        ecoli_fna = Channel.fromPath("https://bcb.unl.edu/dbCAN2/download/Samples/EscheriaColiK12MG1655.fna")
        ecoli_faa = Channel.fromPath("https://bcb.unl.edu/dbCAN2/download/Samples/EscheriaColiK12MG1655.faa")
        ecoli_gff = Channel.fromPath("https://bcb.unl.edu/dbCAN2/download/Samples/EscheriaColiK12MG1655.gff")

        DBCAN_PREPARE(
            substrate_mapping, pul, dbCAN_pul_xlsx,
            dbCAN_pul_txt, dbCAN_pul, dbCAN_sub, CAZyDB,
            HMM, tcdb, tf1, tf2, stp
        )

    //     DBCAN_TASK((samples.id, samples.file), DBCAN_PREPARE.out, ecoli_fna, ecoli_faa, ecoli_gff)
    // emit:
    //     DBCAN_TASK.out
}