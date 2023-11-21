
process DBCAN_PREPARE {
    conda 'bioconda::dbcan'

    publishDir "dbs/", mode: 'copy'

    input:
        path substrate_mapping
        path pul
        path dbCAN_pul_xlsx
        path dbCAN_pul_txt
        path dbCAN_pul
        path dbCAN_sub
        path CAZyDB
        path HMM name: "dbCAN.txt"
        path tcdb
        path tf1
        path tf2
        path stp
        path ecoli_fna
        path ecoli_faa
        path ecoli_gff
    output:
        path "dbcan"
    script:
    """
    mkdir dbcan
    mv $substrate_mapping dbcan
    mv $pul dbcan
    mv $dbCAN_pul_xlsx dbcan
    mv $dbCAN_pul_txt dbcan
    mv $dbCAN_pul dbcan
    mv $dbCAN_sub dbcan
    mv $CAZyDB dbcan
    mv $HMM dbcan
    mv $tcdb dbcan
    mv $tf1 dbcan
    mv $tf2 dbcan
    mv $stp dbcan
    mv $ecoli_fna dbcan
    mv $ecoli_faa dbcan
    mv $ecoli_gff dbcan

    cd dbcan
    makeblastdb -in $pul -dbtype prot
    tar xvf $dbCAN_pul
    hmmpress $dbCAN_sub
    diamond makedb --in $CAZyDB -d CAZy
    hmmpress $HMM
    diamond makedb --in $tcdb -d tcdb
    hmmpress $tf1
    hmmpress $tf2
    hmmpress $stp
    """

}

process DBCAN_TASK {
    conda 'bioconda::dbcan'

    input:
        tuple val(id), path(fna)
        path db
    output:
        path outdir
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