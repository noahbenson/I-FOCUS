#! /bin/bash

# This script sets up the hyak-jupyter command and related scripts.

# Utility function.
function die {
    echo "ERROR:" "$@" 1>&2
    exit 1
}

# The command always lives in the directory ~/.hyak-jupyter
BASEDIR="${HOME}/.i-focus"
BINDIR="${BASEDIR}/bin"
mkdir -p "${BINDIR}" \
    || die "Could not create directory ${BINDIR}"

# Figure out what directory this script is in:
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# First thing is to copy all the executables into the bin directory:
cp "${SCRIPT_DIR}"/scripts/*.sh "${BINDIR}" \
    && chmod 755 "${BINDIR}"/*.sh \
    || die "Could not copy helper scripts to ${BINDIR}"
# Also put the hyak-jupyter script in the ~/.local/bin directory:
mkdir -p "${HOME}/.local/bin" \
    || die "Could not create directory ${HOME}/.local/bin"
cp "${SCRIPT_DIR}/scripts/hyak-jupyter" "${HOME}/.local/bin" \
    || die "Could not copy hyak-jupyter to directory ${HOME}/.local/bin"
[ -x "${SCRIPT_DIR}/scripts/hyak-matlab" ] \
    && cp "${SCRIPT_DIR}/scripts/hyak-matlab" "${HOME}/.local/bin" #\
    #|| die "Could not copy hyak-matlab to directory ${HOME}/.local/bin"

# Finally, we want to put a line for APPTAINER in the bashrc file:
if ! grep -q APPTAINER_CACHE "${HOME}/.bashrc"
then cat >> "${HOME}/.bashrc" <<EOF

# Added by hyak-jupyter setup.sh script.
export APPTAINER_CACHEDIR="/gscratch/scrubbed/${USER}/.cache/apptainer"
EOF
fi

cat <<EOF

================================================================================
Successfully installed hyak-jupyter!

To run Jupyter on Hyak, just use the command hyak-jupyter; any options that can
be passed to the srun command can be passed to hyak-jupyter as well.

In order for this command to work, you must log in to Hyak with local port
forwarding from 7777 to file:
   ${BASEDIR}/tunnels/default/login.sock
This may be done by running ssh with the following option:
   ssh -L7777:${BASEDIR}/tunnels/default/login.sock ${USER}@klone.hyak.uw.edu
Or by adding the following to your computer's ssh config file:
   Host hyak
      HostName klone.hyak.uw.edu
      User ${USER}
      LocalForward 7777 ${BASEDIR}/tunnels/default/login.sock
If you have followed the instructions in the I-FOCUS github repository's README
files, then you should have already added the relevant text to your ssh config
file!

EOF

exit 0
