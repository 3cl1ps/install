export toolsdir=/home/eclips/tools_
export PUBKEY=$(cat $toolsdir/pubkey.txt)
echo "PUBKEY = $PUBKEY"
echo "__________________________________________________________"
ps -ef| grep notary| grep -v grep
ps -ef| grep bitcoind| grep -v grep
ps -ef| grep chipsd| grep -v grep
ps -ef| grep gamecreditsd| grep -v grep
ps -ef| grep erus| grep -v grep
ps -ef| grep hush| grep -v grep
ps -ef| grep einsteiniumd| grep -v grep
ps -ef| grep gincoind| grep -v grep
echo "__________________________________________________________"
$toolsdir/checkpull
$toolsdir/walletsize.sh
echo "__________________________________________________________"
$toolsdir/status.sh
