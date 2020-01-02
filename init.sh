#!/bin/bash

sudo apt-get update
sudo apt-get upgrade 
sudo apt-get install build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool ncurses-dev unzip git python zlib1g-dev wget bsdmainutils automake libboost-all-dev libssl-dev libprotobuf-dev protobuf-compiler	libqrencode-dev libdb++-dev ntp ntpdate vim software-properties-common curl libevent-dev libcurl4-gnutls-dev cmake clang lsof tmux zsh mosh htop

cd
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

mkdir .ssh
touch .ssh/authorized_keys

git clone https://github.com/nanomsg/nanomsg
cd nanomsg
cmake . -DNN_TESTS=OFF -DNN_ENABLE_DOC=OFF
make -j2
sudo make install
sudo ldconfig

git config --global user.email "lagane.thomas@gmail.com"
git config --global user.name "3cl1ps"

https://github.com/KomodoPlatform/dPoW.git
