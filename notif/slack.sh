#!/usr/bin/env bash
# Bash deploy script. Copyright (c) 2017 Romain Bruckert
# https://kvz.io/blog/2013/11/21/bash-best-practices/

curl -i \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
-X POST --data '{"text":"Branch `@'"${GIT_BRANCH}"'` was deployed in `'"${ENV}"'`.\nLive version became `'"${VERSION}"'`", "username":"Alfred", "icon_url": "http://icons.iconarchive.com/icons/martin-berube/square-animal/128/Cat-icon.png"}' ${CNF_SLACK_CHANEL_URL} > /dev/null 2>&1
