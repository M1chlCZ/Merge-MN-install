#!/bin/bash

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -a | --advanced)
        ADVANCED="y"
        shift
        ;;
    -n | --normal)
        ADVANCED="n"
        FAIL2BAN="y"
        UFW="y"
        BOOTSTRAP="y"
        shift
        ;;
    -i | --externalip)
        EXTERNALIP="$2"
        ARGUMENTIP="y"
        shift
        shift
        ;;
    -k | --privatekey)
        KEY="$2"
        shift
        shift
        ;;
    -f | --fail2ban)
        FAIL2BAN="y"
        shift
        ;;
    --no-fail2ban)
        FAIL2BAN="n"
        shift
        ;;
    -u | --ufw)
        UFW="y"
        shift
        ;;
    --no-ufw)
        UFW="n"
        shift
        ;;
    -b | --bootstrap)
        BOOTSTRAP="y"
        shift
        ;;
    --no-bootstrap)
        BOOTSTRAP="n"
        shift
        ;;
    -s | --swap)
        SWAP="y"
        shift
        ;;
    --no-swap)
        SWAP="n"
        shift
        ;;
    -h | --help)
        cat <<EOL
CCASH Masternode installer arguments:
    -n --normal               : Run installer in normal mode
    -a --advanced             : Run installer in advanced mode
    -i --externalip <address> : Public IP address of VPS
    -k --privatekey <key>     : Private key to use
    -f --fail2ban             : Install Fail2Ban
    --no-fail2ban             : Don't install Fail2Ban
    -u --ufw                  : Install UFW
    --no-ufw                  : Don't install UFW
    -b --bootstrap            : Sync node using Bootstrap
    --no-bootstrap            : Don't use Bootstrap
    -h --help                 : Display this help text.
    -s --swap                 : Create swap for <2GB RAM
EOL
        exit
        ;;
    *)                     # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

clear

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# Install tools for dig and systemctl
echo "Preparing installation..."
apt-get install git dnsutils systemd -y >/dev/null 2>&1
killall Campusd >/dev/null 2>&1

# Check for systemd
systemctl --version >/dev/null 2>&1 || {
    echo "systemd is required. Are you using Ubuntu 16.04?" >&2
    exit 1
}

# Getting external IP
if [ -z "$EXTERNALIP" ]; then
    EXTERNALIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
fi
clear

if [ -z "$ADVANCED" ]; then

    cat <<"EOF"
------------------MERGE MN SETUP-----------------  
EOF

    echo "

     +---------MASTERNODE INSTALLER v1 ---------+
 |                                                  |
 | You can choose between two installation options: |::
 |              default and advanced.               |::
 |                                                  |::
 |  The advanced installation will install and run  |::
 |   the masternode under a non-root user. If you   |::
 |   don't know what that means, use the default    |::
 |               installation method.               |::
 |                                                  |::
 |  Otherwise, your masternode will not work, and   |::
 |    the MERGE Team WILL NOT assist you in         |::
 |                 repairing it.                    |::
 |                                                  |::
 |           You will have to start over.           |::
 |                                                  |::
 +--------------------------------------------------+
 ::::::::::::::::::::::::::::::::::::::::::::::::::::

"

    sleep 5
fi

if [ -z "$ADVANCED" ]; then
    read -e -p "Use the Advanced Installation? [N/y] : " ADVANCED
fi

if [[ ("$ADVANCED" == "y" || "$ADVANCED" == "Y") ]]; then
    USER=$USER
    INSTALLERUSED="#Used Advanced Install"

    echo "" && echo 'Using advance install' && echo ""
    sleep 1
else
    USER=$USER
    UFW="y"
    INSTALLERUSED="#Used Basic Install"
    BOOTSTRAP="y"
fi


if [ -z "$KEY" ]; then
    read -e -p "Masternode Private Key : " KEY
fi

if [ -z "$SWAP" ]; then
    read -e -p "Does VPS use less than 2GB RAM? [Y/n] : " SWAP
fi

if [ -z "$UFW" ]; then
    read -e -p "Install UFW and configure ports? [Y/n] : " UFW
fi

if [ -z "$ARGUMENTIP" ]; then
    read -e -p "Server IP Address: " -i $EXTERNALIP -e IP
fi

if [ -z "$BOOTSTRAP"]; then
    read -e -p "Download bootstrap for fast sync? [Y/n] : " BOOTSTRAP
fi

clear

# Generate random passwords
RPCUSER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
RPCPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

echo "Configuring swap file..."
# Configuring SWAPT
if [[ ("$SWAP" == "y" || "$SWAP" == "Y" || "$SWAP" == "") ]]; then
    cd $HOME
    sudo swapoff -a
    sudo dd if=/dev/zero of=/swapfile bs=6144 count=1048576
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
fi
clear

# update packages and upgrade Ubuntu
echo "Installing dependencies..."
YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get)
PACMAN_CMD=$(which pacman)

if [[ ! -z $YUM_CMD ]]; then
    echo "using YUM"
    yum check-update
elif [[ ! -z $APT_GET_CMD ]]; then
    apt-get update
elif [[ ! -z $PACMAN_CMD ]]; then
    yes | LC_ALL=en_US.UTF-8 pacman -S $pkg
else
    echo "Cannot update repository"
    exit 1;
fi



pkgs='build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev libcurl4-openssl-dev curl libzip-dev ntp git make automake build-essential libboost-all-dev yasm binutils libcurl4-openssl-dev openssl libssl-dev libgmp-dev libtool qt5-default qttools5-dev-tools unzip'
install=false
for pkg in $pkgs; do
  status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)"
  if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
    install=true
  fi
  if "$install"; then
    if [[ ! -z $YUM_CMD ]]; then
        yum -y install $pkg
    elif [[ ! -z $APT_GET_CMD ]]; then
        DEBIAN_FRONTEND=noninteractive apt-get -qq -y install $pkg
    elif [[ ! -z $PACMAN_CMD ]]; then
        yes | LC_ALL=en_US.UTF-8 pacman -S $pkg
    else
        echo "error can't install package $pkg"
        exit 1;
    fi    
    install=false
  fi
done
clear

echo "Configuring UFW..."
# Install UFW
if [[ ("$UFW" == "y" || "$UFW" == "Y" || "$UFW" == "") ]]; then
    apt-get -qq install ufw
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow 52000/tcp
    yes | ufw enable
fi
clear


# Install CCASH daemon
cd $HOME
wget https://gitlab.projectmerge.org/ProjectMerge/merge/uploads/58b459679e67a08aa0736d958c8a6611/merge-1.0.4-x86_64-linux-gnu.tar.gz
tar -xvf merge-1.0.4-x86_64-linux-gnu.tar.gz
mv merge-1.0.4 merge
clear

# Create CCASH directory
mkdir $HOME/.merge

# Bootstrap
if [[ ("$BOOTSTRAP" == "y" || "$BOOTSTRAP" == "Y" || "$BOOTSTRAP" == "") ]]; then
    echo "Downloading bootstrap..."
    cd $HOME/.merge
    wget https://snapshots.projectmerge.org/snapshot/merge//MergeSnapshot1357716.zip
    unzip MergeSnapshot1357716.zip
    rm MergeSnapshot1357716.zip
    cd $HOME
fi

# Create CampusCash.conf
touch $HOME/.merge/merge.conf
cat >$HOME/.merge/merge.conf <<EOL
${INSTALLERUSED}
rpcuser=${RPCUSER}
rpcpassword=${RPCPASSWORD}
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
logtimestamps=1
logips=1
externalip=${IP}
bind=${IP}:52000
masternodeaddr=${IP}:52000
masternodeprivkey=${KEY}
masternode=1
addnode=185.52.172.164:52000
addnode=103.1.206.24:52000
EOL
chmod 0600 $HOME/.merge/merge.conf
chown -R $USER:$USER $HOME/.merge

sleep 1
clear

#Set up enviroment variables
cd $HOME

wget https://raw.githubusercontent.com/M1chlCZ/CampusCash-MN-install/main/env.sh
source env.sh
source $HOME/.profile

clear

echo "Setting up CCASH daemon..."
cat >/etc/systemd/system/merge.service <<EOL
[Unit]
Description=MERGED
After=network.target
[Service]
Type=forking
User=${USER}
WorkingDirectory=/root/
ExecStart=/root/merge/bin/merged -conf=/root/.merge/merge.conf -datadir=/root/.merge
ExecStop=/root/merge/bin/merge-cli -conf=/root/.merge/merge.conf -datadir=/root/.merge stop
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOL
sudo systemctl daemon-reload
sudo systemctl enable merge.service
sudo systemctl start merge.service

clear

cat <<EOL
Now, you need to wait for sync you can check the progress by typing getinfo. After full sync please go to your desktop wallet
Click the Masternodes tab
Click Start all at the bottom

If for some reason commands such as mnstart, mnstatus, getinfo did not work, please log out of this session and log back in.

EOL

read -p "Press Enter to continue after read to continue. " -n1 -s
clear

#File cleanup
rm -rf $HOME/mergeMNInstall.sh

echo "" && echo "Masternode setup complete" && echo ""

cat <<"EOF"
           |Brought to you by|         
  __  __ _  ____ _   _ _     ____ _____
 |  \/  / |/ ___| | | | |   / ___|__  /
 | |\/| | | |   | |_| | |  | |     / / 
 | |  | | | |___|  _  | |__| |___ / /_ 
 |_|  |_|_|\____|_| |_|_____\____/____|
       For complains Tweet @M1chl 

MERGE: MS7aePJKQMkk1TbxWasH3mjo2gC6kyzMqu

EOF
