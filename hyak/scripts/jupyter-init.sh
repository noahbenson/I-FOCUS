#! /bin/bash
################################################################################
# This command runs the ifocus-init.sh script to initialize all the shared
# I-FOCUS configuration items then parses the Jupyter-specific arguments and
# prints the overall configuration.
# This script can be run instead of ifocus-init.sh as it exports all of the
# configuration data from ifocus-init.sh.


# Configuration ################################################################
# The configuration is handles by the ifocus-config.sh script; to call this, we
# just need to know the directory of the current script, which will always be
# the same as the config script (and all the other non-command I-FOCUS scripts.)

# What directory is this script running from?
SCRIPT_PATH="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PATH="${SCRIPT_PATH}:${PATH}"

# We have to declare the command we're running before we run the ifocus-init.sh
# script.
export IFOCUS_COMMAND="jupyter"

# Run and evaluate the ifocus-init.sh script.
IFOCUS_INIT="$(ifocus-init.sh "$@")" || exit 1
eval "${IFOCUS_INIT}"

# We have a default image we wish to use, assuming IFOCUS_IMAGE wasn't already
# set or wasn't set in the command arguments.
IFOCUS_IMAGE_DEFAULT="docker://quay.io/jupyter/datascience-notebook:2024-10-02"
IFOCUS_IMAGE="${IFOCUS_IMAGE:-${IFOCUS_IMAGE_DEFAULT}}"

# The jupyter subcommand (lab or notebook).
IFOCUS_JUPYTER_CMD_DEFAULT="lab"
IFOCUS_JUPYTER_CMD="${IFOCUS_JUPYTER_CMD:-${IFOCUS_JUPYTER_CMD_DEFAULT}}"


# Process Configuration ########################################################

# SLURM_NNODES should always be 1.
NNODES_NAME="${IFOCUS_SLURM_PREFIX}NNODES"
NNODES="${!NNODES_NAME}"
[ "${NNODES}" -eq 1 ] \
    || die "Jupyter uses 1 node, but ${NNODES_NAME}=${NNODES}"

# We want to search the arguments for --lab / --notebook.
POS_ARGS_ORIG=("${POS_ARGS[@]}")
POS_ARGS=()
for ARG in "${POS_ARGS_ORIG[@]}"
do if   [ "${ARG}" = "--lab" ]
   then IFOCUS_JUPYTER_CMD="lab"
   elif [ "${ARG}" = "--notebook" ]
   then IFOCUS_JUPYTER_CMD="notebook"
   else POS_ARGS+=("${ARG}")
   fi
done

# Note the socket file.
IFOCUS_JUPYTER_SOCKET_FILE="${IFOCUS_WORK_PATH}/socket.sock"
IFOCUS_JUPYTER_LOGIN_FILE="${IFOCUS_WORK_PATH}/login.sock"


# Export Configuration #########################################################
# Exporting the configuration means printing it to stdout so that the calling
# script can capture that output and eval it.

# First, we export the IFOCUS configuration; we exclude the POS_ARGS and the
# IFOCUS_IMAGE variables because we may have modified them.
echo "${IFOCUS_INIT}" \
    | grep -v '^export POS_ARGS='
    | grep -v '^export IFOCUS_IMAGE='

# Next, we can grab the most of the variables we need from the set command:
set | grep "^IFOCUS_JUPYTER_" \
    | grep -v "^IFOCUS_[^=]*_DEFAULT=" \
    | sed "s/^IFOCUS_/export IFOCUS_/g"

# Last, export the (possibly modified) POS_ARGS and IFOCUS_IMAGE variables.
echo "export IFOCUS_IMAGE=${IFOCUS_IMAGE@Q}"
echo "export POS_ARGS=(${POS_ARGS[@]@Q})"


# Exit Cleanly! ################################################################

exit 0
