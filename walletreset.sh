#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

# Coin we're resetting
# e.g "KMD"
coin=$1

# Full daemon comand with arguments
# e.g "komodod -notary -pubkey=<pubkey>"
daemon=$2

# Daemon process regex to grep processes while we're waiting for it to exit
# e.g "komodod.*\-notary"
daemon_process_regex=$3

# Path to daemon cli
# e.g "komodo-cli"
cli=$4

# Path to wallet.dat
# e.g "${HOME}/.komodo/wallet.dat"
wallet_file=$5

# Address containing all your funds
# e.g "RPxsaGNqTKzPnbm5q7QXwu7b6EZWuLxJG3"
address=$6

date=$(date +%Y-%m-%d:%H:%M:%S)

if [[ "${coin}" = "PIRATE" ]]; then
    echo "[${coin}] ERROR: Cannot reset ${coin} wallet with this method"
    exit 1
fi

echo "[${coin}] Resetting ${coin} wallet - ${date}"

waitforconfirm () {
    confirmations=0
    while [[ ${confirmations} -lt 1 ]]; do
        sleep 1
        confirmations=$(${cli} gettransaction $1 | jq -r .confirmations)
        # Keep re-broadcasting
        ${cli} sendrawtransaction $(${cli} getrawtransaction $1) > /dev/null 2>&1
    done
}

function do_send()
{
    RESULT=$(${cli} sendtoaddress $address $BALANCE "" "" true 2>&1)
    ERRORLEVEL=$?
}

function get_balance()
{
    #echo $komodo_cli $asset getbalance
    BALANCE=$(${cli} getbalance 2>/dev/null)
    ERRORLEVEL=$?

    if [ "$ERRORLEVEL" -eq "0" ] && [ "$BALANCE" != "0.00000000" ]; then
        echo -e "(${GREEN}$coin${RESET}) $BALANCE"
    else
        BALANCE="0.00000000"
        echo -e "(${RED}$coin${RESET}) $BALANCE"
    fi
}

echo "[${coin}] Saving the main address privkey to reimport later"
privkey=$(${cli} dumpprivkey ${address})
if [ "$?" -ne "0" ]; then
    exit
fi

get_balance
if (( $(echo "$BALANCE > 0" |bc -l) )); then
    echo "[${coin}] Unlocking all UTXOs"
    ./unlockutxos.sh ${coin}
    
    #disable generate to avoid daemon crash during multiple "error adding notary vin" messages
    echo "[${coin}] Setgenerate false"
    ${cli} setgenerate false
    echo "[${coin}] Sending entire balance"
    do_send

    while [ "$ERRORLEVEL" -ne "0" ]
    do
        if [[ $RESULT =~ "Transaction too large" ]]; then
            BALANCE=$(printf %f $(bc -l <<< "scale=8;$BALANCE*0.1"))
            echo "TX to large. Now trying to send ten 10% chunks of $BALANCE"
            counter=1
            while [ $counter -le 10 ]
            do
                do_send
                echo "txid: $RESULT"
                ((counter++))
            done
            echo "Sending whole balance again..."
            sleep 3
            get_balance
            do_send
        else
            echo "ERROR: $RESULT"
            exit
        fi
    done
    echo "txid: $RESULT"

    echo "[${coin}] Waiting for confirmation of sent funds"
    waitforconfirm ${RESULT}
    blockhash=$(${cli} gettransaction $RESULT | jq -r .blockhash)
    height=$(${cli} getblock $blockhash | jq .height)
    echo "[${coin}] Sent funds confirmed, height : $height"
fi

echo "[${coin}] Stopping the deamon"
${cli} stop

stopped=0
while [[ ${stopped} -eq 0 ]]; do
    sleep 1
    pgrep -af "${daemon_process_regex}" | grep -v "$0" > /dev/null 2>&1
    outcome=$(echo $?)
    if [[ ${outcome} -ne 0 ]]; then
        stopped=1
    fi
done

echo "[${coin}] Removing wallet file"
rm "${wallet_file}"

echo "[${coin}] Restarting the daemon"
${daemon} > /dev/null 2>&1 &

started=0
while [[ ${started} -eq 0 ]]; do
    sleep 1
    ${cli} getbalance > /dev/null 2>&1
    outcome=$(echo $?)
    if [[ ${outcome} -eq 0 ]]; then
        started=1
    fi
done

echo "[${coin}] Importing the main privkey but without rescanning"
${cli} importprivkey ${privkey} "" true $height

echo "[${coin}] Running UTXO splitter"
/home/eclips/install/acsplit ${coin} 30 > /dev/null 2>&1 &

echo "[${coin}] Wallet reset complete!"
