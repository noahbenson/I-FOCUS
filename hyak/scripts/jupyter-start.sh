#! /bin/bash
################################################################################
# Sets up the ifocus-jupyter directory and waits for the tunnel to connect.


# Utilities ####################################################################

# A function to print an error then exit with an error code.
function die { echo "ERROR:" "$@" 1>&2; exit 1; }


# Configuration ################################################################

# What directory is this script in?
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# The single argument to this script must be the job file, which we source.
IFOCUS_JOB_FILE="$1"
[ -r "${IFOCUS_JOB_FILE}" ] \
    && source "${IFOCUS_JOB_FILE}" \
    || die "jupyter-start.sh requires a job file as its only argument."

# We always run this command from our home directory.
cd


# Sanity Checks ################################################################

# Make sure we're a SLURM job.
[ -n "${SLURM_JOB_ID}" ] \
    || die "No SLURM_JOB_ID set."

# Make sure the work directory exists.
mkdir -p "${IFOCUS_WORK_PATH}" \
    || die "Could not make work directory: ${IFOCUS_WORK_PATH}"

# It's now safe to grab the status; this is also done by the hyak-jupyter script
# because we want the status file to disappear as soon as there is a failure in
# the scripts.
ifocus_start

# Write the nodename and job ID out to the job data file:
echo "export SLURMD_NODENAME=${SLURMD_NODENAME}" >> "${IFOCUS_JOB_FILE}"
echo "export SLURM_JOB_ID=${SLURM_JOB_ID}" >> "${IFOCUS_JOB_FILE}"

# Write out the command for the server:
if [ "${IFOCUS_JUPYTER_CMD}" = "lab" ]
then JUPYTER_ENABLE_LAB=yes
else JUPYTER_ENABLE_LAB=no
fi
cat >"${IFOCUS_JUPYTER_RUN_SCRIPT}" <<EOF
#! /bin/bash

# Always run from home:
cd

# A useful function for erroring out:
function die { echo "ERROR: \$*" 1>&2; exit 1; }

# Start by sourcing the job file:
source "${IFOCUS_JOB_FILE}"

# We claim the status file here; this file is also claimed by other scripts that
# lead to this script getting called, but these are layers of failure checks, so
# there's no issue. We want the status file to disappear as soon as the system
# fails, so we put the check everywhere.
ifocus_start

singularity exec \
    --env "JUPYTER_ENABLE_LAB=${JUPYTER_ENABLE_LAB}" \
    --home "${HOME}" \
    --bind "${HOME}/.local:/home/jovyan/.local" \
    --bind "/gscratch:/gscratch" \
    ${IFOCUS_IMAGE} \
    jupyter ${IFOCUS_JUPYTER_CMD} \
       --no-browser \
       --sock "${IFOCUS_JUPYTER_SOCKET_FILE}" \
       --ip='*' --NotebookApp.token='' --NotebookApp.password=''
RVAL="\$?"

echo "Jupyter exited with status \$RVAL."
exit "\$RVAL"
EOF
chmod 700 "${IFOCUS_JUPYTER_RUN_SCRIPT}"

# Print a message about how we now wait for the tunnel to start up.
echo "Waiting for tunnel to connect..."
echo ""
echo "This may take a few minutes, especially if you have not used the image"
echo "${IFOCUS_IMAGE} recently."
echo ""
echo "To check on the tunnel progress, press control + a twice; you can do this"
echo "again to switch back to this view."

# Wait for the connection from the tunnel...
while ! [ -e "${IFOCUS_JUPYTER_SOCKET_FILE}" ]; do sleep 5; done

# Print a message about how everything's working now...
echo ""
echo "Tunnel connected."
echo ""
echo "-------------------------------------------------------------------------"
echo "To connect to Jupyter, point your browser to localhost:7777"

# Now wait for the tunnel to exit before exiting ourselves.
while ${SCRIPT_DIR}/jupyter-query.sh &>/dev/null; do sleep 5; done
exit 0
