#! /bin/bash
################################################################################
# Sets up the hyak-jupyter directory and waits for the tunnel to connect.


# Configuration ################################################################

# What directory is this script in?
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Load the configuration from the script for it.
eval "$(${SCRIPT_DIR}/jupyter-config.sh "$@")"


# Establish the Tunnel #########################################################

# Wait for the file to appear...
while :
do if [ -e "${HYAK_JUPYTER_RUN_SCRIPT}" ] && [ -e "${HYAK_JUPYTER_JOB_FILE}" ]
   then break
   else sleep 2
   fi
done

# Load the job data.
source "${HYAK_JUPYTER_JOB_FILE}"

# Run the script on the node...
ssh -L "${HYAK_JUPYTER_LOGIN_FILE}:${HYAK_JUPYTER_SOCKET_FILE}" \
    "${SLURMD_NODENAME}" "${HYAK_JUPYTER_RUN_SCRIPT}"

# Clean up.
echo ""
echo "Tunnel closed."
echo ""
read -n1 -p "Press enter to exit." KEYPRESS
exit 0
