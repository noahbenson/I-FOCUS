#! /bin/bash
################################################################################
# This script is called by the ifocus-jupyter system to create a tunnel to a
# particular node for forwarding the Jupyter connection on to the head node and
# then back along the user's connection.


# Utilities ####################################################################

# A function to print an error then exit with an error code.
function die {
    echo "ERROR (jupyter-tunnel.sh):" "$@" 1>&2;
    exit 1;
}


# Configuration ################################################################

# What directory is this script in?
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# The single argument to this script must be the job file, which we source.
IFOCUS_JOB_FILE="$1"
[ -r "${IFOCUS_JOB_FILE}" ] \
    && source "${IFOCUS_JOB_FILE}" \
    || die "jupyter-tunnel.sh requires a job file as its only argument."

# We always run this command from our home directory.
cd


# Establish the Tunnel #########################################################

# Claim ownership of the status.
ifocus_start

# Wait for the run script to appear...
echo "Waiting for startup script to initialize..."
echo ""
echo "This may take a few moments; to see the startup script's progress, press"
echo "control + a twice. You can press control + a twice again to toggle back"
echo "to this view."
echo ""
while :
do if [ -e "${IFOCUS_JUPYTER_RUN_SCRIPT}" ]
   then break
   else sleep 2
   fi
done
# At this point, we source the job file again, because it is now guaranteed to
# have a slurm nodename included in it:
source "${IFOCUS_JOB_FILE}"

# Run the script on the node...
ssh -L "${IFOCUS_JUPYTER_LOGIN_FILE}:${IFOCUS_JUPYTER_SOCKET_FILE}" \
       "${SLURMD_NODENAME}" "${IFOCUS_JUPYTER_RUN_SCRIPT}"

# Clean up.
echo ""
echo "Tunnel closed."
echo ""
read -n1 -p "Press enter to exit." KEYPRESS
exit 0
