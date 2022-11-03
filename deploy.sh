#!/usr/bin/env bash
# Bash deploy script. Copyright (c) 2017 Romain Bruckert
# https://kvz.io/blog/2013/11/21/bash-best-practices/

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

###
# Set and bound variables
##
LOCAL_DIR=$PWD
DIST_DIR=${LOCAL_DIR}/dist
DIR=$(dirname $(readlink $0))
ENV=""
VERSION=""
STATUS_CMD=0

source ${DIR}/import/utils.sh
source ${DIR}/import/functions.sh

###
# Read command line arguments
###
for i in "$@"
do
case $i in
    -e=*|--env=*|--environment=*)
    ENV="${i#*=}"
    shift # past argument=value
    ;;
    -v=*|--version=*)
    VERSION="${i#*=}"
    shift
    ;;
    --status)
    STATUS_CMD=1
    shift
    ;;
    *)
    INVALID="${i#*=}"
        # unknown option(s)
        echo -e "${red}✗ Unrecognized option near arguments --> '${INVALID}'${nc}"
        exit 2
    ;;
esac
done

###
# Set path variables
###
CONFIG_FILEPATH=${LOCAL_DIR}/deploy/conf-${ENV}.cnf
VERSION_FILEPATH=${LOCAL_DIR}/.version.${ENV}
CURR_VERSION=$(read_version_file ${VERSION_FILEPATH})

if [ -z "${ENV}" ]; then
   echo -e "${red}✗ No argument supplied for environment (-e|--env|--environment)${nc}"
   exit 1
fi

###
# Import configuration
###
source ${CONFIG_FILEPATH}

###
# Check input arguments
##

if [ ${STATUS_CMD} == 1 ]; then
    source ${DIR}/status.sh
    exit 0
fi
if [ -z "${VERSION}" ]; then
    echo -e "${red}✗ No argument supplied for version (-v|--version)${nc}"
    exit 1
fi

###
# Check mandatory project files
###
if [ ! -f ${CONFIG_FILEPATH} ]; then
    echo -e "${red}✗ Config deploy file ${} does not exist at --> ${CONFIG_FILEPATH}${nc}"
    exit 2
fi

###
# Check that local angular ./dist folder exists
###
if [ ! -d ${DIST_DIR} ]; then
    echo -e "${red}✗ Local ./dist directory does not exist. Please run ng build --prod man !${nc}"
    exit 2
fi

###
# Check that local angular project config file exist
###
if [ ! -f ${CONFIG_FILEPATH} ]; then
    echo -e "${red}✗ Config deploy file ${CONFIG_FILEPATH} does not exist at --> ${CONFIG_FILEPATH}${nc}"
    exit 2
fi

###
# Set other pathes that depend on configuration
###
GIT_BRANCH=$(parse_git_branch)
REMOTE_DIR=${CNF_BASE_REMOTE_DIR}

echo -e "${green}★  Starting deployment from @${GIT_BRANCH}${nc}"

read -r -p "   ♘  Are you sure you want to deploy in [$ENV]? [y/N] " response
if [[ ${response} =~ ^([yY][eE][sS]|[yY])$ ]]
then

    echo ""

    ###
    # Synchronize all project files from local with remote.
    #
    # Note about rsync options:
    #  a combines recursive, preserve symlinks & permissions and files modification dates
    #  v mode verbose
    #  n dry run to test the command
    #  z enabled compression (to reduce network transfer)
    #  P combines --progress and --partial (progress bar and interrupted transfer resume ability)
    ###
    # create remote directory of version if it does not exist
    ssh -t ${CNF_USER}@${CNF_HOST} "test -d ${REMOTE_DIR} || mkdir ${REMOTE_DIR}" > /dev/null 2>&1

    echo -e "${green}★  Starting deployment from @${GIT_BRANCH}${nc}"
    echo -e "${brown}★  Syncing files to remote${nc}"
    rsync -avzP --delete --no-perms --no-owner --no-group --exclude deploy/ --exclude-from "${LOCAL_DIR}/deploy/exclude.txt" ${DIST_DIR}/ ${CNF_USER}@${CNF_HOST}:${REMOTE_DIR} > /dev/null 2>&1

    if [ -f "${LOCAL_DIR}/deploy/include.txt" ]; then
        echo -e "${brown}★  Uploading include.tx list${nc}"
        # force certain files (from assets uploads directories like index.html/.gitkeep files)
        rsync -avzP --delete --no-perms --no-owner --no-group --files-from "${LOCAL_DIR}/deploy/include.txt" ${DIST_DIR}/ ${CNF_USER}@${CNF_HOST}:${REMOTE_DIR} > /dev/null 2>&1
    fi

    ###
    # Write current version number in local file and remote file.
    ###
    echo "${VERSION}" > ${VERSION_FILEPATH}
    ssh -t ${CNF_USER}@${CNF_HOST} "echo '${VERSION}' > ${CNF_BASE_REMOTE_DIR}/.version.${ENV}" > /dev/null 2>&1

else
    echo -e "${red}✗  Canceled${nc}"
    exit 0
fi
