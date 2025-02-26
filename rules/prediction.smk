configfile: "config.yaml"

rule unzip_fasta:
    #conda: config['Snakefile'] + config['CondaEnv']['unzip']
    input:
        fasta= config['Input']['fasta'] + "{sample}.fna"  # Make sure the file path is correct
    output:
        fna="intdir/{sample}/{sample}.fna"
    shell:
        """
        echo "Input fasta file: {input.fasta}"  # Print the input file path
        mkdir -p intdir/{wildcards.sample}
        if [[ "{input.fasta}" == *.gz ]]; then
            gunzip -c {input.fasta} > {output.fna}
        else
            cp {input.fasta} {output.fna}
        fi
        """

rule prodigal_gene_calling:
    conda: config['Snakefile'] +config['CondaEnv']['prodigal']
    input:
        fasta="intdir/{sample}/{sample}.fna"
    output:
        faa="outdir/{sample}/prodigal/{sample}.faa",
        ffn="outdir/{sample}/prodigal/{sample}.ffn"
    shell:
        """
        mkdir -p outdir/{wildcards.sample}
        prodigal -i {input.fasta} -o /dev/null -a {output.faa}
        prodigal -i {input.fasta} -o /dev/null -d {output.ffn}
        """


rule eggnog:
    conda: config['Snakefile'] + config['CondaEnv']['eggnog']
    input:
        faa="outdir/{sample}/prodigal/{sample}.faa"
    output:
        annotations="outdir/{sample}/eggnog/{sample}.emapper.annotations"
    params:
        id="BacSub",
        outdir="outdir/{sample}/eggnog/",
        db_dir="/veodata/03/sujox/mhlp/snakescript/inputs/eggnog/eggnog-mapper/data/",
        cores=32
    shell:
        """
        emapper.py -i {input.faa} -o {params.id} --output_dir {params.outdir} --cpu {params.cores} --data_dir {params.db_dir} --override
        """

rule bakta:
    conda: config['Snakefile'] + config['CondaEnv']['bakta']
    input:
        fasta="intdir/{sample}/{sample}.fna"
    output:
        outdir = "outdir/{sample}/bakta/"
    params:
        dbdir="/veodata/03/sujox/mhlp/snakescript/inputs/bakta/manual_db/db",
        cores=32,
        id="BacSub"
    shell:
        """
        bakta --threads {params.cores} --prefix {params.id} --output {output.outdir} --db {params.dbdir} {input.fasta}
        """

rule barrnap:
    conda: config['Snakefile'] + config['CondaEnv']['barrnap']  
    input:
        fasta="intdir/{sample}/{sample}.fna"
    output:
        outfile="outdir/{sample}/barrnap/{sample}_16S.fna"
    params:
        cores=32
    shell:
        """
        barrnap --threads {params.cores} {input.fasta} > {output.outfile}
        """

rule kofamanscan:
    conda: config['Snakefile'] + config['CondaEnv']['Kofamanscan']  
    input:
        faa="intdir/{sample}/{sample}.fna"
    output:
        outdir="outdir/{sample}/kofamscan/{sample}.txt"
    params:
        profiles="/veodata/03/sujox/mhlp/snakescript/inputs/kofam_scan/db/profiles/",
        ko_list="/veodata/03/sujox/mhlp/snakescript/inputs/kofam_scan/db/ko_list",
        cores=32
    shell:
        """
        exec_annotation --cpu {params.cores} -f mapper -p {params.profiles} -k {params.ko_list} -o {output.outdir} {input.faa}
        """

rule abricate:
    conda: config['Snakefile'] + config['CondaEnv']['abricate']
    input:
        ffn="outdir/{sample}/prodigal/{sample}.ffn"
    output:
        vfdb="outdir/{sample}/abricate/{sample}_vfdb.tbl",
        resfinder="outdir/{sample}/abricate/{sample}_resfinder.tbl"
    shell:
        """
        abricate --db vfdb {input.ffn} > {output.vfdb}
        abricate --db resfinder {input.ffn} > {output.resfinder}
        """

rule platon:
    conda: config['Snakefile'] + config['CondaEnv']['platon']
    input:
        faa ="intdir/{sample}/{sample}.fna"
    output:
        out ="outdir/{sample}/platon"
    params:
        dbdir = "/veodata/03/sujox/mhlp/snakescript/inputs/platon/db",
        cores = 32
    shell:
        """
        platon --db {params.dbdir} --threads {params.cores} --output {output.out} {input.faa}
        """

# Antismash Rule (Fixed Directory Output)
rule antismash:
    conda: config['Snakefile'] + config['CondaEnv']['antismash']  
    input:
        fasta = "intdir/{sample}/{sample}.fna"
    params:
        cores = 32,
        id = "BacSub"
    output:
        outdir = directory("outdir/{sample}/antismash")  
    threads:
        32
    shell:
        """
        download-antismash-databases && \
        antismash --cb-general --cb-knownclusters --cb-subclusters --asf --pfam2go --cc-mibig \
        --genefinding-tool prodigal -c {threads} \
        --output-dir {output.outdir} --output-basename {params.id} {input.fasta}
        """

# # Gutsmash Rule (for future use)
# rule gutsmash:
#     conda:
#         "envs/gutsmash.yaml"   # conda env for gutmash
#     input:
#         fasta = config['Input']['fasta'],
#         py = "/veodata/03/sujox/mhlp/snakescript/inputs/gutsmash/run_gutsmash.py"
#     params:
#         cores = 32,
#         id = "BacSub"
#     output:
#         out = directory("outdir/gutsmash")
#     threads: 
#         32
#     shell:
#         """
#         python {input.py} --cpus {params.cores} --genefinding-tool prodigal --cb-knownclusters --cb-general --enable-genefunctions --output-dir {output.out}/{params.id} {input.fasta}
#         """


