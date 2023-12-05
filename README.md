
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
This pipeline requires the bellow software to be installed, please click on the icons for the installation instructions.
 1. [![Nextflow][Nextflow]][Nextflow-url]
 2. [![Miniconda][Miniconda]][Miniconda-url]
 3. [![Docker]][Docker-url], [![Podman]][Podman-url] or [![Singularity]][Singularity-url]


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

<br />
<div align="center">
  <a href="https://www.uni-kiel.de/de/">
    <img src="assets/cau-logo.png" alt="CAU" height="50">
  </a>
  <a href="https://www.ikmb.uni-kiel.de/">
    <img src="assets/ikmb_logo.png" alt="IKMB" height="50">
  </a>
</div>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[Nextflow]: https://img.shields.io/badge/Nextflow-0dc09d
[Nextflow-url]: https://www.nextflow.io/docs/latest/getstarted.html
[Anaconda]: https://img.shields.io/badge/Anaconda-43b02a?logo=anaconda&logoColor=white
[Anaconda-url]: https://docs.conda.io/en/latest/miniconda.html
[Miniconda]: https://img.shields.io/badge/Miniconda-43b02a?logo=anaconda&logoColor=white
[Miniconda-url]: https://docs.conda.io/en/latest/miniconda.html
[Docker]: https://img.shields.io/badge/Docker-2496ed?logo=docker&logoColor=white
[Docker-url]: https://docs.docker.com/get-docker/
[Podman]: https://img.shields.io/badge/Podman-892CA0?logo=podman&logoColor=white
[Podman-url]: https://podman.io/getting-started/installation
[Singularity]: https://img.shields.io/badge/Singularity%20%28Apptiner%29-2496ed
[Singularity-url]: https://apptainer.org/docs/user/main/quick_start.html
