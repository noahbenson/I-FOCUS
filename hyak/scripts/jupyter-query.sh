#! /bin/bash

TUNNELS_DIR="${TUNNELS_DIR:-${HOME}/.tunnels}"
TUNNEL_NAME="${TUNNEL_NAME:-singularity-jupyter}"
JUPYTER_ENABLE_LAB="${JUPYTER_ENABLE_LAB:-yes}"
SOCKET_NAME="${1:-default}"
TUNNEL_DIR="${TUNNELS_DIR}/${TUNNEL_NAME}"

SOCKET_FILE="${TUNNEL_DIR}/${SOCKET_NAME}.sock"
JOB_FILE="${TUNNEL_DIR}/jobdata.sh"
RUN_SCRIPT="${TUNNEL_DIR}/run.sh"

[ -d "${JOB_FILE}" ] || exit 1

source "${JOB_FILE}"

# Make sure this is still our job...
LNS=$(squeue -j "${SLURM_JOB_ID}" -u "${USER}" 2>/dev/null | wc -l)
[ "$LNS" -eq 2 ] || exit 1

[ -z "$1" ] && exit 0
[ "$1" != "print" ] && die "invalid command: $1"

cat <<EOF
TUNNELS_DIR="${TUNNELS_DIR:-${HOME}/.tunnels}"
TUNNEL_NAME="${TUNNEL_NAME:-singularity-jupyter}"
JUPYTER_ENABLE_LAB="${JUPYTER_ENABLE_LAB:-yes}"
SOCKET_NAME="${1:-default}"
TUNNEL_DIR="${TUNNELS_DIR}/${TUNNEL_NAME}"
SOCKET_FILE="${TUNNEL_DIR}/${SOCKET_NAME}.sock"
JOB_FILE="${TUNNEL_DIR}/jobdata.sh"
RUN_SCRIPT="${TUNNEL_DIR}/run.sh"
EOF

exit 0
