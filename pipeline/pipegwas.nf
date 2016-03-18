#!/usr/bin/env nextflow

/*
 * Author       : Rob Clucas
 * Description  : Nextflow pipeline for Wits GWAS.
 */

// Defines the name of the docker container to run the pipeline through.
params.dock_container   = 'witsgwas'

// Defines the name of the mountpoint of the data directories in the docker
// container. This is so that any scripts which run in the container and 
// might need this info can run succesfully, and the user can specify the 
// directory to each of the scripts.
// Note: The mountpoint is mounted in the container from the root directory,
//       so specifying 'data' as the mount point mounts the data at /data in
//       the container.
params.dock_data_mpoint = 'data'

// Defines the directory where the plink 1.07 input files are. 
// Note: This must be a relative path.
params.plink_inputpath  = "gwasdata/plink"

// Defines the names of the plink files in the plink directory (.fam,.bed,.bed)
// Note: This must be without the extension (so if A.fam, A.bed then use 'A').
params.plink_fname      = 'raw-GWA-data'

// Convert the relative data path to an absolute one
plink_data_path = Channel.fromPath(params.plink_inputpath, type : 'dir')

/* Process to check for duplicates. The process mounts the plink data to the 
 * docker container and then runs plink 1.07 through the docker container.
 * 
 * Inputs:
 * - data_path  : The path to the plink data
 * - filename   : The name of the plink input files wo extension
 * - container  : The name of the docker container to use
 * - mountpoint : The mountpoint of the data in the container
 */
process checkDuplicateMarkers { 
  input:
  val data_path  from plink_data_path
  val filename   from params.plink_fname
  val container  from params.dock_container
  val mountpoint from params.dock_data_mpoint

  """
  docker run -v ${data_path}:/$mountpoint -w /$mountpoint $container   \
    plink1 --noweb --bfile $filename --out results
  """
}
