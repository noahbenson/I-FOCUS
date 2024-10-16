#! /bin/bash

# Utility stuff.
function die {
    echo "ERROR:" "$@" 1>&2
    exit 1
}

# Configuration (via environment variables):
IMAGE="${IMAGE:-docker://quay.io/jupyter/datascience-notebook:2024-10-02}"
TUNNELS_DIR="${TUNNELS_DIR:-${HOME}/.tunnels}"
TUNNEL_NAME="${TUNNEL_NAME:-singularity-jupyter}"
SOCKET_NAME="default"
TUNNEL_DIR="${TUNNELS_DIR}/${TUNNEL_NAME}"
SOCKET_FILE="${TUNNEL_DIR}/${SOCKET_NAME}.sock"
LOGIN_FILE="${TUNNEL_DIR}/${SOCKET_NAME}.login.sock"
JOB_FILE="${TUNNEL_DIR}/jobdata.sh"
RUN_SCRIPT="${TUNNEL_DIR}/run.sh"

# Export the configuration.
export IMAGE
export TUNNELS_DIR
export TUNNEL_NAME
export JUPYTER_ENABLE_LAB
export SOCKET_NAME
export TUNNEL_DIR
export SOCKET_FILE
export LOGIN_FILE
export JOB_FILE
export RUN_SCRIPT

# Wait for the file to appear...
while :
do [ -e "${RUN_SCRIPT}" ] && [ -e "${JOB_FILE}" ] && break
   sleep 2
done

# Load the job data.
source "${JOB_FILE}"

# Run the script on the node...
ssh -L "${LOGIN_FILE}:${SOCKET_FILE}" \
    "${SLURMD_NODENAME}" "$RUN_SCRIPT"

read -n1 -p "Press enter to exit." KEYPRESS
