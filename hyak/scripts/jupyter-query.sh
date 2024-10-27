#! /bin/bash
################################################################################
# This script checks wither hyak-jupyter is already running.
# The return value is 0 (true) if jupyter was already running; the return value
# is 1 (false) if jupyter is not running.


# Configuration ################################################################

# What directory is this script in?
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
# Load the configuration from the script for it.
eval "$(${SCRIPT_DIR}/jupyter-config.sh "$@")"


# Check the Job Directory ######################################################

# First, read in the job data.
[ -r "${HYAK_JUPYTER_JOB_FILE}" ] || exit 1
source "${HYAK_JUPYTER_JOB_FILE}"

# If the socket file isn't there, the job is over.
[ -r "${HYAK_JUPYTER_SOCKET_FILE}" ] || exit 1

# Make sure this is still our job by checking squeue.
LNS=$(squeue -j "${SLURM_JOB_ID}" -u "${USER}" 2>/dev/null | wc -l)
[ "$LNS" -eq 2 ] || exit 1

# The tests pass so it's still running.
echo "SLURM_JOB_ID=${SLURM_JOB_ID}"
exit 0
