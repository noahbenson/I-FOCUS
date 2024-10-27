#! /bin/bash
################################################################################
# This script checks wither hyak-jupyter is already running.
# The return value is 0 (true) if jupyter was already running; the return value
# is 1 (false) if jupyter is not running.


# Configuration ################################################################

# What directory is this script in?
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Initialize the Jupyter data from the script directory.
eval "$(${SCRIPT_DIR}/jupyter-init.sh "$@")"


# Check the Job Directory ######################################################

# First, if there is no status file, then no Jupyter job is running.
ifocus_isrunning || exit 1

# Make sure this is still our job by reading in the job info then
# checking squeue for the job ID.
[ -r "${IFOCUS_JOB_FILE}" ] || exit 1
source "${IFOCUS_JOB_FILE}"
[ -n "${SLURM_JOB_ID}" ] || exit 1
LNS=$(squeue -j "${SLURM_JOB_ID}" -u "${USER}" 2>/dev/null | wc -l)
[ "$LNS" -eq 2 ] || exit 1

# The tests pass so it's still running.
echo "SLURM_JOB_ID=${SLURM_JOB_ID}"
exit 0
