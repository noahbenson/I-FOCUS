#! /bin/bash
################################################################################
# Builds apptainer images for use on Hyak.


# Configuration ################################################################

# The directory of this script.
SCRIPT_PATH="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# The IFOCUS tmp directory path (in the scrubbed directories):
IFOCUS_TMP_PATH="/gscratch/scrubbed/i-focus"

# The directory in which the images are saved.
IFOCUS_IMAGE_PATH="${IFOCUS_TMP_PATH}/images"


# Utilities ####################################################################

function syntax {
    echo "SYNTAX: build.sh <image> <tag>"
    echo ""
    echo "The <image> argument must be the name of an image whose configuration"
    echo "has been put in the I-FOCUS GitHub repository. The <tag> argument is"
    echo "an identifier to attach to the built image; for example if you run"
    echo "the build script with the arguments 'jupyter' and 'testbuild' then"
    echo "the built image will be named jupyter:testbuild."
    echo ""
    echo "This command is designed to be run on Hyak from a worker node (i.e.,"
    echo "not the login node, Klone). To allocate a worker node, you can use"
    echo "the hyak-sh command. Upon completion, the image will automatically be"
    echo "saved to the following directory: ${IFOCUS_TMP_PATH}"
    echo ""
    echo "Example:"
    echo "The following command builds the 'jupyter' image with the tag"
    echo "'testbuild'. On success, the image is saved as the file"
    echo "${IFOCUS_IMAGE_PATH}/jupyter:testbuild.sif."
    echo ""
    echo "   [jovyan@klone ~]$ cd repos/i-focus/hyak/images"
    echo "   [jovyan@klone images] ./build.sh jupyter testbuild"
    echo ""
}

function die {
    echo "$*" 1>&2
    exit 1
}


# Work #########################################################################

# If we don't have correct arguments, fail:
if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ $# -ne 2 ]
then syntax
     exit 1
else IMAGE="$1"
     TAG="$2"
fi

# Go to the script directory.
cd "${SCRIPT_PATH}"

# Make sure there is a directory and instructions for our image.
[ -d "${IMAGE}" ] \
    || die "No image directory for '${IMAGE}' found in I-FOCUS repository."
[ -r "${IMAGE}"/image.def ] \
    || die "No image.def file found for image '${IMAGE}'."

# Make sure we aren't about to overwrite an image file.
IMAGE_FILE="${IFOCUS_IMAGE_PATH}/${IMAGE}:${TAG}.sif"
[ -f "${IMAGE_FILE}" ] \
    && die "Image file already exists: ${IMAGE_FILE}"

# If we are on the head-node, fail out!
[[ "`uname -n`" == *klone* ]] \
    && die "Cannot build images on the login node! Use hyak-sh."

# Okay, we're ready to build!
cd "${SCRIPT_PATH}/${IMAGE}"
if apptainer build "${IMAGE_FILE}" image.def
then RVAL=0
     echo ""
     chown "${USER}.all" "${IMAGE_FILE}"
     chmod 664 "${IMAGE_FILE}"
     echo "Apptainer build returned successfully!"
else RVAL="$?"
     echo ""
     echo "Apptainer build failed with exit code ${RVAL}."
fi

# That's all!
exit "${RVAL}"
