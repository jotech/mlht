
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
    conda 'bioconda::dbcan'

    input:
        tuple val(id), path(fna)
        path db
    output:
        path outdir, name "database"
    script:
    outdir = "dbscan"
    """
    run_dbcan "$fna" prok \
        --out_dir $outdir -c cluster \
        --cgc_substrate \
        --pul $db/PUL.faa \
        --db_dir $db \
        --use_signalP=TRUE \
        --signalP_path /zfshome/sukem066/software/signalp-4.1/signalp \
        --hmm_cpu $taks.cpus \
        --dia_cpu $taks.cpus \
        --tf_cpu $taks.cpus \
        --stp_cpu $taks.cpus
    """
}