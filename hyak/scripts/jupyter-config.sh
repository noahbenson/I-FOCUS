#! /bin/bash
################################################################################
# This command parses all arguments into a set of variables then prints those
# variables out; it is meant to be run as a sort of shell function: eval
# "$(jupyter-config.sh "$@")" Running the above command will set and export all
# of the environment variables that the hyak-jupyter system depends on using the
# argument list "$@".
# If any of the environment variables are already set, those values are used by
# default.


# Configuration ################################################################

# Filesystem -------------------------------------------------------------------

# What directory is this script running from?
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# The names of the other scripts:
HYAK_JUPYTER_START="${SCRIPT_DIR}/jupyter-start.sh"
HYAK_JUPYTER_TUNNEL="${SCRIPT_DIR}/jupyter-tunnel.sh"
HYAK_JUPYTER_QUERY="${SCRIPT_DIR}/jupyter-query.sh"

# Default Values ---------------------------------------------------------------

# The singularity image we are using to run Jupyter.
HYAK_JUPYTER_IMAGE_DEFAULT="docker://quay.io/jupyter/datascience-notebook:2024-10-02"

# The directory we use to store local data like unix sockets and job data.
HYAK_JUPYTER_DIR_DEFAULT="${HOME}/.hyak-jupyter"

# The jupyter subcommand (lab or notebook).
HYAK_JUPYTER_SUBCMD_DEFAULT="lab"

# The tag. This is mostly an unused feature, but it theoretically allows one to
# open multiple jupyter sessions at once
HYAK_JUPYTER_TAG_DEFAULT="default"

# The name given to the screen session; if blank, then uses the tag.
HYAK_JUPYTER_SCREEN_NAME_DEFAULT=""

# If SLURM memory isn't specified, we go with 12G.
SLURM_MEM_PER_NODE_DEFAULT=12G

# If the number of cpus isn't specified, request 4.
SLURM_NTASKS_PER_NODE_DEFAULT=4

# We want to auto-detect an account.
SLURM_ACCOUNT_DEFAULT=$(
    groups | sed -E 's/(all)|(test)//g' | sed -E s'/  / /g' | cut -d ' ' -f 1)

# We also want to use a sensible choice for partition.
SLURM_PARTITION_DEFAULT=ckpt-all

# hyak-jupyter -----------------------------------------------------------------

HYAK_JUPYTER_IMAGE="${HYAK_JUPYTER_IMAGE:-${HYAK_JUPYTER_IMAGE_DEFAULT}}"
HYAK_JUPYTER_DIR="${HYAK_JUPYTER_DIR:-${HYAK_JUPYTER_DIR_DEFAULT}}"
HYAK_JUPYTER_SUBCMD="${HYAK_JUPYTER_SUBCMD:-${HYAK_JUPYTER_SUBCMD_DEFAULT}}"
HYAK_JUPYTER_TAG="${HYAK_JUPYTER_TAG:-${HYAK_JUPYTER_TAG_DEFAULT}}"
HYAK_JUPYTER_SCREEN_NAME="${HYAK_JUPYTER_SCREEN_NAME:-${HYAK_JUPYTER_SCREEN_NAME_DEFAULT}}"
[ -z "${HYAK_JUPYTER_SCREEN_NAME}" ] \
    && HYAK_JUPYTER_SCREEN_NAME="jupyter-${HYAK_JUPYTER_TAG}"

# SLURM ------------------------------------------------------------------------

SLURM_MEM_PER_NODE=${SLURM_MEM_PER_NODE:-${SLURM_MEM_PER_NODE_DEFAULT}}
SLURM_NTASKS_PER_NODE=${SLURM_NTASKS_PER_NODE:-${SLURM_NTASKS_PER_NODE_DEFAULT}}
SLURM_ACCOUNT=${SLURM_ACCOUNT:-${SLURM_ACCOUNT_DEFAULT}}
SLURM_PARTITION=${SLURM_PARTITION:-${SLURM_PARTITION_DEFAULT}}

# Jupyter runs on 1 node, so we always want 1 node.
SLURM_NNODES=1


# Arguments ####################################################################

# We need to collect a few options for srun because we want to (1) autodetect
# the the account if possible and (2) use decent defaults for time, cpus,
# memory, and partition when not provided.
SRUN_ARGS=()

# Step through each argument and figure out whether we understand it or whether
# it gets passed on to srun.
while [ $# -gt 0 ]
do case "$1" in
       --image)
	   HYAK_JUPYTER_IMAGE="$2"
	   shift
	   shift
	   ;;
       --image=*)
	   HYAK_JUPYTER_IMAGE="${1:8}"
	   shift
	   ;;
       --tag)
	   HYAK_JUPYTER_TAG="$2"
	   shift
	   shift
	   ;;
       --tag=*)
	   HYAK_JUPYTER_TAG="${1:6}"
	   shift
	   ;;
       --dir)
	   HYAK_JUPYTER_DIR="$2"
	   shift
	   shift
	   ;;
       --dir=*)
	   HYAK_JUPYTER_DIR="${1:6}"
	   shift
	   shift
	   ;;
       --lab)
	   HYAK_JUPYTER_SUBCMD="lab"
	   shift
	   ;;
       --notebook)
	   HYAK_JUPYTER_SUBCMD="notebook"
	   shift
	   ;;
       --)
	   shift
	   SRUN_ARGS+=("$@")
	   break
	   ;;
       *)
	   SRUN_ARGS+=("$1")
	   shift
	   ;;
   esac
done

# A few of the variables like the tunnel directory come from a combination of
# the above:
HYAK_JUPYTER_TUNNELS_DIR="${HYAK_JUPYTER_DIR}/tunnels"
HYAK_JUPYTER_TUNNEL_DIR="${HYAK_JUPYTER_TUNNELS_DIR}/${HYAK_JUPYTER_TAG}"
HYAK_JUPYTER_SOCKET_FILE="${HYAK_JUPYTER_TUNNEL_DIR}/socket.sock"
HYAK_JUPYTER_LOGIN_FILE="${HYAK_JUPYTER_TUNNEL_DIR}/login.sock"
HYAK_JUPYTER_JOB_FILE="${HYAK_JUPYTER_TUNNEL_DIR}/jobdata.sh"
HYAK_JUPYTER_RUN_SCRIPT="${HYAK_JUPYTER_TUNNEL_DIR}/run.sh"


# Export Configuration #########################################################
# Exporting the configuration means printing it to stdout so that the calling
# script can capture that output and eval it.

# We can grab most of the variables we need  from the set command!
set | grep '^HYAK_JUPYTER_'
set | grep '^SLURM_'

# The only thing left is the SRUN_ARGS list.
echo "SRUN_ARGS=(\"${SRUN_ARGS[@]}\")"


# Exit Cleanly! ################################################################

exit 0
