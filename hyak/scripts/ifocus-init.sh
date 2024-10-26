#! /bin/bash
################################################################################
# This command parses all arguments into a set of variables then prints those
# variables out; it is meant to be run as a sort of shell function:
# eval "$(ifocus-init.sh "$@")"
# Running the above command will set and export all of the environment variables
# that the I-FOCUS scripting system depends on using the argument list "$@". If
# any of the environment variables are already set, those values are used by
# default.


# Configuration ################################################################
# The configuration is handles by the ifocus-config.sh script; to call this, we
# just need to know the directory of the current script, which will always be
# the same as the config script (and all the other non-command I-FOCUS scripts.)

# What directory is this script running from?
SCRIPT_PATH="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PATH="${SCRIPT_PATH}:${PATH}"

# Source the configuration script. This script defines all the default values
source "${SCRIPT_PATH}/ifocus-config.sh"

# I-FOCUS Initialization -------------------------------------------------------

# The path of our local data directory (default is ~/.i-focus).
IFOCUS_PATH="${IFOCUS_PATH:-${IFOCUS_PATH_DEFAULT}}"

# The prefix to give SLURM environment variables; this is usually SLURM_, but if
# running an salloc command, this should instead of SALLOC_. The SALLOC_ prefix
# can also be set with the --salloc option.
IFOCUS_SLURM_PREFIX="${IFOCUS_SLURM_PREFIX:-SLURM_}"

# SLURM Initialization ---------------------------------------------------------

SLURM_MEM_PER_NODE=${SLURM_MEM_PER_NODE:-${SLURM_MEM_PER_NODE_DEFAULT}}
SLURM_NNODES=${SLURM_NNODES:-${SLURM_NNODES_DEFAULT}}
SLURM_NTASKS_PER_NODE=${SLURM_NTASKS_PER_NODE:-${SLURM_NTASKS_PER_NODE_DEFAULT}}
SLURM_NTASKS=${SLURM_NTASKS:-${SLURM_NTASKS_DEFAULT}}
SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK:-${SLURM_CPUS_PER_TASK_DEFAULT}}
SLURM_ACCOUNT=${SLURM_ACCOUNT:-${SLURM_ACCOUNT_DEFAULT}}
SLURM_PARTITION=${SLURM_PARTITION:-${SLURM_PARTITION_DEFAULT}}


# Arguments ####################################################################

# We need to collect a few options for srun because we want to (1) autodetect
# the the account if possible and (2) use decent defaults for time, cpus,
# memory, and partition when not provided.
POS_ARGS=()

# Step through each argument and figure out whether we understand it or whether
# it gets passed on as a positional argument.
while [ $# -gt 0 ]
do case "$1" in
       # Multiple commands use images, so we parse them as --image:
       --image)
	   IFOCUS_IMAGE="$2"
	   shift
	   shift
	   ;;
       --image=*)
	   IFOCUS_IMAGE="${1:8}"
	   shift
	   ;;
       # Similarly, some of the commands can be given tags via --tag:
       --tag)
	   IFOCUS_TAG="$2"
	   shift
	   shift
	   ;;
       --tag=*)
	   IFOCUS_TAG="${1:6}"
	   shift
	   ;;
       # We can set the I-FOCUS path (where we store temporary data).
       --ifocus-path)
	   IFOCUS_PATH="$2"
	   shift
	   shift
	   ;;
       --ifocus-path=*)
	   IFOCUS_PATH="${1:14}"
	   shift
	   ;;
       # We can specify a SLURM prefix; this is usually SLURM_ for the srun
       # command, but the salloc takes SALLOC_ variables.
       --slurm-prefix)
           IFOCUS_SLURM_PREFIX="$2"
	   shift
	   shift
	   ;;
       --slurm-prefix=*)
	   IFOCUS_SLURM_PREFIX="${1:15}"
	   shift
	   ;;
       --salloc)
           IFOCUS_SLURM_PREFIX="SALLOC_"
           shift
           ;;
       --srun)
           IFOCUS_SLURM_PREFIX="SLURM_"
           shift
           ;;
       # We also interpret a number of SLURM arguments (so that we can have or
       # guess default values).
       --mem)
           SLURM_MEM_PER_NODE="$2"
           shift
           shift
           ;;
       --mem=*)
           SLURM_MEM_PER_NODE="${1:6}"
           shift
           ;;
       -N|-nodes)
           SLURM_NNODES="$2"
           shift
           shift
           ;;
       -N*)
           SLURM_NNODES="${1:2}"
           shift
           ;;
       --nodes=*)
           SLURM_NNODES="${1:8}"
           shift
           ;;
       -n|--ntasks)
           SLURM_NTASKS="$2"
           shift
           shift
           ;;
       -n*)
           SLURM_NTASKS="${1:2}"
           shift
           shift
           ;;
       --ntasks=*)
           SLURM_NTASKS="${1:9}"
           shift
           shift
           ;;
       --ntasks-per-node)
           SLURM_NTASKS_PER_NODE="$2"
           shift
           shift
           ;;
       --ntasks-per-node=*)
           SLURM_NTASKS_PER_NODE="${1:18}"
           shift
           ;;
       -c|--cpus-per-task)
           SLURM_CPUS_PER_TASK="$2"
           shift
           shift
           ;;
       -c*)
           SLURM_CPUS_PER_TASK="${1:2}"
           shift
           shift
           ;;
       --cpus-per-task=*)
           SLURM_CPUS_PER_TASK="${1:16}"
           shift
           shift
           ;;
       -A|--account)
           SLURM_ACCOUNT="$2"
           shift
           shift
           ;;
       -A*)
           SLURM_ACCOUNT="${1:2}"
           shift
           ;;
       --account=*)
           SLURM_ACCOUNT="${1:10}"
           shift
           ;;
       -p|--partition)
           SLURM_PARTITION="$2"
           shift
           shift
           ;;
       -p*)
           SLURM_PARTITION="${1:2}"
           shift
           ;;
       --partition=*)
           SLURM_PARTITION="${1:12}"
           shift
           ;;
       # If we reach a --, all remaining arguments are positional.
       --)
	   shift
	   POS_ARGS+=("$@")
	   break
	   ;;
       # Otherwise we consider this argument to be a positional argument.
       *)
	   POS_ARGS+=("$1")
	   shift
	   ;;
   esac
done

# A few of the variables like the tunnel directory come from a combination of
# the above:
IFOCUS_TUNNELS_DIR="${IFOCUS_PATH}/tunnels"
IFOCUS_TUNNEL_DIR="${IFOCUS_TUNNELS_DIR}/${IFOCUS_TAG}"
IFOCUS_JOB_FILE="${IFOCUS_TUNNEL_DIR}/jobdata.sh"

# We may need to auto-detect the the account.
if [ -z "${SLURM_ACCOUNT}" ]
then SLURM_ACCOUNT="$(guess-account.sh)" \
        || die "Could not deduce an account to use."
fi


# Export Configuration #########################################################
# Exporting the configuration means printing it to stdout so that the calling
# script can capture that output and eval it.

# We can grab most of the variables we need from the set command:
set | grep "^IFOCUS_" \
    | sed "s/^IFOCUS_/export IFOCUS_/g"
# For the SLURM_ variables, we might need to convert them to SALLOC_ or some
# other prefix.
set | grep "^SLURM_" \
    | sed "s/^SLURM_/${IFOCUS_SLURM_PREFIX}=/g"

# We want to export SLURM_ARGS, and we want that variable name to be SLURM_ARGS
# whether the ifocus slurm prefix is SALLOC_ or SLURM_
SLURM_ARGS=(--account="${SLURM_ACCOUNT}")
if [ -n "${SLURM_PARTITION}" ]
then SLURM_ARGS+=(--partition="${SLURM_PARTITION}")
fi
if [ -n "${SLURM_MEM_PER_NODE}" ]
then SLURM_ARGS+=(--mem="${SLURM_MEM_PER_NODE}")
fi
if [ -n "${SLURM_NNODES}" ]
then SLURM_ARGS+=(--nodes="${SLURM_NNODES")
fi
if [ -n "${SLURM_NTASKS}" ]
then SLURM_ARGS+=(--ntasks="${SLURM_NTASKS}")
fi
if [ -n "${SLURM_NTASKS_PER_NODE}" ]
then SLURM_ARGS+=(--ntasks-per-node="${SLURM_NTASKS_PER_NODE}")
fi
if [ -n "${SLURM_CPUS_PER_TASK}" ]
then SLURM_ARGS+=(--="${SLURM_CPUS_PER_TASK}")
fi
if [ -n "${SLURM_}" ]
then SLURM_ARGS+=(--="${SLURM_}")
fi
if [ -n "${SLURM_}" ]
then SLURM_ARGS+=(--="${SLURM_}")
fi
if [ -n "${SLURM_}" ]
then SLURM_ARGS+=(--="${SLURM_}")
fi
echo "export SLURM_ARGS=(${SLURM_ARGS[@]@Q})"

# The only thing left is the POS_ARGS list.
echo "export POS_ARGS=(${POS_ARGS[@]@Q})"


# Exit Cleanly! ################################################################

exit 0
