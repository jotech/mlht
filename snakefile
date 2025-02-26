configfile: "config.yaml"

import glob
import os


path = config['Input']['fasta']
inpfile = glob.glob(f"{path}/*fna")
print(inpfile)


SAMPLE = []
for file_path in inpfile:
    file_name = os.path.basename(file_path) 
    name_without_extension = os.path.splitext(file_name)[0] 
    SAMPLE.append(name_without_extension)

print(SAMPLE)  

# SAMPLES = 'bacSub' 
rule all:
    input:
        expand("outdir/{sample}/prodigal/{sample}.faa", sample=SAMPLE),
        expand("outdir/{sample}/prodigal/{sample}.ffn", sample=SAMPLE),
        expand("outdir/{sample}/eggnog/{sample}.emapper.annotations", sample=SAMPLE),
        expand("outdir/{sample}/bakta/", sample=SAMPLE),
        expand("outdir/{sample}/barrnap/{sample}_16S.fna", sample=SAMPLE),
        expand("outdir/{sample}/kofamscan/{sample}.txt", sample=SAMPLE),
        expand("outdir/{sample}/abricate/{sample}_vfdb.tbl", sample=SAMPLE),
        expand("outdir/{sample}/abricate/{sample}_resfinder.tbl", sample=SAMPLE),
        expand("outdir/{sample}/platon", sample=SAMPLE),
        #expand("outdir/{sample}/platon", sample=SAMPLE),
        expand("outdir/{sample}/antismash", sample=SAMPLE),


include: "rules/prediction.smk"



# configfile: "config.yaml"

# import glob,os
# import pandas

# path = config['Input']['fasta']
# inpfile = glob.glob(f"{path}/*fna")
# # print(inpfile)


# SAMPLE = []


# for file_path in inpfile:
#     file_name = os.path.basename(file_path) 
#     name_without_extension = os.path.splitext(file_name)[0] 
#     SAMPLE.append(name_without_extension) 

# print(SAMPLE)  



# rule all:
#     input:
#         expand("outdir/{sample}/{sample}.faa", sample=SAMPLE),
#         #expand("outdir/{{sample}}/{{sample}}.ffn", sample=SAMPLE)

# include: "rules/prediction.smk"


# rule all:
#     input:
#         "outdir/BacSub.faa",
#         "outdir/BacSub.ffn",
#         "outdir/eggnog/BacSub.emapper.annotations",
#         "outdir/bakta_BacSub/",        
#         "outdir/barrnap/BacSub_16S.fna",
#         "outdir/kofamscan/BacSub.txt",
#         "outdir/abricate/BacSub_vfdb.tbl",
#         "outdir/abricate/BacSub_resfinder.tbl",
#         "outdir/platon",
#         "outdir/antismash",
#         # "outdir/gutsmash" 





# configfile: "config.yaml"

# rule all:
#     input:
#         "outdir/BacSub.faa",
#         "outdir/BacSub.ffn",
#         "outdir/eggnog/BacSub.emapper.annotations",
#         "outdir/bakta_BacSub/",        
#         "outdir/barrnap/BacSub_16S.fna",
#         "outdir/kofamscan/BacSub.txt",
#         "outdir/abricate/BacSub_vfdb.tbl",
#         "outdir/abricate/BacSub_resfinder.tbl",
#         "outdir/platon",
#         "outdir/antismash",
#        # "outdir/gutsmash" 

# rule unzip_fasta:
#     conda:
#         "envs/mlhp.yaml"  
#     input:
#         fasta= config['Input']['fasta']
#     output:
#         fna="intdir/BacSub.fna"
#     shell:
#         """
#         if [[ "{input.fasta}" == *.gz ]]; then
#             gunzip -c {input.fasta} > {output.fna}
#         else
#             cp {input.fasta} {output.fna}
#         fi
#         """

# rule prodigal_gene_calling:
#     conda:
#         "envs/mlhp.yaml"  
#     input:
#         fasta="intdir/BacSub.fna"
#     output:
#         faa="outdir/BacSub.faa",
#         ffn="outdir/BacSub.ffn"
#     shell:
#         """
#         prodigal -i {input.fasta} -o /dev/null -a {output.faa}
#         prodigal -i {input.fasta} -o /dev/null -d {output.ffn}
#         """

# rule eggnog:
#     conda:
#         "envs/mlhp.yaml"  
#     input:
#         faa="outdir/BacSub.faa"
#     output:
#         annotations="outdir/eggnog/BacSub.emapper.annotations"
#     params:
#         id="BacSub",
#         outdir="outdir/eggnog/",
#         db_dir="/veodata/03/sujox/mhlp/snakescript/inputs/eggnog/eggnog-mapper/data/",
#         cores=32
#     shell:
#         """
#         emapper.py -i {input.faa} -o {params.id} --output_dir {params.outdir} --cpu {params.cores} --data_dir {params.db_dir} --override
#         """

# rule bakta:
#     conda:
#         "envs/mlhp.yaml"  
#     input:
#         fasta="intdir/BacSub.fna"
#     output:
#         outdir = "outdir/bakta_BacSub/"
#     params:
#         dbdir="/veodata/03/sujox/mhlp/snakescript/inputs/bakta/manual_db/db",
#         cores=32,
#         id="BacSub"
#     shell:
#         """
#         bakta --threads {params.cores} --prefix {params.id} --output {output.outdir} --db {params.dbdir} {input.fasta}
#         """

# rule barrnap:
#     conda:
#         "envs/mlhp.yaml"  
#     input:
#         fasta="intdir/BacSub.fna"
#     output:
#         outfile="outdir/barrnap/BacSub_16S.fna"
#     params:
#         cores=32
#     shell:
#         """
#         barrnap --threads {params.cores} {input.fasta} > {output.outfile}
#         """

# rule kofamscan:
#     conda:
#         "envs/mlhp.yaml"  
#     input:
#         faa="outdir/BacSub.faa"
#     output:
#         outdir="outdir/kofamscan/BacSub.txt"
#     params:
#         profiles="/veodata/03/sujox/mhlp/snakescript/inputs/kofam_scan/db/profiles/",
#         ko_list="/veodata/03/sujox/mhlp/snakescript/inputs/kofam_scan/db/ko_list",
#         cores=32
#     shell:
#         """
#         exec_annotation --cpu {params.cores} -f mapper -p {params.profiles} -k {params.ko_list} -o {output.outdir} {input.faa}
#         """

# rule abricate:
#     conda:
#         "envs/mlhp.yaml"  
#     input:
#         ffn="outdir/BacSub.ffn"
#     output:
#         vfdb="outdir/abricate/BacSub_vfdb.tbl",
#         resfinder="outdir/abricate/BacSub_resfinder.tbl"
#     shell:
#         """
#         abricate --db vfdb {input.ffn} > {output.vfdb}
#         abricate --db resfinder {input.ffn} > {output.resfinder}
#         """
# rule platon:
#     conda:
#         "envs/mlhp.yaml"  
#     input:
#         faa ="intdir/BacSub.fna"
#     output:
#         dbdir = "/veodata/03/sujox/mhlp/snakescript/inputs/platon/db",
#         out ="outdir/platon"
#     params:
#         cores = 32
#     shell:
#         """
#         platon --db {output.dbdir} --threads {params.cores} --output {output.out} {input.faa}
#         """

# # rule gutsmash:
# # rule gRoden:
# # rule antismash:
# #     input:
# #         fasta = config['Input']['fasta']
# #     params:
# #         cores = 32,
# #         id = "BacSub"
# #     output:
# #         out = "outdir/antismash/BacSub"
# #     threads: 
# #         32
# #     shell:
# #         """
# #         antismash --cb-general --cb-knownclusters --cb-subclusters --asf --pfam2go --cc-mibig \
# #         --genefinding-tool prodigal -c {threads} \
# #         --output-dir {output} --output-basename {params.id} {input.fasta}
# #         """
# rule antismash:
#     conda:
#         "envs/mlhp2.yaml"  
#     input:
#         fasta = config['Input']['fasta']
#     params:
#         cores = 32,
#         id = "BacSub"
#     output:
#         outdir = directory("outdir/antismash")  # Treat the directory as the output
#     threads:
#         32
#     shell:
#         """
#         antismash --cb-general --cb-knownclusters --cb-subclusters --asf --pfam2go --cc-mibig \
#         --genefinding-tool prodigal -c {threads} \
#         --output-dir {output.outdir} --output-basename {params.id} {input.fasta}
#         """

# rule gutsmash:
#     conda:
#         "envs/mlhp_gut.yaml"   # conda env for gutmash
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


# # rule antismash:
# #     input:
# #         fasta = config['Input']['fasta']
# #     params:
# #         cores = 32,
# #         id = "BacSub"
# #     output:
# #         out = "outdir/antismash/BacSub"
# #     shell:
# #         """
# #         antismash --cb-general --cb-knownclusters --cb-subclusters --asf --pfam2go --cc-mibig --genefinding-tool prodigal -c {params.cores} --output-dir {output.out} --output-basename {params.id} {input.fasta}
# #         """
# # rule dbcan