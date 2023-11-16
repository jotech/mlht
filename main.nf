params.samples = "samples.csv"
params.bakta_db = false
params.eggnog_db = false

process EGGNOG {
    conda 'bioconda::eggnog-mapper'

    input:
        tuple val(id), path(faa)
        path db
    output:
    script:
    """
    emapper.py -i $faa -o "$id" \
        --cpu $task.cpus \
        --data_dir $db \
        --override
    """
}

process EGGNOG_DB {
    conda 'bioconda::eggnog-mapper'

    publishDir "dbs/", mode: 'copy'

    output:
        path "eggnog"
    script:
    """
    mkdir -p data
    download_eggnog_data.py -y \
        --data_dir ./eggnog
    """

}

process BAKTA_DB {
    conda 'bakta-env.yaml'

    publishDir "dbs/", mode: 'copy'

    output:
        path "$outdir"
    script:
    outdir = "bakta_db"
    """
    bakta_db download --output $outdir --type full
    """
}

process BAKTA {
    conda 'bakta-env.yaml'

    publishDir "out/", mode: 'copy'

    input:
        tuple val(id), path(faa)
        path db
    output:
        path "bakta"
    script:
    """
    mkdir -p bakta
    bakta \
        --threads $task.cpus \
        --prefix "$id" \
        --output bakta \
        --db $db "$faa"
    """
}

process GRODON {
    // codon usage bias (gRodon)
    // from: https://github.com/jlw-ecoevo/gRodon2
    container "shengwei/grodon:latest"

    input:
    output:
        path "grodon"
    script:
    """
    Rscript ~/uni/life_history/src/codon.R -i $ffn -o grodon
    """
}

process BARRNAP {
    conda 'barrnap-env.yaml'

    input:
        tuple val(id), path(fna)
    output:
        path "${id}_16S.fna"
    script:
    """
    barrnap "$fna" \
        --threads $task.cpus \
        --outseq "${id}_16S.fna"
    """
}

process DBCAN_DB {
    conda 'bioconda::dbcan'

    publishDir "dbs/", mode: 'copy'

    output:
        path "dbcan"
    script:
    """
    mkdir dbcan
    cd db
    wget http://bcb.unl.edu/dbCAN2/download/Databases/fam-substrate-mapping-08252022.tsv
    wget http://bcb.unl.edu/dbCAN2/download/Databases/PUL.faa && makeblastdb -in PUL.faa -dbtype prot
    wget http://bcb.unl.edu/dbCAN2/download/Databases/dbCAN-PUL_07-01-2022.xlsx
    wget http://bcb.unl.edu/dbCAN2/download/Databases/dbCAN-PUL_07-01-2022.txt
    wget http://bcb.unl.edu/dbCAN2/download/Databases/dbCAN-PUL.tar.gz && tar xvf dbCAN-PUL.tar.gz
    wget http://bcb.unl.edu/dbCAN2/download/Databases/dbCAN_sub.hmm && hmmpress dbCAN_sub.hmm
    wget http://bcb.unl.edu/dbCAN2/download/Databases/V11/CAZyDB.08062022.fa && diamond makedb --in CAZyDB.08062022.fa -d CAZy
    wget https://bcb.unl.edu/dbCAN2/download/Databases/V11/dbCAN-HMMdb-V11.txt && mv dbCAN-HMMdb-V11.txt dbCAN.txt && hmmpress dbCAN.txt
    wget https://bcb.unl.edu/dbCAN2/download/Databases/V11/tcdb.fa && diamond makedb --in tcdb.fa -d tcdb
    wget http://bcb.unl.edu/dbCAN2/download/Databases/V11/tf-1.hmm && hmmpress tf-1.hmm
    wget http://bcb.unl.edu/dbCAN2/download/Databases/V11/tf-2.hmm && hmmpress tf-2.hmm
    wget https://bcb.unl.edu/dbCAN2/download/Databases/V11/stp.hmm && hmmpress stp.hmm
    cd ../
    wget http://bcb.unl.edu/dbCAN2/download/Samples/EscheriaColiK12MG1655.fna
    wget http://bcb.unl.edu/dbCAN2/download/Samples/EscheriaColiK12MG1655.faa
    wget http://bcb.unl.edu/dbCAN2/download/Samples/EscheriaColiK12MG1655.gff
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

process KOFAMSCAN {
    conda 'bioconda::kofamscan'

    publishDir "out/kofam", mode: 'copy'

    input:
        tuple val(id), path(faa)
        path profiles
        path ko_list
    output:
        path "${id}.txt"
    script:
    """
    gunzip $profiles
    gunzip $ko_list
    exec_annotation \
        --cpu $tak.cpus
        -f mapper
        -p profiles
        -k ko_list
        -o ${id}.txt "$faa"
    """
}

process ABRICATE {
    conda 'abricate'
    input:
    output:
    script:
    """
    abricate \
        --db vfdb "$id.ffn" > $output/abricate/${id}_vfdb.tbl
    abricate \
        --db resfinder "$id.ffn\$" > $output/abricate/${id}_resfinder.tbl
    """
}

process ANTISMASH {
    conda 'antismash'
    input:
    output:
        path "data"
    script:
    """
    antismash \
        --cb-general \
        --cb-knownclusters \
        --cb-subclusters \
        --asf \
        --pfam2go \
        --cc-mibig \
        --genefinding-tool prodigal -c $cores \
        --output-dir $output/antismash/$id \
        --output-basename $id $fasta
    """
}

process GUTSMASH {
    conda 'gutsmash'
    input:
    output:
    script:
    """
    ~/software/gutsmash/run_gutsmash.py \
        --cpus $cores \
        --genefinding-tool prodigal \
        --cb-knownclusters \
        --cb-general \
        --enable-genefunctions \
        --output-dir $output/gutsmash/$id $fasta
    """
}

process PLATON {
    // platon (plasmids)
    conda 'platon'
    input:
    output:
    script:
    """
    platon \
        --db ~/dat/db/platon/db \
        --threads $cores \
        --output $output/platon "$id.fna"
    """
}



workflow {
    samples = Channel
        .fromPath( params.samples )
        .splitCsv( header: true)
        .map { row -> tuple( row.id, file(row.file)) }

    // eggnog_db = params.eggnog_db ? file(params.eggnog_db) : EGGNOG_DB()
    // EGGNOG(samples, eggnog_db)

    bakta_db = params.bakta_db ? file(params.bakta_db) : BAKTA_DB()
    BAKTA(samples, bakta_db)

    kofam_profiles = Channel.fromPath("ftp://ftp.genome.jp/pub/db/kofam/profiles.tar.gz")
    kofam_ko_list = Channel.fromPath("ftp://ftp.genome.jp/pub/db/kofam/ko_list.gz")
    KOFAMSCAN_DB(samples, kofam_profiles, kofam_ko_list)
}