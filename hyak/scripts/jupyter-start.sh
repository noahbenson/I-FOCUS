#! /bin/bash

IMAGE="${IMAGE:-docker://quay.io/jupyter/datascience-notebook:2024-10-02}"
TUNNELS_DIR="${TUNNELS_DIR:-${HOME}/.tunnels}"
TUNNEL_NAME="${TUNNEL_NAME:-singularity-jupyter}"
JUPYTER_ENABLE_LAB="${JUPYTER_ENABLE_LAB:-yes}"
SOCKET_NAME="${1:-default}"

function die {
    echo "ERROR:" "$@" 1>&2
    exit 1
}

[ -n "$SLURM_JOB_ID" ] \
    || die "No SLURM_JOB_ID set."

TUNNEL_DIR="${TUNNELS_DIR}/${TUNNEL_NAME}"
mkdir -p "${TUNNEL_DIR}" \
    || die "Could not make tunnel directory: ${TUNNEL_DIR}"

SOCKET_FILE="${TUNNEL_DIR}/${SOCKET_NAME}.sock"
JOB_FILE="${TUNNEL_DIR}/jobdata.sh"
RUN_SCRIPT="${TUNNEL_DIR}/run.sh"

# Write out the job data:
cat >"$JOB_FILE" <<EOF
SLURM_JOB_ID=${SLURM_JOB_ID}
SLURMD_NODENAME=${SLURMD_NODENAME}
EOF

# Write out the command for the server:
cat >"$RUN_SCRIPT" <<EOF
#! /bin/bash
singularity exec \
    --env "JUPYTER_ENABLE_LAB=${JUPYTER_ENABLE_LAB}" \
    --home "${HOME}" \
    --bind "${HOME}/.local:/home/jovyan/.local" \
    ${IMAGE} \
    jupyter lab --no-browser --sock "${SOCKET_FILE}" \
        --ip='*' --NotebookApp.token='' --NotebookApp.password=''
RVAL="\$?"

# Cleanup:
[ -e "${SOCKET_FILE}" ] && rm "${SOCKET_FILE}"

echo "Jupyter exited with status \$RVAL."
exit "\$RVAL"
EOF
chmod 700 "$RUN_SCRIPT"

# Wait for the socket file to appear...
while :
do [ -e "${SOCKET_FILE}" ] && break
   sleep 2
done
echo "Tunnel connected."

while :
do if ! [ -e "${SOCKET_FILE}" ]
   then exit 0
   else sleep 5
   fi
done
