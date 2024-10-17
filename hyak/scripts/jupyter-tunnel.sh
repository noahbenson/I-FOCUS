#! /bin/bash

# Utility stuff.
function die {
    echo "ERROR:" "$@" 1>&2
    exit 1
}

# Configuration should come from the environment variables.

# Make sure our screen caption is correct.
[ -n "$STY" ] && {
    echo "==========================================================="
    echo "To detach, press control + a then d. To reattach: screen -x"
    echo ""
}

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
