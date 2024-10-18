#! /bin/bash
################################################################################
# Sets up the hyak-jupyter directory and waits for the tunnel to connect.


# Utilities ####################################################################

# A function to print an error then exit with an error code.
function die {
    echo "ERROR:" "$@" 1>&2
    exit 1
}


# Configuration ################################################################

# What directory is this script in?
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Load the configuration from the script for it.
eval "$(${SCRIPT_DIR}/jupyter-config.sh "$@")"


# Sanity Checks ################################################################

# Make sure we're a SLURM job.
[ -n "$SLURM_JOB_ID" ] \
    || die "No SLURM_JOB_ID set."

# Make sure the tunnel directory exists.
mkdir -p "${HYAK_JUPYTER_TUNNEL_DIR}" \
    || die "Could not make tunnel directory: ${HYAK_JUPYTER_TUNNEL_DIR}"

# Write out the job data:
cat >"$HYAK_JUPYTER_JOB_FILE" <<EOF
SLURM_JOB_ID=${SLURM_JOB_ID}
SLURMD_NODENAME=${SLURMD_NODENAME}
EOF

# Write out the command for the server:
if [ "${HYAK_JUPYTER_SUBCMD}" = "lab" ]
then JUPYTER_ENABLE_LAB=yes
else JUPYTER_ENABLE_LAB=no
fi
cat >"${HYAK_JUPYTER_RUN_SCRIPT}" <<EOF
#! /bin/bash
singularity exec \
    --env "JUPYTER_ENABLE_LAB=${JUPYTER_ENABLE_LAB}" \
    --home "${HOME}" \
    --bind "${HOME}/.local:/home/jovyan/.local" \
    ${HYAK_JUPYTER_IMAGE} \
    jupyter ${HYAK_JUPYTER_SUBCMD} \
       --no-browser \
       --sock "${HYAK_JUPYTER_SOCKET_FILE}" \
       --ip='*' --NotebookApp.token='' --NotebookApp.password=''
RVAL="\$?"

# Cleanup:
[ -e "${HYAK_JUPYTER_SOCKET_FILE}" ] && rm "${HYAK_JUPYTER_SOCKET_FILE}"

echo "Jupyter exited with status \$RVAL."
exit "\$RVAL"
EOF
chmod 700 "${HYAK_JUPYTER_RUN_SCRIPT}"

# Wait for the socket file to appear...
echo "Waiting for tunnel to connect..."
echo ""
echo "This may take a few minutes, especially if you have not used the image"
echo "${HYAK_JUPYTER_IMAGE} recently."
echo ""
echo "To check on the tunnel progress, press control + a twice; you can do this"
echo "again to switch back."
while :
do [ -e "${HYAK_JUPYTER_SOCKET_FILE}" ] && break
   sleep 2
done
echo ""
echo "Tunnel connected."
echo ""
echo "-------------------------------------------------------------------------"
echo "To connect to Jupyter, point your browser to localhost:7777"

while :
do if ! [ -e "${HYAK_JUPYTER_SOCKET_FILE}" ]
   then exit 0
   else sleep 5
   fi
done
