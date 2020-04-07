#!/bin/bash
source repos

cd ~
git clone https://github.com/marmarachain/Marmara-v.1.0.git
cd Marmara-v.1.0
git checkout master
git pull
./zcutils/build.sh
