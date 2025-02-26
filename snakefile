configfile: "config.yaml"
import glob
import os

path = config['Input']['fasta']
inpfile = glob.glob(f"{path}/*fna")

SAMPLE = []
for file_path in inpfile:
    file_name = os.path.basename(file_path) 
    name_without_extension = os.path.splitext(file_name)[0] 
    SAMPLE.append(name_without_extension)

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

