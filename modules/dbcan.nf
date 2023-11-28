
process DBCAN_PREPARE {
    conda 'bioconda::dbcan'

    publishDir "dbs/", mode: 'copy'

    input:
        path substrate_mapping, stageAs: 'dbcan/*'
        path pul, stageAs: 'dbcan/*'
        path dbCAN_pul_xlsx, stageAs: 'dbcan/*'
        path dbCAN_pul_txt, stageAs: 'dbcan/*'
        path dbCAN_pul, stageAs: 'dbcan/*'
        path dbCAN_sub, stageAs: 'dbcan/*'
        path CAZyDB, stageAs: 'dbcan/*'
        path HMM, name: "dbCAN.txt", stageAs: 'dbcan/*'
        path tcdb, stageAs: 'dbcan/*'
        path tf1, stageAs: 'dbcan/*'
        path tf2, stageAs: 'dbcan/*'
        path stp, stageAs: 'dbcan/*'
        path ecoli_fna, stageAs: 'dbcan/*'
        path ecoli_faa, stageAs: 'dbcan/*'
        path ecoli_gff, stageAs: 'dbcan/*'
    output:
        path "dbcan"
    script:
    """
    cd dbcan
    makeblastdb -in $pul.fileName.name -dbtype prot
    tar xvf $dbCAN_pul.fileName.name
    hmmpress $dbCAN_sub.fileName.name
    diamond makedb --in $CAZyDB.fileName.name -d CAZy
    hmmpress $HMM.fileName.name
    diamond makedb --in $tcdb.fileName.name -d tcdb
    hmmpress $tf1.fileName.name
    hmmpress $tf2.fileName.name
    hmmpress $stp.fileName.name
    """

}

process DBCAN_TASK {
    //TODO: add param for signalP
    conda 'bioconda::dbcan'

    input:
        each sample
        path db
    output:
        path outdir
    script:
    (id, fna) = sample
    outdir = "dbcan"
    """
    run_dbcan "$fna" prok \
        --out_dir $outdir -c cluster \
        --cgc_substrate \
        --pul $db/PUL.faa \
        --db_dir $db \
        --use_signalP=TRUE \
        --hmm_cpu $task.cpus \
        --dia_cpu $task.cpus \
        --tf_cpu $task.cpus \
        --stp_cpu $task.cpus
    """
}