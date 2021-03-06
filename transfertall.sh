#!/bin/bash
#
# Usage: ./transferall <addresstotransferto>
#
# @author webworker01
#
addresstarget=$1

if [[ ! -z $addresstarget ]]; then
    echo "Usage: ./transferall <addresstotransferto>"
fi

komodo-cli sendtoaddress $addresstarget `komodo-cli getbalance` "" "" true
chips-cli sendtoaddress $addresstarget `chips-cli getbalance` "" "" true
gamecredits-cli sendtoaddress $addresstarget `gamecredits-cli getbalance` "" "" true
gincoin-cli sendtoaddress $addresstarget `gincoin-cli getbalance` "" "" true
einsteinium-cli sendtoaddress $addresstarget `einsteinium-cli getbalance` "" "" true
bitcoin-cli sendtoaddress $addresstarget `bitcoin-cli getbalance` "" "" true

/home/eclips/komodo/src/listassetchains | while read coin; do
    if [[ ! ${ignoreacs[*]} =~ ${coin} ]]; then
        balance=$(komodo-cli -ac_name=${coin} getbalance)
        echo ${coin} $balance
        komodo-cli -ac_name=${coin} sendtoaddress $addresstarget $balance "" "" true
    fi
done
