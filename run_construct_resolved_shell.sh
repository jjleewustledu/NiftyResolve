#! /bin/bash

# resources #################################



# commands for nodes ########################

# manually, from login node:
# singularity pull docker://jjleewustledu/niftymcr-image:construct_resolved

unset CONDA_DEFAULT_ENV
#DT=$(date +"%Y%m%d%H%M%S")
module unload singularity-20181030
module load singularity-3.0.2

singularity shell \
    --bind $SINGULARITY_HOME:/SubjectsDir \
    --bind /export:/export \
    $SINGULARITY_HOME/niftymcr-image_construct_resolved.sif 


