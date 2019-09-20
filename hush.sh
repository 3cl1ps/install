#!/bin/bash
sudo apt-get update
cd ~
git clone https://github.com/MyHush/hush3
cd hush3
git checkout master
./zcutil/build.sh -j$(nproc)

sudo ln -sf /home/eclips/hush3/src/hush-cli /usr/local/bin/hush-cli
sudo ln -sf /home/eclips/hush3/src/hushd /usr/local/bin/hushd

/home/eclips/hush3/src/hushd -pubkey=$PUBKEY &
