#!/bin/bash
#
# Usage: ./transferall <addresstotransferto>
#
# @author webworker01
#
source coinlist
addresstarget=$1

if [[ ! -z $addresstarget ]]; then
    echo "Usage: ./transferall <addresstotransferto>"
fi

$komodocli sendtoaddress $addresstarget `komodo-cli getbalance` "" "" true
chips-cli sendtoaddress $addresstarget `chips-cli getbalance` "" "" true
gamecredits-cli sendtoaddress $addresstarget `gamecredits-cli getbalance` "" "" true
gincoin-cli sendtoaddress $addresstarget `gincoin-cli getbalance` "" "" true
einsteinium-cli sendtoaddress $addresstarget `einsteinium-cli getbalance` "" "" true
hush-cli sendtoaddress $addresstarget `hush-cli getbalance` "" "" true

for coins in "${coinlist[@]}"; do
    coin=($coins)
    if [[ ! ${ignoreacs[*]} =~ ${coin[0]} ]]; then
        balance=$($komodocli -ac_name=${coin[0]} getbalance)
        echo ${coin[0]} $balance
        $komodocli -ac_name=${coin[0]} sendtoaddress $addresstarget $balance "" "" true
    fi
