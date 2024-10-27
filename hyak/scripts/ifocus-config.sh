#! /bin/bash
################################################################################
# This script is meant to be sourced. It contains variable definitions that are
# not exported to the environment, so running it as a script has no effect.


# Configuration ################################################################

# What directory is this script running from?
# This line typically needs to be duplicated in each I-FOCUS script because it's
# a reliable way to figure out where the script is being run from and thus the
# path of the other scripts. It is included here for reference:
#  SCRIPT_PATH="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# The directory we use to store local data like unix sockets and job data.
IFOCUS_PATH_DEFAULT="${HOME}/.i-focus"

# If SLURM memory isn't specified, we go with 12G.
SLURM_MEM_PER_NODE_DEFAULT=12G

# If the number of nodes, tasks, or cpus isn't specified, request 4 cpus for 1
# node and 1 task.
SLURM_NNODES_DEFAULT=""
SLURM_NTASKS_PER_NODE_DEFAULT=""
SLURM_NTASKS_DEFAULT=1
SLURM_CPUS_PER_TASK_DEFAULT=4

# If the SLURM_ACCOUNT is empty, we auto-detect an account using the
# guess-account.sh script. This is desired behavior, so we leave the
# default blank.
SLURM_ACCOUNT_DEFAULT=""

# We also want to use a sensible choice for partition.
SLURM_PARTITION_DEFAULT=ckpt-all
