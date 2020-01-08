#!/bin/bash

read -p "Enter hostname: " NEWHOSTNAME
sudo echo "$NEWHOSTNAME" > /etc/hostname
sudo sed -i "1i127.0.0.1 ${NEWHOSTNAME}" /etc/hosts

read -p "Add non-root sudo user? (y/n) " -n 1 DONONROOT
echo
if [[ $DONONROOT =~ ^[Yy]$ ]]; then
    read -p "Enter user name: " NEWUSERNAME
    echo
    useradd -m $NEWUSERNAME
    adduser $NEWUSERNAME sudo
    passwd $NEWUSERNAME
    sudo chsh $NEWUSERNAME -s /bin/bash

    grep -q "^[#]*force_color_prompt=" /home/$NEWUSERNAME/.bashrc && sed -i "/^[#]*force_color_prompt=/c\force_color_prompt=yes" /home/$NEWUSERNAME/.bashrc

    source /home/$NEWUSERNAME/.bashrc

    read -p "Please enter the public key (include the ssh-rsa prefix and also a label if desired) for $NEWUSERNAME (enter to skip - not recommended): " NEWUSERPUBKEY
    if [[ ! -z "$NEWUSERPUBKEY" ]]; then
        mkdir -p /home/$NEWUSERNAME/.ssh/
        echo "$NEWUSERPUBKEY" >> /home/$NEWUSERNAME/.ssh/authorized_keys
        chmod -R 700 /home/$NEWUSERNAME/.ssh/
        chown -R $NEWUSERNAME:$NEWUSERNAME /home/$NEWUSERNAME/.ssh/

        read -p "Copy key to root user? " -n 1 DOROOTKEY
        if [[ $DOROOTKEY =~ ^[Yy]$ ]]; then
            mkdir -p /root/.ssh
            cp /home/$NEWUSERNAME/.ssh/authorized_keys /root/.ssh/
            chown -R root:root /root/.ssh/
            chmod -R 700 /root/.ssh/
        fi

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

    read -p "Disable root login? " -n 1 DOROOTDISABLE
    echo
    if [[ $DOROOTDISABLE =~ ^[Yy]$ ]]; then
        grep -q "^[#]*PermitRootLogin" /etc/ssh/sshd_config && sed -i "/^[#]*PermitRootLogin/c\PermitRootLogin no" /etc/ssh/sshd_config || echo "PermitRootLogin no" >> /etc/ssh/sshd_config
    fi
fi

sudo apt-get update
sudo apt-get upgrade 
sudo apt-get install -y build-essential pkg-config libc6-dev m4 g++-multilib bc autoconf libtool ncurses-dev unzip git python zlib1g-dev wget bsdmainutils automake libboost-all-dev libssl-dev libprotobuf-dev protobuf-compiler	libqrencode-dev libdb++-dev ntp ntpdate vim software-properties-common curl libevent-dev libcurl4-gnutls-dev cmake clang lsof tmux zsh mosh htop

cd
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

mkdir .ssh
touch .ssh/authorized_keys

git clone https://github.com/nanomsg/nanomsg
cd nanomsg
cmake . -DNN_TESTS=OFF -DNN_ENABLE_DOC=OFF
make -j2
sudo make install
sudo ldconfig

git config --global user.email "lagane.thomas@gmail.com"
git config --global user.name "3cl1ps"

git clone https://github.com/KomodoPlatform/dPoW.git

sudo apt-get install -y locales
sudo locale-gen "en_US.UTF-8"
sudo update-locale LC_ALL="en_US.UTF-8"
export LC_ALL=en_US.UTF-8

