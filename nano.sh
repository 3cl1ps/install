#!/bin/bash
sudo apt-get update
sudo apt-get -y install build-essential pkg-config git libc6-dev m4 g++-multilib autoconf libtool ncurses-dev unzip python zlib1g-dev wget bsdmainutils automake libssl-dev libprotobuf-dev protobuf-compiler libqrencode-dev ntp ntpdate software-properties-common curl libcurl4-openssl-dev cmake clang libevent-dev libboost-all-dev

cd ~
git clone https://github.com/nanomsg/nanomsg
cd nanomsg
cmake . -DNN_TESTS=OFF -DNN_ENABLE_DOC=OFF
make -j2
sudo make install
sudo ldconfig
