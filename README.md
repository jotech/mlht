This pipeline identifies microbial life history traits.

# Getting started
## Prerequisites
Nextflow is the main prerequisite to run this pipeline, to install it please follow the [installation guide](https://www.nextflow.io/docs/latest/getstarted.html). Apart from that, conda and a container provider such as docker or podman is required.

## Installation and Usage
1. Clone the repo
   ```sh
   git clone https://github.com/jotech/mlht.git
   cd mlht
   ```
2. Run the pipeline
  ```sh
  nextflow run main.nf --samples samples.csv
  ```
