
<br />
<div align="center">
  <a href="https://github.com/jotech/mlht">
    <img src="https://cdn12.picryl.com/photo/2016/12/31/bacteria-bacterium-neisseria-meningitidis-a4fd60-1024.png" alt="Logo" width="200" height="200">
  </a>

  <h3 align="center">Microbial Life History Traits</h3>

  <p align="center">
    A new pipeline to identify microbial life history traits!
    <br />
    <a href="https://github.com/jotech/mlht/issues">Report Bug</a>
    ·
    <a href="https://github.com/jotech/mlht/issues">Request Feature</a>
  </p>
</div>


# Getting started
## Prerequisites
Nextflow is the main prerequisite to run this pipeline, to install it please follow the [installation guide](https://www.nextflow.io/docs/latest/getstarted.html). Apart from that you will need to install the following tools:
 1. Conda environment: [conda](https://docs.conda.io/en/latest/miniconda.html)
 2. Container provider [docker](https://docs.docker.com/get-docker/), [podman](https://podman.io/getting-started/installation) or [singularity](https://sylabs.io/guides/3.0/user-guide/installation.html)

## Usage
To run this pipeline simply execute the following command. Additional parameters are described below.
   ```sh
   nextflow run jotech/mlht --samples samples.csv
   ```

## Parameters
#### Databases
The first time you run the pipeline it will download the required databases to a folder called `dbs`. However, you can pass the databases as parameters to avoid the download step.
 1. `--bakta_db`
 2. `--eggnog_db`
 3. `--antismash_db`
 4. `--platon_db`

# Citation
If you use this pipeline please cite the following paper:

**The paper is not yet published, please contact the authors of this repo for further information.**