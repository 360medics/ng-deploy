#!/usr/bin/env bash
# Bash deploy script. Copyright (c) 2017 Romain Bruckert
# https://kvz.io/blog/2013/11/21/bash-best-practices/

###
# Check input arguments
##
if [ -z "${ENV}" ]; then
   echo -e "${red}✗ No argument supplied for environment (-e|--env|--environment)${nc}"
   exit 1
fi

LOCAL_VERSION_NUMBER=${CURR_VERSION}
REMOTE_VERSION_NUMBER=$(ssh ${CNF_USER}@${CNF_HOST} "cat ${CNF_BASE_REMOTE_DIR}/.version.${ENV}")

echo -e "${green}★  Version info${nc}"
echo -e "   ✓ Current local version: ${brown}${LOCAL_VERSION_NUMBER}${nc}"
echo -e "   ✓ Current live version: ${green}${REMOTE_VERSION_NUMBER}${nc}"

exit 0
