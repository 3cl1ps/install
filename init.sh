#!/bin/bash
#
# @author webworker01
#

if [ "$EUID" -ne 0 ]; then
    echo -e "\e[41mPlease use sudo or run as root...\e[0m"
    exit
fi

read -p "Configure timezone & locale? (y/n) " -n 1 DOLOCALE
echo
if [[ $DOLOCALE =~ ^[Yy]$ ]]; then
        sudo apt-get install -y locales
        sudo locale-gen "en_US.UTF-8"
        sudo update-locale LC_ALL="en_US.UTF-8"
        export LC_ALL=en_US.UTF-8
fi

read -p "Install extra tools? (y/n) " -n 1 DOEXTRAS
echo
if [[ $DOEXTRAS =~ ^[Yy]$ ]]; then
    apt-get update     
    sudo apt-get upgrade 
    sudo apt-get install -y fail2ban ufw curl bash-completion htop jq bc build-essential pkg-config libc6-dev m4 g++-multilib bc autoconf libtool ncurses-dev unzip git python zlib1g-dev wget bsdmainutils automake libboost-all-dev libssl-dev libprotobuf-dev protobuf-compiler	libqrencode-dev libdb++-dev ntp ntpdate vim software-properties-common curl libevent-dev libcurl4-gnutls-dev cmake clang lsof tmux zsh mosh htop
fi

echo -e "\e[41mAdd non-root sudo user eclips\e[0m"
    useradd -m eclips
    adduser eclips sudo
    passwd eclips
    sudo chsh eclips -s /bin/bash
    read -p "Please enter the public key (include the ssh-rsa prefix and also a label if desired) for $NEWUSERNAME (enter to skip - not recommended): " NEWUSERPUBKEY
    if [[ ! -z "$NEWUSERPUBKEY" ]]; then
        mkdir -p /home/eclips/.ssh/
        echo "$NEWUSERPUBKEY" >> /home/eclips/.ssh/authorized_keys
        chmod -R 700 /home/eclps/.ssh/
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

su eclips
    cd
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/gpakosz/.tmux.git
    ln -s -f .tmux/.tmux.conf
    cp .tmux/.tmux.conf.local .
    /home/eclips/install/nano.sh 
    git config --global user.email "lagane.thomas@gmail.com"
    git config --global user.name "3cl1ps"
   grep -q "^[#]*force_color_prompt=" /home/eclips/.bashrc && sed -i "/^[#]*force_color_prompt=/c\force_color_prompt=yes" /home/eclips/.bashrc
    source /home/eclips/.bashrc
    
cat <<EOF > $HOME/.vimrc
if empty(glob('~/.vim/autoload/plug.vim')) 
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs 
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC 
endif 
call plug#begin('~/.vim/plugged') 
Plug 'neomake/neomake' 
call plug#end() 
 
" When writing a buffer (no delay). 
call neomake#configure#automake('w') 
" " When writing a buffer (no delay), and on normal mode changes (after 
" 750ms). 
call neomake#configure#automake('nw', 750) 
" " When reading a buffer (after 1s), and when writing (no delay). 
call neomake#configure#automake('rw', 1000) 
" " Full config: when writing or reading a buffer, and on changes in insert 
" and 
" " normal mode (after 500ms; no delay when writing). 
call neomake#configure#automake('nrwi', 500) 
 
filetype plugin indent on 
" show existing tab with 4 spaces width 
set tabstop=4 
" when indenting with '>', use 4 spaces width 
set shiftwidth=4 
" On pressing tab, insert 4 spaces 
set expandtab 
EOF

read -p "Update hostname? (y/n) " -n 1 DOHOSTNAME
echo
if [[ $DOHOSTNAME =~ ^[Yy]$ ]]; then
    read -p "Enter hostname: " NEWHOSTNAME
    
    case "$NEWHOSTNAME" in
        indenodes_ae)
            cat <<EOF > $HOME/.bash_profile
            export PUBKEY=02ec0fa5a40f47fd4a38ea5c89e375ad0b6ddf4807c99733c9c3dc15fb978ee147
            export KMDADDRESS="RFQNjTfcvSAmf8D83og1NrdHj1wH2fc5X4"
            export HUSHADDRESS="t1PznfHCUHw9oBktpX4W1R9Q1DQfm9jRoSi"
            export BTCADDRESS="178BewnLKcNCb7qvadgtHLJ5xkUgK9ifFY"
            export REFNODE="34"
            export EDITOR=vi
            if [[ -z "$TMUX" ]] && [ "$SSH_CONNECTION" != "" ]; then
                tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
            fi
            cd /home/eclips/tools && git pull >/dev/null; cd /home/eclips/install && git pull >/dev/null; cd
            alias psgrep="ps aux | grep -v grep | grep"
            EOF
            ;;   
        indenodes_eu)
            cat <<EOF > $HOME/.bash_profile
            export PUBKEY=0221387ff95c44cb52b86552e3ec118a3c311ca65b75bf807c6c07eaeb1be8303c
            export KMDADDRESS="RPknkGAHMwUBvfKQfvw9FyatTZzicSiN4y"
            export HUSHADDRESS="t1YMCg5h8jSTDTJ179Bm9JGMbwxjCkV7SHM"
            export BTCADDRESS="1FUbfkGzm7fcrexDCkx2ATFghJY7u7nZf8"
            export REFNODE="44"
            export EDITOR=vi
            if [[ -z "$TMUX" ]] && [ "$SSH_CONNECTION" != "" ]; then
                tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
            fi
            cd /home/eclips/tools && git pull >/dev/null; cd /home/eclips/install && git pull >/dev/null; cd
            alias psgrep="ps aux | grep -v grep | grep"
            ;;
        indenodes_na)
            cat <<EOF > $HOME/.bash_profile
            export PUBKEY=02698c6f1c9e43b66e82dbb163e8df0e5a2f62f3a7a882ca387d82f86e0b3fa988
            export KMDADDRESS="RMqbQz4NPNbG15QBwy9EFvLn4NX5Fa7w5g"
            export HUSHADDRESS="t1WS1LobDksaHXi5tRDyEJD7VYmFZLYwShR"
            export BTCADDRESS="1DZQLUB5nYngw52zUoA7AQ1aJ74UXr4nBF"
            export REFNODE="11"
            export EDITOR=vi
            if [[ -z "$TMUX" ]] && [ "$SSH_CONNECTION" != "" ]; then
                tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
            fi
            cd /home/eclips/tools && git pull >/dev/null; cd /home/eclips/install && git pull >/dev/null; cd
            alias psgrep="ps aux | grep -v grep | grep"
            ;;
        indenodes_sh)
            cat <<EOF > $HOME/.bash_profile
            export PUBKEY=0334e6e1ec8285c4b85bd6dae67e17d67d1f20e7328efad17ce6fd24ae97cdd65e
            export KMDADDRESS="RQipE6ycbVVb9vCkhqrK8PGZs2p5YmiBtg"
            export HUSHADDRESS="t1ZKE9vWTxzUcgYtTB6gKAg3HMRYZggeueC"
            export BTCADDRESS="1GSd9b6Kzfh25uqZEfsC2rwN6mMUvwuLGi"
            export REFNODE="44"
            export EDITOR=vi
            if [[ -z "$TMUX" ]] && [ "$SSH_CONNECTION" != "" ]; then
                tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
            fi
            cd /home/eclips/tools && git pull >/dev/null; cd /home/eclips/install && git pull >/dev/null; cd
            alias psgrep="ps aux | grep -v grep | grep"
            ;;
        indenodes_ae2)
            cat <<EOF > $HOME/.bash_profile
            export PUBKEY="0242778789986d614f75bcf629081651b851a12ab1cc10c73995b27b90febb75a2"
            export KMDADDRESS="RYJLF5h4gPe527RyqqcgiiD93GwYbUmL9o"
            export EMC2ADDRESS="EgB3f9eHWX8QwQfeBWd5dKru3ez5Jb4qbf"
            export GAMEADDRESS="Ggs4ah8j4RSo2aN5JcHg3xDqCBGnraTT49"
            export REFNODE="34"
            export EDITOR=vi
            if [[ -z "$TMUX" ]] && [ "$SSH_CONNECTION" != "" ]; then
                tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
            fi
            cd /home/eclips/tools2 && git pull >/dev/null; cd /home/eclips/install && git pull >/dev/null; cd
            ;;   
        indenodes_eu2)
            cat <<EOF > $HOME/.bash_profile
            export PUBKEY="03a416533cace0814455a1bb1cd7861ce825a543c6f6284a432c4c8d8875b7ace9"
            export KMDADDRESS="RUaRqxuNc7a5MqsW3T19bfJUmmKFQtGHtr"
            export EMC2ADDRESS="EcT9G2rbSF4RH97AP81YWGxEn9MnHjpH3j"
            export GAMEADDRESS="Gd9ABaM2z9NoNJobWDg8vuKAvfeVoKqn5b"
            export REFNODE="6"
            export EDITOR=vi
            if [[ -z "$TMUX" ]] && [ "$SSH_CONNECTION" != "" ]; then
                tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
            fi
            cd /home/eclips/tools2 && git pull >/dev/null; cd /home/eclips/install && git pull >/dev/null; cd
            ;;
        indenodes_na2)
            cat <<EOF > $HOME/.bash_profile
            export PUBKEY=02b3908eda4078f0e9b6704451cdc24d418e899c0f515fab338d7494da6f0a647b
            export KMDADDRESS="RTZqkgcLLT2w7RtgxxCz4eFoGtFiq2YUY1"
            export EMC2ADDRESS="EbSZAkZZAaXH2j8MJdDNyFuZHGJFfNU59G"
            export GAMEADDRESS="Gc8a6J3ziUqf7tpnRisyPtGVRnayDdXBox"
            export REFNODE="11"
            export editor=vi
            if [[ -z "$TMUX" ]] && [ "$SSH_CONNECTION" != "" ]; then
                tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
            fi
            cd /home/eclips/tools2 && git pull >/dev/null; cd /home/eclips/install && git pull >/dev/null; cd
            ;;
        indenodes_sh2)
            cat <<EOF > $HOME/.bash_profile
            export PUBKEY="031d1584cf0eb4a2d314465e49e2677226b1615c3718013b8d6b4854c15676a58c"
            export KMDADDRESS="RV4SqkaYAJajvqNANve8f4JoLS5BJZMf7E"
            export EMC2ADDRESS="EcwAFpXkzS55r8bpibeXZfxZLp7i7AywPd"
            export GAMEADDRESS="GddBBN2CYLPTwJJFqhK7zJKVVLQRdTRDGz"
            export REFNODE="44"
            export EDITOR=vi
            if [[ -z "$TMUX" ]] && [ "$SSH_CONNECTION" != "" ]; then
                tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
            fi
            cd /home/eclips/tools2 && git pull >/dev/null; cd /home/eclips/install && git pull >/dev/null; cd
            ;;
        *)
            echo "Usage: $0 {indenodes_XXY}"
            exit 1
    esac
    echo "$NEWHOSTNAME" > /etc/hostname
    sed -i "1i127.0.0.1 ${NEWHOSTNAME}" /etc/hosts
fi
