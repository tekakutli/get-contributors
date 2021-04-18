#!/usr/bin/env bash

COMMAND=$2

#check if retrieved file is still valid
if (grep -q 'API rate limit exceeded' "$1" || [ ! -s $1 ] );then
#if (grep -q 'API rate limit exceeded' "$VARO" || cmp -s $VARO ../github-api/vacum);then
       printf "\n\n\n\n\n"
       printf "Github API download limit reached, attempt again after some hours:\n\n      \$ $COMMAND\n\nthe full fetch requires several runs\nwhen its done you will no longer see this message"
       printf "\n\n\n\n\n"
       #check the existance of this file from other scripts to see if its fine to continue, if it exists its not
       touch exit-everything
       exit 1
fi

