#!/bin/bash

[ $# -ne 4 ] && { echo "Usage: $0 id fasta output cores"; exit 1; }

id=$1
fasta=$2
output=$3
cores=$4

echo "$0 id=$id fasta=$fasta output=$output cores=$cores"

mkdir -p $output
cd $TMPDIR

# conda
eval "$(conda shell.bash hook)"

# unzip
if [[ $fasta == *.gz ]]; then
    gunzip -c $fasta > "$id.fna"
else
    cp $fasta "$id.fna"
fi



# gene calling (prodigal)
~/software/prodigal/prodigal -i $fasta -o /dev/null -a "$id.faa"
~/software/prodigal/prodigal -i $fasta -o /dev/null -d "$id.ffn"

# eggnog
if ! [[ -s "$output/eggnog/$id.emapper.annotations" ]]; then 
    conda activate eggnog
    mkdir -p $output/eggnog
    emapper.py -i "$id.faa" -o "$id" --output_dir $output/eggnog --cpu $cores --data_dir $WORK/dat/db/eggnog/ --override
    conda deactivate
fi

# bakta
if ! [[ -s "$output/bakta/$id/$id.txt" ]]; then 
    conda activate bakta
    mkdir -p $output/bakta
    bakta --threads $cores --prefix "$id" --output "$output/bakta/$id" --db /work_beegfs/sukem066/dat/db/bakta/db "$id.fna"
    conda deactivate
fi

# codon usage bias (gRodon)
if ! [[ -s "$output/grodon/$id.csv" ]]; then 
    mkdir -p $output/grodon
    Rscript ~/uni/life_history/src/codon.R -i $output/bakta/$id/$id.ffn -o $output/grodon
fi

# barrnap
if ! [[ -s "$output/barrnap/${id}_16S.fna" ]]; then 
    conda activate barrnap
    mkdir -p $output/barrnap
    barrnap "$id.fna" --threads $cores --outseq "$output/barrnap/${id}_16S.fna"
    conda deactivate
fi

# dbcan
if ! [[ -s "$output/dbcan/$id/overview.txt" ]]; then 
    conda activate dbcan
    mkdir -p $output/dbcan
    run_dbcan "$id.fna" prok --out_dir "$output/dbcan/${id}" -c cluster --cgc_substrate --pul ~/dat/db/dbcan/PUL.faa --db_dir ~/dat/db/dbcan --use_signalP=TRUE --signalP_path /zfshome/sukem066/software/signalp-4.1/signalp --hmm_cpu $cores --dia_cpu $cores --tf_cpu $cores --stp_cpu $cores
    conda deactivate
fi

# kofamscan
if ! [[ -s "$output/kofam/$id.txt" ]]; then 
    conda activate kofam
    mkdir -p $output/kofam
    exec_annotation --cpu $cores -f mapper -p ~/dat/db/kofam/profiles -k ~/dat/db/kofam/ko_list -o $output/kofam/$id.txt "$id.faa"
    conda deactivate
fi

# abricate
if ! [[ -s "$output/abricate/${id}_vfdb.tbl" ]]; then 
    conda activate abricate
    mkdir -p $output/abricate
    abricate --db vfdb "$id.ffn" > $output/abricate/${id}_vfdb.tbl
    abricate --db resfinder "$id.ffn$" > $output/abricate/${id}_resfinder.tbl
    conda deactivate
fi

# antismash
if ! [[ -s "$output/antismash/$id/index.html" ]]; then 
    conda activate antismash
    mkdir -p $output/antismash
    antismash --cb-general --cb-knownclusters --cb-subclusters --asf --pfam2go --cc-mibig --genefinding-tool prodigal -c $cores --output-dir $output/antismash/$id --output-basename $id $fasta
    conda deactivate
fi

# gutsmash
if ! [[ -s "$output/gutsmash/$id/index.html" ]]; then 
    conda activate gutsmash
    mkdir -p $output/gutsmash
    ~/software/gutsmash/run_gutsmash.py --cpus $cores --genefinding-tool prodigal --cb-knownclusters --cb-general --enable-genefunctions --output-dir $output/gutsmash/$id $fasta
    conda deactivate
fi

# platon (plasmids)
if ! [[ -s "$output/platon/$id.log" ]]; then 
    conda activate platon
    mkdir -p $output/platon
    platon --db ~/dat/db/platon/db --threads $cores --output $output/platon "$id.fna"
fi
