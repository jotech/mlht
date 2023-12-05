
<br />
<div align="center">
  <a href="https://github.com/jotech/mlht">
    <img src="assets/bitmap.png" alt="Logo" height="200">
  </a>

  <h3 align="center">Microbial Life History Traits</h3>

  <p align="center">
    A new pipeline to identify microbial life history traits!
    <br />
    <a href="https://github.com/jotech/mlht/issues">Report Bug</a>
    ·
    <a href="https://github.com/jotech/mlht/issues">Request Feature</a>
    ·
    <a href="https://github.com/jotech/mlht">Paper</a>
  </p>
  <p>
    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Logo_Kiel_University.svg/1200px-Logo_Kiel_University.svg.png" alt="Logo" height="50">
    <img src="https://intake.ikmb.uni-kiel.de/static/images/ikmb_logo.png" alt="Logo" height="50">
  </p>
</div>


<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#usage">Usage</a></li>
        <li><a href="#parameters">Parameters</a></li>
        <li><a href="#further-recommendations">Further recomendations</a></li>
      </ul>
    </li>
    <li><a href="#citation">Citation</a></li>
  </ol>
</details>

# About the project
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

## Further recommendations
It is often useful to cache the conda environment to avoid downloading the same packages multiple times. To do so, you can set the following environment variable:
```sh
export NXF_CONDA_CACHEDIR=/path/to/conda/environment/cache/directory/
```

# Citation
If you use this pipeline please cite the following paper:

Zimmermann, J., Mendoza-Mejía N., et al. (2024). A new pipeline to identify microbial life history traits.

**The paper is not yet published, please contact the authors of this repo for further information.**