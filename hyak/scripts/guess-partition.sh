#! /bin/bash
################################################################################
# This command attempts to deduce the partition that should be used for a SLURM
# command. It should be run with one argument: the account name, under the
# assumption that all other methods of figuring out the partition (command line
# and/or environment variables) have been exhausted. These methods can be found
# in the ifocus-init.sh script.
#
# This script outputs a single partition name and returns 0 if a valid partition
# is found and outputs an error message to stderr and returns 1 if no valid
# partition is found.


# Configuration ################################################################

# We prefer these accounts in this order if multiple accounts are available:
declare -A PREFERRED_PARTITIONS
PREFERRED_PARTITIONS=(
    ['escience']='ckpt-all'
    ['psych']='cpu-g2-mem2x')

# Utility function for erroring out.
function die { echo "ERROR: $*" 1>&2; exit 1; }


# Logic ########################################################################

# This script requires the account as the first argument
[ -z "$1" ] \
    && die "The account name is required as an argument to guess-partition.sh."
ACCOUNT="$1"

# See if we have a preferred partition for our account.
PREFERRED_PARTITION="${PREFERRED_PARTITIONS[${ACCOUNT}]}"
if [ -n "${PREFERRED_PARTITION}" ]
then echo "${PREFERRED_PARTITION}"
     exit 0
fi

# If not, we'll just guess ckpt-all.
echo "ckpt-all"
exit 0
