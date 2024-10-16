#! /bin/bash

BINDIR="${HOME}/.hyak-jupyter/bin"

# Get arguments.
eval "$(${BINDIR}/hyak-jupyter-args.sh "$@")"

[ -r "${JOB_FILE}" ] || exit 1
source "${JOB_FILE}"

# Make sure this is still our job...
LNS=$(squeue -j "${SLURM_JOB_ID}" -u "${USER}" 2>/dev/null | wc -l)
[ "$LNS" -eq 2 ] || exit 1

# Tests pass so it's still running.
exit 0
