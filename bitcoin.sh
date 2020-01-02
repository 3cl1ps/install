#!/bin/bash

buildbtc () {
  cd ~
  wget https://bitcoincore.org/bin/bitcoin-core-0.16.3/bitcoin-0.16.3-x86_64-linux-gnu.tar.gz
  tar xvzf bitcoin-0.16.3-x86_64-linux-gnu.tar.gz
}

confsetup () {

  mkdir ~/.bitcoin
  rm ~/.bitcoin/bitcoin.conf
  echo "server=1" >> ~/.bitcoin/bitcoin.conf
  echo "daemon=1" >> ~/.bitcoin/bitcoin.conf
  echo "txindex=1" >> ~/.bitcoin/bitcoin.conf
  echo "rpcuser=bitcoinrpc" >> ~/.bitcoin/bitcoin.conf
  echo "rpcpassword=`head -c 32 /dev/urandom | base64`" >> ~/.bitcoin/bitcoin.conf
  echo "bind=127.0.0.1" >> ~/.bitcoin/bitcoin.conf
  echo "rpcbind=127.0.0.1" >> ~/.bitcoin/bitcoin.conf
  echo "rpcallowip=127.0.0.1" >> ~/.bitcoin/bitcoin.conf
  echo "datadir=/bitcoin/" >> ~/.bitcoin/bitcoin.conf
  
  chmod 0600 ~/.bitcoin/bitcoin.conf
}

cd ~
confsetup
buildbtc

sudo ln -sf /home/eclips/bitcoin-0.16.3/bin/bitcoind /usr/local/bin/bitcoind
sudo ln -sf /home/eclips/bitcoin-0.16.3/bin/bitcoin-cli /usr/local/bin/bitcoin-cli
bitcoind
