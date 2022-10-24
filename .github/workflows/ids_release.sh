#!/bin/bash

if [ $# -le 4 ]; then
    echo "  ERROR: 4 inputs required!"
    echo "    password workspace_path s"
    echo "      project: name of the project to be released"
    echo "      password: password for releasing to RDS"
    echo "      folder: path to the folder to be released"
    echo "        from the workflow workspace"
    echo "      version_number: package version number"
    echo "    release_type (optional)"
    echo "      release_type: release type, either 'dev' or 'prod' "
    exit 1
fi

echo "Releasing IDS to RDS"

if [ $# -lt 5 ]; then
    echo " Defaulting to a dev release"
    RELEASE_TYPE="dev"
else
    RELEASE_TYPE="$5"
fi

PROJECT_NAME=$2
WORKSPACE_PATH=$3
VERSION=$4
echo 'WORKSPACE_PATH =' "${WORKSPACE_PATH}"
echo 'VERSION =' "v${VERSION}"
echo 'RELEASE_TYPE =' "${RELEASE_TYPE}"

STAGE_PATH="${WORKSPACE_PATH}/dist/v${VERSION}"

# Read a parameter from the ids interface
# USAGE: exec_rds command password
read_ids_config () {
   export IDS_CONFIG_PATH=${IDS_CONFIG_PATH}
  echo "${STAGE_PATH}"/bin/ids config "$@"
}

RDS_RW_DIR_ROOT=$(export IDS_CONFIG_PATH=${IDS_CONFIG_PATH}; "${STAGE_PATH}"/bin/ids config rds paths rw_root)

TEST_RDS_DIR_ROOT=$(read_ids_config rds paths root)
echo "TEST_RDS_DIR_ROOT = ${TEST_RDS_DIR_ROOT}"

RDS_DIR_ROOT=$(ids config rds paths root)/${PROJECT_NAME}
DEVEL_DIR_ROOT=$(ids config rds paths devel_root)/${PROJECT_NAME}
RDS_RW_DIR_ROOT=$(ids config rds paths rw_root)/${PROJECT_NAME}

echo "RDS_RW_DIR_ROOT = ${RDS_RW_DIR_ROOT}"
echo "RDS_DIR_ROOT: ${RDS_DIR_ROOT}"
echo "DEVEL_DIR_ROOT: ${DEVEL_DIR_ROOT}"
DEVEL_DIR="${DEVEL_DIR_ROOT}/v${VERSION}"
echo "RDS_RW_DIR_ROOT: ${RDS_RW_DIR_ROOT}"

RDS_DIR="${RDS_DIR_ROOT}/v${VERSION}"
echo 'RDS_DIR =' "${RDS_DIR}"
DEVEL_DIR="${DEVEL_DIR_ROOT}/v${VERSION}"
echo 'DEVEL_DIR =' "${DEVEL_DIR}"
RDS_RW_DIR="${RDS_RW_DIR_ROOT}/v${VERSION}"
echo 'RDS_RW_DIR =' "${RDS_RW_DIR}"

# Release to RDS devel
rm -rf "${DEVEL_DIR}"
mkdir "${DEVEL_DIR}"
rsync -avzl "${STAGE_PATH}" "${DEVEL_DIR}"
# update symbolic links
rm -f "${DEVEL_DIR_ROOT}/dev"
ln -sf "v${VERSION}" "${DEVEL_DIR_ROOT}/dev"

# Run a command as the rds user with sudo
# USAGE: exec_rds command password
exec_rds () {
    echo "$2" | /usr/local/bin/sudo -S su - rds -c "$1"
}

# update symbolic links
exec_rds "rm -f ${RDS_RW_DIR_ROOT}/dev" "$1"
exec_rds "ln -sf v${VERSION} ${RDS_RW_DIR_ROOT}/dev" "$1"

if [ "${RELEASE_TYPE}" == "prod" ]; then
    # Release to RDS production
    rm -f "${DEVEL_DIR_ROOT}/latest"
    ln -sf "v${VERSION}" "${DEVEL_DIR_ROOT}/latest"
    
fi

exec_rds "rm -rf ${RDS_RW_DIR}" "$1"
    exec_rds "rm -rf ${RDS_RW_DIR}" "$1"
    exec_rds "mkdir ${RDS_RW_DIR}" "$1"
    exec_rds "rsync -avzl $2/IDS.cshrc ${RDS_RW_DIR}" "$1"

    exec_rds "rm -f ${RDS_RW_DIR_ROOT}/latest" "$1"
    exec_rds "ln -sf v${VERSION} ${RDS_RW_DIR_ROOT}/latest" "$1"