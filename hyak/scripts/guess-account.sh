#! /bin/bash
################################################################################
# This command attempts to deduce the account that should be used for a SLURM
# command. It should be run without arguments, under the assumption that all
# other methods of figuring out the account (command line and/or environment
# variables) have been exhausted. These methods can be found in the
# ifocus-config.sh script. It outputs a single account name and returns 0 if a
# valid account is found and outputs an error message to stderr and returns 1 if
# no valid account is found.


# Configuration ################################################################

# We prefer these accounts in this order if multiple accounts are available:
PREFERRED_ACCOUNTS=(fang escience psych)

# We won't use these accounts:
EXCLUDED_ACCOUNTS=(all test)


# Logic ########################################################################

# A function that tests whether an account is in a group of accounts; given a
# variable `VAL` whose value we are searching for in an array `ARR`, this
# function should be called as:
#   inarray "$VAL" "${ARR[@]}"
function inarray {
    [ $# -lt 2 ] && return 1
    local EL="$1"
    shift
    while [ $# -gt 0 ]
    do [ "$EL" = "$1" ] && return 0
       shift
    done
    return 1
}

# Function for printing an error message and exiting.
function die {
    echo "ERROR (guess-account.sh): $@" 1>&2
    exit 1
}

# The possible Hyak accounts are the groups as listed by the groups command:
POSSIBLE_ACCOUNTS=($(groups))

# Go through the possible accounts and any account that is in the excluded
# accounts list.
VALID_ACCOUNTS=()
for ACCOUNT in "${POSSIBLE_ACCOUNTS[@]}"
do if ! inarray "${ACCOUNT}" "${EXCLUDED_ACCOUNTS[@]}"
   then VALID_ACCOUNTS+=("${ACCOUNT}")
   fi
done
[ ${#VALID_ACCOUNTS[@]} -eq 0 ] \
    && die "No valid accounts found among all accounts:${POSSIBLE_ACCOUNTS[*]}."

# See if there is a preferred account listed before we pick a random account.
for ACCOUNT in "${PREFERRED_ACCOUNTS[@]}"
do if inarray "${ACCOUNT}" "${VALID_ACCOUNTS[@]}"
   then # This is the account we use:
        echo "${ACCOUNT}"
        exit 0
   fi
done

# If we get to this point, we don't have a preferred account, so we just use the
# first valid account:
echo "${VALID_ACCOUNTS[0]}"
exit 0
