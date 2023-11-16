params.samples = "samples.csv"
params.bakta_db = "dbs/bakta/db"
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

    publishDir "dbs/eggnog", mode: 'move'

    output:
        path "data"
    script:
    """
    mkdir -p data
    download_eggnog_data.py -y \
        --data_dir ./data
    """

}

process BAKTA_DB {
    conda 'bioconda::bakta'

    publishDir "dbs/", mode: 'move'

    output:
        path "$outdir"
    script:
    out_dir = "bakta_db"
    """
    bakta_db download --output $outdir --type full
    """
}

process BAKTA {
    conda 'bioconda::bakta'

    input:
        tuple val(id), path(faa)
        path db
    output:
        path "data"
    script:
    """
    mkdir -p data
    bakta \
        --threads $task.cpus \
        --prefix "$id" \
        --output data \
        --db $db "$fna"
    """
}

process GRODON {
    // codon usage bias (gRodon)
    input:
    output:
    script:
    """
    Rscript ~/uni/life_history/src/codon.R -i $output/bakta/$id/$id.ffn -o $output/grodon
    """
}

process BARRNAP {
    conda 'barrnap'
    input:
    output:
    script:
    """
    barrnap "$id.fna" \
        --threads $cores \
        --outseq "$output/barrnap/${id}_16S.fna"
    """
}

process DBCAN {
    conda 'dbcan'
    input:
    output:
        path "data"
    script:
    """
    run_dbcan "$id.fna" prok \
        --out_dir "$output/dbcan/${id}" -c cluster \
        --cgc_substrate \
        --pul ~/dat/db/dbcan/PUL.faa \
        --db_dir ~/dat/db/dbcan \
        --use_signalP=TRUE \
        --signalP_path /zfshome/sukem066/software/signalp-4.1/signalp \
        --hmm_cpu $cores \
        --dia_cpu $cores \
        --tf_cpu $cores \
        --stp_cpu $cores
    """
}

process KOFAMSCAN {
    conda 'kofam'
    input:
    output:
    script:
    """
    exec_annotation \
        --cpu $cores -f mapper -p ~/dat/db/kofam/profiles -k ~/dat/db/kofam/ko_list -o $output/kofam/$id.txt "$id.faa"
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

    eggnog_db = params.eggnog_db ? file(params.eggnog_db) : EGGNOG_DB()
    EGGNOG(samples, eggnog_db)

    bakta_db = params.bakta_db ? file(params.bakta_db) : BAKTA_DB()
    BAKTA(samples, bakta_db)

}