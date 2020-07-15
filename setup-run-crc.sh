#!/bin/bash

CRC_LOG_FILE="~/crc-start.log"
REMOTE_LOG_FILE="~/remote-config.log"

#is crc running? (crc status always returns 0)
if ! ~/bin/crc ip ; then

    sudo dnf -y install curl tar xz tmux

    #go get crc if it isn't downloaded
    echo "downloading crc"
    test -f "crc-linux-amd64.tar.xz" || curl -O -sS  \
        "https://mirror.openshift.com/pub/openshift-v4/clients/crc/latest/crc-linux-amd64.tar.xz"

    #extract crc
    echo "extracting crc"
    tar -xf crc-linux-amd64.tar.xz

    #get crc in to a runnable place
    echo "setting crc as executable"
    mkdir ~/bin || :
    ln -sf ~/crc-linux-*-amd64/crc ~/bin/crc
    grep 'PATH=$PATH:$HOME/bin' ~/.bashrc ||  \
        echo "export PATH=$PATH:$HOME/bin" >> ~/.bashrc

    #run crc setup if it hasn't been done
    echo "running crc setup"
    ~/bin/crc setup

    #run crc start directly (which will just say "done already" not error if running)
    #crc start -p ~/pull-secret > $CRC_LOG_FILE 2>&1

    #run crc start (which will just say "done already" not error if running)
    echo "running crc start in the background"
    tmux new-session -d -s 'crc-start' \
        "~/bin/crc start -p ~/pull-secret > $CRC_LOG_FILE 2>&1"

    echo "crc start is running in a tmux session in the vagrant vm. " \
        "You can check its status with vagrant ssh -c \"tail -f $CRC_LOG_FILE\""

else
    echo "crc is already running on this instance."
fi

#start script to setup remote access to crc
echo "running remote-config setup in background"
tmux new-session -d -s 'config-remote' \
        "~/configure-remote.sh > $REMOTE_LOG_FILE 2>&1"
echo "remote config shell script is running in a tmux session in the vagrant vm." \
        "You can check its status with vagrant ssh -c \"tail -f $REMOTE_LOG_FILE\""

