#!/bin/bash

sudo apt-get install build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool libncurses-dev unzip git python zlib1g-dev wget bsdmainutils automake libboost-all-dev libssl-dev libprotobuf-dev protobuf-compiler libgtest-dev libqt4-dev libqrencode-dev libdb++-dev ntp ntpdate software-properties-common libevent-dev curl libcurl4-gnutls-dev cmake clang libsodium-dev jq htop -y
rm -rf komodo
cd ~/
git clone https://github.com/KomodoPlatform/komodo
cd ~/komodo
git checkout beta
./zcutil/fetch-params.sh
./zcutil/build.sh -j8
mkdir ~/.komodo
rm ~/.komodo/komodo.conf
echo "rpcuser=`head -c 32 /dev/urandom | base64`" >> ~/.komodo/komodo.conf
echo "rpcpassword=`head -c 32 /dev/urandom | base64`" >> ~/.komodo/komodo.conf
echo "txindex=1" >> ~/.komodo/komodo.conf
echo "server=1" >> ~/.komodo/komodo.conf
echo "daemon=1" >> ~/.komodo/komodo.conf
echo "rpcworkqueue=256" >> ~/.komodo/komodo.conf
echo "rpcbind=127.0.0.1" >> ~/.komodo/komodo.conf
echo "rpcallowip=127.0.0.1" >> ~/.komodo/komodo.conf
#echo "whitelistaddress=RFQNjTfcvSAmf8D83og1NrdHj1wH2fc5X4" >> ~/.komodo/komodo.conf
#echo "whitelistaddress=RYJLF5h4gPe527RyqqcgiiD93GwYbUmL9o" >> ~/.komodo/komodo.conf
#echo "whitelistaddress=RUaRqxuNc7a5MqsW3T19bfJUmmKFQtGHtr" >> ~/.komodo/komodo.conf
#echo "whitelistaddress=RPknkGAHMwUBvfKQfvw9FyatTZzicSiN4y" >> ~/.komodo/komodo.conf
#echo "whitelistaddress=RMqbQz4NPNbG15QBwy9EFvLn4NX5Fa7w5g" >> ~/.komodo/komodo.conf
#echo "whitelistaddress=RTZqkgcLLT2w7RtgxxCz4eFoGtFiq2YUY1" >> ~/.komodo/komodo.conf
#echo "whitelistaddress=RQipE6ycbVVb9vCkhqrK8PGZs2p5YmiBtg" >> ~/.komodo/komodo.conf
#echo "whitelistaddress=RV4SqkaYAJajvqNANve8f4JoLS5BJZMf7E" >> ~/.komodo/komodo.conf
#echo "whitelistaddress=bDnbcXrZ4iMqfnybMgKjWvYosRzgVMToF8" >> ~/.komodo/komodo.conf
chmod 0600 ~/.komodo/komodo.conf

sudo ln -sf /home/eclips/komodo/src/komodo-cli /usr/local/bin/komodo-cli
sudo ln -sf /home/eclips/komodo/src/komodod /usr/local/bin/komodod

komodod &
