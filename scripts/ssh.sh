#!/bin/bash

#############################
# Creating External Volumes #
#############################

echo -e "\n\033[35m==========  Creating External Volume (ssh)  ==========\n\033[37m"

if [ ! "$(docker volume ls | grep ssh-agent-data)" ]; then
    docker run -u 1000 -d --restart always -v ssh-agent-data:/ssh --name=ssh-agent whilp/ssh-agent
fi

docker run -u 1000 --rm -v ssh-agent-data:/ssh -v $HOME:$HOME -it whilp/ssh-agent:latest ssh-add $HOME/$SSH_KEY_PATH
echo -e "\033[32m ✔ Success\n\033[37m"
