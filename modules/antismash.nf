process ANTISMASH_DB {
    conda 'antismash==6.1.1'
    container 'antismash/standalone-lite:7.1.0'

    publishDir "dbs/antismash", mode: 'copy'

    output:
        path "antismash"
    script:
    """
    mkdir -p antismash
    download-antismash-databases --database-dir antismash
    """

}
process ANTISMASH {
    tag "$id"

    conda 'antismash==6.1.1'
    container 'antismash/standalone-lite:7.1.0'

    publishDir "${params.output_dir}/", mode: 'copy'

    input:
        tuple val(id), path(fasta)
        path db
    output:
        path "antismash"
    script:
    """
    mkdir -p antismash/$id
    antismash \
        --databases $db \
        --cb-general \
        --cb-knownclusters \
        --cb-subclusters \
        --asf \
        --pfam2go \
        --cc-mibig \
        --genefinding-tool prodigal -c $task.cpus \
        --output-dir antismash/$id \
        --output-basename $id $fasta
    """
}