#!/bin/bash

function is_file() {
    local FILE_PATH=$1
    
    if [ ! -f ${FILE_PATH} ]; then
        echo 0
    else
        echo 1
    fi
}

# gets the current git branch
function parse_git_branch() {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

function parse_git_dirty() {
  git diff --quiet --ignore-submodules HEAD 2>/dev/null; [ $? -eq 1 ] && echo "*"
}

function read_version_file() {
    local VFILE=$1
    touch ${VFILE}

    local V=`cat ${VFILE}`

    if [ -z "${V}" ]; then
        V="0.0.1"
        echo "${V}" > ${VFILE}
    fi

    local V=`cat ${VFILE}`
    echo ${V}
}
