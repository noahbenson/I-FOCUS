#! /bin/bash
################################################################################
# This command parses all arguments into a set of variables then prints those
# variables out; it is meant to be run as a sort of shell function:
# eval "$(ifocus-init.sh "$@")"
# Running the above command will set and export all of the environment variables
# that the I-FOCUS scripting system depends on using the argument list "$@". If
# any of the environment variables are already set, those values are used by
# default.

function die { echo "ERROR: $*" 1>&2; exit 1; }


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

# If there is no IFOCUS_COMMAND defined, we set it to a default value.
IFOCUS_COMMAND_DEFAULT="none"
if [ -z "${IFOCUS_COMMAND}" ]
then echo "WARNING: Setting IFOCUS_COMMAND to '${IFOCUS_COMMAND_DEFAULT}'" 1>&2
     IFOCUS_COMMAND="${IFOCUS_COMMAND_DEFAULT}"
fi


# SLURM Initialization ---------------------------------------------------------

SLURM_NNODES=${SLURM_NNODES:-${SLURM_NNODES_DEFAULT}}
SLURM_NTASKS_PER_NODE=${SLURM_NTASKS_PER_NODE:-${SLURM_NTASKS_PER_NODE_DEFAULT}}
SLURM_NTASKS=${SLURM_NTASKS:-${SLURM_NTASKS_DEFAULT}}
SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK:-${SLURM_CPUS_PER_TASK_DEFAULT}}
SLURM_ACCOUNT=${SLURM_ACCOUNT:-${SLURM_ACCOUNT_DEFAULT}}
SLURM_PARTITION=${SLURM_PARTITION:-${SLURM_PARTITION_DEFAULT}}
SLURM_MEM_PER_NODE=${SLURM_MEM_PER_NODE:-${SLURM_MEM_PER_NODE_DEFAULT}}
SLURM_MEM_PER_CPU=${SLURM_MEM_PER_CPU:-${SLURM_MEM_PER_CPU_DEFAULT}}


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
       # We also allow the specification of a screen for those commands that use
       # screens.
       --screen)
           IFOCUS_SCREEN="$2"
           shift
           shift
           ;;
       --screen=*)
           IFOCUS_SCREEN="${1:9}"
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
       -t|--time)
           SLURM_TIMELIMIT="$2"
           shift
           shift
           ;;
       -t*)
           SLURM_TIMELIMIT="${1:2}"
           shift
           ;;
       --time=*)
           SLURM_TIMELIMIT="${1:7}"
           shift
           ;;
       --mem)
           SLURM_MEM_PER_NODE="$2"
           shift
           shift
           ;;
       --mem=*)
           SLURM_MEM_PER_NODE="${1:6}"
           shift
           ;;
       --mem-per-cpu)
           SLURM_MEM_PER_CPU="$2"
           shift
           shift
       --mem-per-cpu=*)
           SLURM_MEM_PER_CPU="${1:14}"
           shift
       -N|--nodes)
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
           ;;
       --ntasks=*)
           SLURM_NTASKS="${1:9}"
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
           ;;
       --cpus-per-task=*)
           SLURM_CPUS_PER_TASK="${1:16}"
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


# Checks and Logic #############################################################

# A few of the variables like the tunnel directory come from a combination of
# the above:
IFOCUS_COMMAND_PATH="${IFOCUS_PATH}/work/${IFOCUS_COMMAND}"
IFOCUS_WORK_PATH="${IFOCUS_COMMAND_PATH}/${IFOCUS_TAG:-default}"
IFOCUS_JOB_FILE="${IFOCUS_WORK_PATH}/jobdata.sh"
IFOCUS_STATUS_FILE="${IFOCUS_WORK_PATH}/status"

# If no timelimit was given, we error out.
[ -z "${SLURM_TIMELIMIT}" ] \
    && die "No time-limit given; use --time=H:MM:SS or -t H:MM:SS"

# If IFOCUS_SCREEN isn't set, its default value is <command>-<tag> or
# just <command> if tag isn't set.
if [ -z "${IFOCUS_SCREEN}" ]
then if [ -z "${IFOCUS_TAG}" ]
     then IFOCUS_SCREEN="${IFOCUS_COMMAND}"
     else IFOCUS_SCREEN="${IFOCUS_COMMAND}-${IFOCUS_TAG}"
     fi
fi

# We may need to auto-detect the account.
if [ -z "${SLURM_ACCOUNT}" ]
then SLURM_ACCOUNT="$("${SCRIPT_PATH}"/guess-account.sh)" \
        || die "Could not deduce an account to use."
fi

# We may also need to auto-detect the partition.
if [ -z "${SLURM_PARTITION}" ]
then SLURM_PARTITION="$(${SCRIPT_PATH}/guess-partition.sh "${SLURM_ACCOUNT}")" \
        || die "Could not deduce a partition to use."
fi

# If the work path doesn't exist, we should go ahead and make it.
[ -d "${IFOCUS_WORK_PATH}" ] \
    || mkdir -p "${IFOCUS_WORK_PATH}" \
    || die "Could not make work directory: ${IFOCUS_WORK_PATH}"

# We can now write a function for opening and editing the status file. This file
# should be created as soon as a job starts initializing; once it finishes, the
# status file should be automatically deleted.
# Any script that runs ifocus_start will immediately create the status file and
# and will automatically delete the status file on exit.
function ifocus_start {
    touch "${IFOCUS_STATUS_FILE}"
    function ifocus_status_cleanup {
        [ -w "${IFOCUS_STATUS_FILE}" ] && rm -f "${IFOCUS_STATUS_FILE}"
    }
    trap ifocus_status_cleanup EXIT SIGINT SIGTERM SIGQUIT SIGILL SIGABRT
}
# Usage: ifocus_isrunning && echo "ifocus job is already running!"
function ifocus_isrunning {
    if [ -r "${IFOCUS_STATUS_FILE}" ]
    then return 0
    else return 1
    fi
}


# Export Configuration #########################################################
# Exporting the configuration means printing it to stdout so that the calling
# script can capture that output and eval it.

# We can grab most of the variables we need from the set command:
set | grep "^IFOCUS_" \
    | grep -v '=$' \
    | grep -vE '^IFOCUS_[^=]*_DEFAULT=' \
    | sed "s/^IFOCUS_/export IFOCUS_/g"
# For the SLURM_ variables, we might need to convert them to SALLOC_ or some
# other prefix.
set | grep "^SLURM_" \
    | grep -v '=$' \
    | grep -vE '^SLURM_[^=]*_DEFAULT=' \
    | sed "s/^SLURM_/export ${IFOCUS_SLURM_PREFIX}/g"
# We also want to export our function:
declare -f ifocus_start ifocus_isrunning

# We want to export SLURM_ARGS, and we want that variable name to be SLURM_ARGS
# whether the ifocus slurm prefix is SALLOC_ or SLURM_
SLURM_ALLARGS=(
    --account="${SLURM_ACCOUNT}"
    --partition="${SLURM_PARTITION}"
    --time="${SLURM_TIMELIMIT}"
    --nodes="${SLURM_NNODES}"
    --ntasks="${SLURM_NTASKS}"
    --ntasks-per-node="${SLURM_NTASKS_PER_NODE}"
    --cpus-per-task="${SLURM_CPUS_PER_TASK}"
    --mem="${SLURM_MEM_PER_NODE}"
    --mem-per-cpu="${SLURM_MEM_PER_CPU}")
# Filter out the empty arguments.
SLURM_ARGS=()
for ARG in "${SLURM_ALLARGS[@]}"
do [ "${ARG: -1}" != "=" ] && SLURM_ARGS+=("${ARG}")
done
# Print these as part of the configuration, along with the POS_ARGS list.
cat <<EOF
export SLURM_ARGS=(${SLURM_ARGS[@]@Q})
export POS_ARGS=(${POS_ARGS[@]@Q})
EOF


# Exit Cleanly! ################################################################

exit 0
