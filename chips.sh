#!/bin/bash
source repos
cd ~
sudo apt-get update && sudo apt-get install software-properties-common autoconf git build-essential libtool libprotobuf-c-dev libgmp-dev libsqlite3-dev python python3 zip jq libevent-dev pkg-config libssl-dev libcurl4-gnutls-dev cmake -y
git clone https://github.com/jl777/chips3.git
cd chips3/
git checkout ${repos[CHIPS,1]}

CHIPS_ROOT=$(pwd)
BDB_PREFIX="${CHIPS_ROOT}/db4"
mkdir -p $BDB_PREFIX
wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef db-4.8.30.NC.tar.gz' | sha256sum -c
tar -xzvf db-4.8.30.NC.tar.gz
cd db-4.8.30.NC/build_unix/
../dist/configure -enable-cxx -disable-shared -with-pic -prefix=$BDB_PREFIX
make -j$(nproc)
make install

cd ~/chips3
./autogen.sh
./configure LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/" -without-gui -without-miniupnpc --disable-tests --disable-bench --with-gui=no
make -j$(nproc)

mkdir ~/.chips
rm ~/.chips/chips.conf
echo "server=1" >> ~/.chips/chips.conf
echo "daemon=1" >> ~/.chips/chips.conf
echo "txindex=1" >> ~/.chips/chips.conf
echo "rpcuser=user" >> ~/.chips/chips.conf
echo "rpcpassword=`head -c 32 /dev/urandom | base64`" >> ~/.chips/chips.conf
echo "addnode=159.69.23.29" >> ~/.chips/chips.conf
echo "addnode=95.179.192.102" >> ~/.chips/chips.conf
echo "addnode=149.56.29.163" >> ~/.chips/chips.conf
echo "addnode=145.239.149.173" >> ~/.chips/chips.conf
echo "addnode=178.63.53.110" >> ~/.chips/chips.conf
echo "addnode=151.80.108.76" >> ~/.chips/chips.conf
echo "addnode=185.137.233.199" >> ~/.chips/chips.conf
echo "rpcbind=127.0.0.1" >> ~/.chips/chips.conf
echo "rpcallowip=127.0.0.1" >> ~/.chips/chips.conf
echo "changeaddress=" >> ~/.chips/chips.conf
chmod 0600 ~/.chips/chips.conf

git config --global user.email "lagane.thomas@gmail.com"
git config --global user.name "3cl1ps"

sudo ln -sf /home/eclips/chips3/src/chips-cli /usr/local/bin/chips-cli
sudo ln -sf /home/eclips/chips3/src/chipsd /usr/local/bin/chipsd

chipsd &


