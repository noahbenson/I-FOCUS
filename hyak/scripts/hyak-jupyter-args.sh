#! /bin/bash

# This command parses all arguments into a set of variables then
# prints those variables out; it is meant to be run as:
# eval "$(hyak-jupyter-args.sh $@)"

# Default values:
IMAGE="${IMAGE:-docker://quay.io/jupyter/datascience-notebook:2024-10-02}"
JUPYTER_START_CMD="${JUPYTER_START_CMD:-${HOME}/bin/worker/jupyter-start.sh}"
TUNNELS_DIR="${TUNNELS_DIR:-${HOME}/.hyak-jupyter/tunnels}"
JUPYTER_ENABLE_LAB="${JUPYTER_ENABLE_LAB:-yes}"
SOCKET_NAME="${SOCKET_NAME:-default}"

OTHER_ARGS=()
while [ $# -gt 0 ]
do case "$1" in
       --image)
	   IMAGE="$2"
	   shift
	   shift
	   ;;
       --jupyer-command)
	   JUPYTER_START_CMD="$2"
	   shift
	   shift
	   ;;
       --tunnels-dir)
	   TUNNELS_DIR="$2"
	   shift
	   shift
	   ;;
       --socket-name)
	   SOCKET_NAME="$2"
	   shift
	   shift
	   ;;
       --jupyter-lab)
	   JUPYTER_ENABLE_LAB="$2"
	   shift
	   shift
	   ;;
       *)
	   OTHER_ARGS+=("$1")
	   shift
	   ;;
   esac
done

# A few of the variables like the tunnel directory come from a
# combination of the above:
TUNNEL_DIR="${TUNNELS_DIR}/${SOCKET_NAME}"
SOCKET_FILE="${TUNNEL_DIR}/socket.sock"
LOGIN_FILE="${TUNNEL_DIR}/login.sock"
JOB_FILE="${TUNNEL_DIR}/jobdata.sh"
RUN_SCRIPT="${TUNNEL_DIR}/run.sh"

echo "export IMAGE=${IMAGE}"
echo "export JUPYTER_START_CMD=${JUPYTER_START_CMD}"
echo "export TUNNELS_DIR=${TUNNELS_DIR}"
echo "export TUNNEL_NAME=${TUNNEL_NAME}"
echo "export TUNNEL_DIR=${TUNNEL_DIR}"
echo "export JUPYTER_ENABLE_LAB=${JUPYTER_ENABLE_LAB}"
echo "export SOCKET_FILE=${SOCKET_FILE}"
echo "export LOGIN_FILE=${LOGIN_FILE}"
echo "export JOB_FILE=${JOB_FILE}"
echo "export RUN_SCRIPT=${RUN_SCRIPT}"
echo "export OTHER_ARGS=(${OTHER_ARGS[@]})"

# That's all!

exit 0

