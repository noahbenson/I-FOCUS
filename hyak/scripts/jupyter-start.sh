#! /bin/bash

# The one variable we set manually.
BINDIR="${HOME}/.hyak-jupyter/bin"

# Arguments should have been passed via the environment, so no need to parse
# them all here.

function die {
    echo "ERROR:" "$@" 1>&2
    exit 1
}

[ -n "$SLURM_JOB_ID" ] \
    || die "No SLURM_JOB_ID set."

mkdir -p "${TUNNEL_DIR}" \
    || die "Could not make tunnel directory: ${TUNNEL_DIR}"

# Write out the job data:
cat >"$JOB_FILE" <<EOF
SLURM_JOB_ID=${SLURM_JOB_ID}
SLURMD_NODENAME=${SLURMD_NODENAME}
EOF

# Write out the command for the server:
if [ "$JUPYTER_ENABLE_LAB" = "no" ]
then LABCMD="notebook"
else LABCMD="lab"
fi
cat >"$RUN_SCRIPT" <<EOF
#! /bin/bash
singularity exec \
    --env "JUPYTER_ENABLE_LAB=${JUPYTER_ENABLE_LAB}" \
    --home "${HOME}" \
    --bind "${HOME}/.local:/home/jovyan/.local" \
    ${IMAGE} \
    jupyter ${LABCMD} --no-browser --sock "${SOCKET_FILE}" \
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
echo ""
echo "Tunnel connected."
echo ""
echo "--------------------------------------------------------------------------------"
echo "To connect to Jupyter, point your browser to localhost:7777"

while :
do if ! [ -e "${SOCKET_FILE}" ]
   then exit 0
   else sleep 5
   fi
done
