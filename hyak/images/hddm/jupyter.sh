#! /bin/bash

# We ignore the first argument, which is either lab or notebook.
if [ "$1" = "lab" ] || [ "$1" = "notebook" ]
then shift
fi

# Set up the environment.
export ENV_NAME=hddm36
source /usr/local/bin/_activate_current_env.sh

# Run jupyter notebook!
exec python -m jupyter notebook "$@"
