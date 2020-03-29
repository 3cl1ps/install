#!/bin/bash
#
# @author webworker01
#

if [ "$EUID" -ne 0 ]; then
    echo -e "\e[41mrun as root...\e[0m"
    exit
fi

sudo apt-get install -y locales
sudo locale-gen "en_US.UTF-8"
sudo update-locale LC_ALL="en_US.UTF-8"
export LC_ALL=en_US.UTF-8

apt-get update     
sudo apt-get upgrade 
sudo apt-get install -y fail2ban ufw curl libsodium-dev bash-completion htop jq bc build-essential pkg-config libc6-dev m4 g++-multilib bc autoconf libtool ncurses-dev unzip git python zlib1g-dev wget bsdmainutils automake libboost-all-dev libssl-dev libprotobuf-dev protobuf-compiler	libqrencode-dev libdb++-dev ntp ntpdate vim software-properties-common curl libevent-dev libcurl4-gnutls-dev cmake clang lsof tmux zsh mosh htop

echo -e "\e[41mAdd non-root sudo user eclips\e[0m"
useradd -m eclips
adduser eclips sudo
passwd eclips
sudo chsh eclips -s /bin/bash
read -p "Please enter the public key (include the ssh-rsa prefix and also a label if desired) for eclips (enter to skip - not recommended): " NEWUSERPUBKEY
if [[ ! -z "$NEWUSERPUBKEY" ]]; then
    mkdir -p /home/eclips/.ssh/
    echo "$NEWUSERPUBKEY" >> /home/eclips/.ssh/authorized_keys
    chmod -R 700 /home/eclips/.ssh/
    chown -R eclips:eclips /home/eclips/.ssh/

    read -p "Please login with the SSH key on the new user now in a separate terminal to verify connectivity. Have you completed this? (Warning! After pressing yes here password based authentication will be disabled!) (y/n) " -n 1 TESTEDCONNECTIVITY
    echo
    if [[ $TESTEDCONNECTIVITY =~ ^[Yy]$ ]]; then
        grep -q "^[#]*PubkeyAuthentication" /etc/ssh/sshd_config && sed -i "/^[#]*PubkeyAuthentication/c\PubkeyAuthentication yes" /etc/ssh/sshd_config || echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
        grep -q "^[#]*ChallengeResponseAuthentication" /etc/ssh/sshd_config && sed -i "/^[#]*ChallengeResponseAuthentication/c\ChallengeResponseAuthentication no" /etc/ssh/sshd_config || echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
        grep -q "^[#]*PasswordAuthentication" /etc/ssh/sshd_config && sed -i "/^[#]*PasswordAuthentication/c\PasswordAuthentication no" /etc/ssh/sshd_config || echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

        systemctl restart sshd.service
    else
        echo -e "\e[41mSorry, it won't be safe to do the final steps here then... take care.\e[0m"
    fi
fi

grep -q "^[#]*PermitRootLogin" /etc/ssh/sshd_config && sed -i "/^[#]*PermitRootLogin/c\PermitRootLogin no" /etc/ssh/sshd_config || echo "PermitRootLogin no" >> /etc/ssh/sshd_config
