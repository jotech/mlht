
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
        path HMM
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
    cd dbcan
    mv $substrate_mapping .
    mv $pul . && makeblastdb -in PUL.faa -dbtype prot
    mv $dbCAN_pul_xlsx .
    mv $dbCAN_pul_txt .
    mv $dbCAN_pul . && tar xvf dbCAN-PUL.tar.gz
    mv $dbCAN_sub . && hmmpress dbCAN_sub.hmm
    mv $CAZyDB . && diamond makedb --in CAZyDB.08062022.fa -d CAZy
    mv $HMM . && mv dbCAN-HMMdb-V11.txt dbCAN.txt && hmmpress dbCAN.txt
    mv $tcdb . && diamond makedb --in tcdb.fa -d tcdb
    mv $tf1 . && hmmpress tf-1.hmm
    mv $tf2 . && hmmpress tf-2.hmm
    mv $stp . && hmmpress stp.hmm
    cd ../
    mv ecoli_fna .
    mv ecoli_faa .
    mv ecoli_gff .
    """

}

process DBCAN {
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