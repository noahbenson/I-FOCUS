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

# The partition we use if we can't figure out a "coprrect" one:
IFOCUS_DEFAULT_PARTITION="cpu-g2"

# We prefer these accounts in this order if multiple accounts are available:
declare -A PREFERRED_PARTITIONS
PREFERRED_PARTITIONS=(
    ['escience']='ckpt-all'
    ['psych']='cpu-g2-mem2x'
    ['fang']='cpu-g2')


# Logic ########################################################################

# This script requires the account as the first argument
if [ -z "$1" ]
then echo "WARNING: No account name given to guess-partition.sh." 2>&1
     echo "         Defaulting to partition ${IFOCUS_DEFAULT_PARTITION}." 2>&1
     echo "${IFOCUS_DEFAULT_PARTITION}"
     exit 0
fi

# See if we have a preferred partition for our account.
PREFERRED_PARTITION="${PREFERRED_PARTITIONS[$1]}"
if [ -n "${PREFERRED_PARTITION}" ]
then echo "${PREFERRED_PARTITION}"
     exit 0
fi

# If not, we'll just guess ckpt-all.
echo "${IFOCUS_DEFAULT_PARTITION}"
exit 0
