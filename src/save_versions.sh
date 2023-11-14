#!/bin/bash


[ $# -ne 2 ] && { echo "Usage: $0 output module"; exit 1; }

output=$1
module=$2

if [ ! -d "$output/$module" ]; then
    echo "Output folder $module not found in folder $output"
    exit 1
fi

# conda
eval "$(conda shell.bash hook)"
if ! { conda env list | grep $module; } >/dev/null 2>&1; then
    echo "Conda environment for $module not found"
    exit 1
fi
conda activate $module
conda env export > $output/$module/$module.yml
conda deactivate

if [[ "$module" == "abricate" ]]; then
    conda activate abricate
    abricate --version >> $output/version
    abricate --list >> $output/version
    conda deactivate
elif [[ "$module" == "eggnog" ]]; then
    conda activate eggnog
    emapper.py --data_dir $WORK/dat/db/eggnog --version >> $output/version
    conda deactivate
elif [[ "$module" == "bakta" ]]; then
    conda activate bakta
    bakta --version >> $output/version
    #bakta_db list >> $output/version
    cat /work_beegfs/sukem066/dat/db/bakta/db/version.json >> $output/version
    conda deactivate
elif [[ "$module" == "grodon" ]]; then

fi

