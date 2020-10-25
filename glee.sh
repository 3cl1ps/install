#!/bin/bash
# GleecBTC build script for Ubuntu & Debian 9 v.3 (c) Decker (and webworker)
berkeleydb () {
    GleecBTC_ROOT=$(pwd)
    GleecBTC_PREFIX="${GleecBTC_ROOT}/db4"
    mkdir -p $GleecBTC_PREFIX
    wget -N 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
    echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef db-4.8.30.NC.tar.gz' | sha256sum -c
    tar -xzvf db-4.8.30.NC.tar.gz
    cat <<-EOL >atomic-builtin-test.cpp
        #include <stdint.h>
        #include "atomic.h"

        int main() {
        db_atomic_t *p; atomic_value_t oldval; atomic_value_t newval;
        __atomic_compare_exchange(p, oldval, newval);
        return 0;
        }
EOL
    if g++ atomic-builtin-test.cpp -I./db-4.8.30.NC/dbinc -DHAVE_ATOMIC_SUPPORT -DHAVE_ATOMIC_X86_GCC_ASSEMBLY -o atomic-builtin-test 2>/dev/null; then
        echo "No changes to bdb source are needed ..."
        rm atomic-builtin-test 2>/dev/null
    else
        echo "Updating atomic.h file ..."
        sed -i 's/__atomic_compare_exchange/__atomic_compare_exchange_db/g' db-4.8.30.NC/dbinc/atomic.h
    fi
    cd db-4.8.30.NC/build_unix/
    ../dist/configure -enable-cxx -disable-shared -with-pic -prefix=$GleecBTC_PREFIX
    make install
    cd $GleecBTC_ROOT
}
buildGleecBTC () {
    git pull
    ./autogen.sh
    ./configure LDFLAGS="-L${GleecBTC_PREFIX}/lib/" CPPFLAGS="-I${GleecBTC_PREFIX}/include/" --with-gui=no --disable-tests --disable-bench --without-miniupnpc --enable-experimental-asm --enable-static --disable-shared --with-incompatible-bdb
    make -j$(nproc)
}

cd ~
mkdir .gleecbtc
rm ~/.gleecbtc/gleecbtc.conf
echo "server=1" >> ~/.gleecbtc/gleecbtc.conf
echo "daemon=1" >> ~/.gleecbtc/gleecbtc.conf
echo "txindex=1" >> ~/.gleecbtc/gleecbtc.conf
echo "rpcuser=user" >> ~/.gleecbtc/gleecbtc.conf
echo "rpcpassword=`head -c 32 /dev/urandom | base64`" >> ~/.gleecbtc/gleecbtc.conf
echo "addnode=159.69.23.29" >> ~/.gleecbtc/gleecbtc.conf
echo "bind=127.0.0.1" >> ~/.gleecbtc/gleecbtc.conf
echo "rpcbind=127.0.0.1" >> ~/.gleecbtc/gleecbtc.conf
echo "rpcallowip=127.0.0.1" >> ~/.gleecbtc/gleecbtc.conf
echo "changeaddress=" >> ~/.gleecbtc/gleecbtc.conf
chmod 0600 ~/.gleecbtc/gleecbtc.conf

berkeleydb
buildGleecBTC
echo "Done building GleecBTC!"
sudo ln -sf /home/$USER/GleecBTC-FullNode-Win-Mac-Linux/src/gleecbtc-cli /usr/local/bin/gleecbtc-cli
sudo ln -sf /home/$USER/GleecBTC-FullNode-Win-Mac-Linux/src/gleecbtcd /usr/local/bin/gleecbtcd

/home/eclips/GleecBTC-FullNode-Win-Mac-Linux/src/gleecbtcd &
