echo "Setting up enviromental commands..."
cd $HOME
mkdir -p .commands
mkdir -p .profile
echo "export PATH="$PATH:$HOME/.commands"" >>$HOME/.profile


rm  $HOME/.commands/gethelp > /dev/null 2>&1
rm  $HOME/.commands/getinfo > /dev/null 2>&1
rm  $HOME/.commands/mnstart > /dev/null 2>&1
rm  $HOME/.commands/mnstatus > /dev/null 2>&1
rm  $HOME/.commands/mnxstatus > /dev/null 2>&1
rm  $HOME/.commands/startd > /dev/null 2>&1
rm  $HOME/.commands/stopd > /dev/null 2>&1
rm  $HOME/.commands/commandUpdate > /dev/null 2>&1
rm  $HOME/.commands/campusUpdate > /dev/null 2>&1
rm  $HOME/.commands/clearbanned > /dev/null 2>&1
rm  $HOME/.commands/getBootstrap > /dev/null 2>&1
rm  $HOME/.commands/getBootstrap2 > /dev/null 2>&1
rm  $HOME/.commands/mn2setup > /dev/null 2>&1
rm  $HOME/.commands/mnxsetup > /dev/null 2>&1
rm  $HOME/.commands/mn2start > /dev/null 2>&1
rm  $HOME/.commands/mn2status > /dev/null 2>&1
rm  $HOME/.commands/startd2 > /dev/null 2>&1
rm  $HOME/.commands/stopd2 > /dev/null 2>&1
rm  $HOME/.commands/startdx > /dev/null 2>&1
rm  $HOME/.commands/stopdx > /dev/null 2>&1
rm  $HOME/.commands/campusBetaInstall > /dev/null 2>&1
rm  $HOME/.commands/getBootstrapx > /dev/null 2>&1
rm  $HOME/.commands/getxinfo > /dev/null 2>&1
rm  $HOME/.commands/mnxstatus > /dev/null 2>&1
rm  $HOME/.commands/getPeers > /dev/null 2>&1
rm  $HOME/.commands/getxPeers > /dev/null 2>&1
rm  $HOME/.commands/campusVersionInstall > /dev/null 2>&1
rm  $HOME/.commands/addnode > /dev/null 2>&1
rm  $HOME/.commands/addnodex > /dev/null 2>&1
rm  $HOME/.commands/addnode2 > /dev/null 2>&1

cat > $HOME/.commands/gethelp << EOL
#!/bin/bash

cat << "EOF"
          |Brought to you by|         
  __  __ _  ____ _   _ _     ____ _____
 |  \/  / |/ ___| | | | |   / ___|__  /
 | |\/| | | |   | |_| | |  | |     / / 
 | |  | | | |___|  _  | |__| |___ / /_ 
 |_|  |_|_|\____|_| |_|_____\____/____|
       For complains Tweet @M1chl 

Merge: MS7aePJKQMkk1TbxWasH3mjo2gC6kyzMqu

EOF
echo ""
echo "Here is list of commands for you MERGE service"
echo "you can type these commands anywhere in terminal."
echo ""
echo "Command              | What does it do?"
echo "---------------------------------------------------"
echo "getinfo              | Get wallet info"
echo ""
echo "mnstart              | Start masternode"
echo ""
echo "mnstatus             | Status of the masternode"
echo ""
echo "mnxstatus N          | Status of the masternode #N"
echo ""
echo "startd               | Start MERGE deamon"
echo ""
echo "startd2              | Start MERGE deamon for MN #2"
echo ""
echo "startdx N            | Start MERGE deamon #<N>"
echo ""
echo "stopd                | Stop MERGE deamon"
echo ""
echo "stopd2               | Stop MERGE deamon for MN #2"
echo ""
echo "stopdx N             | Stop MERGE deamon #N"
echo ""
echo "mn2start             | Start MN #2"
echo ""
echo "mn2status            | Status of MN #2"
echo ""
echo "mnxstatus N          | Status of MN #2"
echo ""
echo "campusUpdate         | Update MERGE deamon"
echo ""
echo "commandUpdate        | Update List of commands"
echo ""
echo "campusBetaInstall    | Installs a beta version of daemon"
echo ""
echo "getBootstrap         | Get a bootstrap"
echo ""
echo "getBootstrap2        | Get a bootstrap for MN #2"
echo ""
echo "getBootstrapx N      | Get a bootstrap for MN #N"
echo ""
echo "getPeers             | Get peers for daemon"
echo ""
echo "getxPeers N          | Get peers for daemon #N"
echo ""
echo "getpeerinfo          | Show peer info"
echo ""
echo "clearbanned          | Clear all banned IPs"
echo ""
echo "getinfo2             | Get 2nd deamon info"
echo ""
echo "mn2setup             | Set up MN #2"
echo ""
echo "mnxsetup N           | Set up MN #N"
echo ""
echo "gethelp              | Show help"
echo "---------------------------------------------------"
echo ""
EOL

cat > $HOME/.commands/getinfo << EOL
#!/bin/bash    
$HOME/merge/bin/merge-cli getinfo
EOL

cat > $HOME/.commands/getpeerinfo << EOL
#!/bin/bash    
$HOME/merge/bin/merge-cli getpeerinfo
EOL

cat > $HOME/.commands/mnstart << EOL
#!/bin/bash    
$HOME/merge/bin/merge-cli startmasternode local false
EOL

cat > $HOME/.commands/mnstatus << EOL
#!/bin/bash    
$HOME/merge/bin/merge-cli getmasternodestatus
EOL

cat > $HOME/.commands/startd << EOL
#!/bin/bash
systemctl start merge.service > /dev/null 2>&1
echo "MERGE Deamon is running..."
EOL

cat > $HOME/.commands/startdx << EOL
#!/bin/bash    
systemctl start merge\$1.service 
echo "MERGE Deamon is running..."
EOL

cat > $HOME/.commands/stopdx << EOL
#!/bin/bash    
systemctl stop merge\$1.service 
echo "MERGE Deamon is innactive..."
EOL


cat > $HOME/.commands/stopd << EOL
#!/bin/bash
systemctl stop merge.service
sleep 1
echo "MERGE Deamon is innactive..."
EOL

cat > $HOME/.commands/clearbanned << EOL
#!/bin/bash    
$HOME/merge/bin/merge-cli clearbanned
EOL

cat > $HOME/.commands/getBootstrap << EOL
systemctl stop ccash.service 

cd $HOME

mv  $HOME/.merge/merge.conf merge.conf
mv  $HOME/.merge/wallet.dat wallet.dat
mv  $HOME/.merge/masternode.conf masternode.conf

pkgs='unzip'
install=false
for pkg in $pkgs; do
  status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)"
  if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
    install=true
  fi
  if "$install"; then
    apt-get install -y $pkg
    install=false
  fi
done

 cd $HOME/.merge
    wget https://snapshots.projectmerge.org/snapshot/merge//MergeSnapshot1357716.zip
    unzip MergeSnapshot1357716.zip
    rm MergeSnapshot1357716.zip
    cd $HOME

mv merge.conf  $HOME/.merge/merge.conf
mv wallet.dat  $HOME/.merge/wallet.dat
mv masternode.conf $HOME/.merge/masternode.conf 


systemctl start merge.service > /dev/null 2>&1
echo "MERGE Deamon is running..."
EOL

cat > $HOME/.commands/getBootstrapx << EOL
systemctl stop merge\$1.service 

cd $HOME

mv  $HOME/.merge\$1/merge.conf merge.conf
mv  $HOME/.merge\$1/wallet.dat wallet.dat
mv  $HOME/.merge\$1/masternode.conf masternode.conf

pkgs='unzip'
install=false
for pkg in $pkgs; do
  status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)"
  if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
    install=true
  fi
  if "$install"; then
    apt-get install -y $pkg
    install=false
  fi
done

 cd $HOME/.merge
    wget https://snapshots.projectmerge.org/snapshot/merge//MergeSnapshot1357716.zip
    unzip MergeSnapshot1357716.zip
    rm MergeSnapshot1357716.zip
    cd $HOME

mv merge.conf  $HOME/.merge\$1/merge.conf
mv wallet.dat  $HOME/.merge\$1/wallet.dat
mv masternode.conf $HOME/.merge\$1/masternode.conf

systemctl start merge\$1.service > /dev/null 2>&1
echo "MERGE Deamon is running..."
EOL

cat > $HOME/.commands/commandUpdate << EOL
#!/bin/bash
cd $HOME 
wget https://raw.githubusercontent.com/M1chlCZ/MERGE-MN-install/main/env.sh > /dev/null 2>&1
source env.sh
clear

cat << "EOF"
            Update complete!

           |Brought to you by|         
  __  __ _  ____ _   _ _     ____ _____
 |  \/  / |/ ___| | | | |   / ___|__  /
 | |\/| | | |   | |_| | |  | |     / / 
 | |  | | | |___|  _  | |__| |___ / /_ 
 |_|  |_|_|\____|_| |_|_____\____/____|
       For complains Tweet @M1chl 

CCASH: MS7aePJKQMkk1TbxWasH3mjo2gC6kyzMqu

EOF

. $HOME/.commands/gethelp

echo ""
EOL

cat > $HOME/.commands/getBootstrap2 << EOL
systemctl stop ccash2.service 

cd $HOME

mv  $HOME/.merge2/merge.conf merge.conf
mv  $HOME/.merge2/wallet.dat wallet.dat
mv  $HOME/.merge2/masternode.conf masternode.conf

pkgs='unzip'
install=false
for pkg in $pkgs; do
  status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)"
  if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
    install=true
  fi
  if "$install"; then
    apt-get install -y $pkg
    install=false
  fi
done

cd $HOME/.merge2
rm -rf *
wget https://github.com/MERGE/MERGE_Core/releases/download/v1.1.0.16/MERGE_Bootstrap.zip
unzip MERGE_Bootstrap.zip
rm MERGE_Bootstrap.zip
cd $HOME

mv merge.conf  $HOME/.merge2/merge.conf
mv wallet.dat  $HOME/.merge2/wallet.dat
mv masternode.conf $HOME/.merge2/masternode.conf
 
systemctl start merge.service > /dev/null 2>&1
echo "MERGE Deamon is running..."
EOL

cat > $HOME/.commands/mn2setup << EOL
cd $HOME
wget https://raw.githubusercontent.com/M1chlCZ/MERGE-MN-install/main/mn2.sh > /dev/null 2>&1
source mn2.sh
EOL

cat > $HOME/.commands/mnxsetup << EOL
cd $HOME
wget https://raw.githubusercontent.com/M1chlCZ/MERGE-MN-install/main/mnxsetup.sh > /dev/null 2>&1
chmod +x mnxsetup.sh
source mnxsetup.sh
EOL

cat > $HOME/.commands/getinfo2 << EOL
#!/bin/bash    
$HOME/merge/bin/merge-cli -conf=$HOME/.merge2/merge.conf -datadir=$HOME/.merge2 getinfo
EOL

cat > $HOME/.commands/mn2start << EOL
#!/bin/bash    
$HOME/merge/bin/merge-cli -conf=$HOME/.merge2/merge.conf -datadir=$HOME/.merge2 -port=12001 startmasternode local false
EOL

cat > $HOME/.commands/mnxstart << EOL
#!/bin/bash    
PORT=\$((\$1 - 1))
$HOME/merge/bin/merge-cli -conf=$HOME/.merge\$1/merge.conf -datadir=$HOME/.merge\$1 -port=1200\$PORT startmasternode local false
EOL

cat > $HOME/.commands/mnxstatus << EOL
#!/bin/bash    
PORT=\$((\$1 - 1))
$HOME/merge/bin/merge-cli -conf=$HOME/.merge\$1/merge.conf -datadir=$HOME/.merge\$1 -port=1200\$PORT getmasternodestatus
EOL

cat > $HOME/.commands/getxinfo << EOL
#!/bin/bash    
PORT=\$((\$1 - 1))
$HOME/merge/bin/merge-cli -conf=$HOME/.merge\$1/merge.conf -datadir=$HOME/.merge\$1 -port=1200\$PORT getinfo
EOL

cat > $HOME/.commands/mnxstatus << EOL
#!/bin/bash    
PORT=\$((\$1 - 1))
$HOME/merge/bin/merge-cli -conf=$HOME/.merge\$1/merge.conf -datadir=$HOME/.merge\$1 -port=1200\$PORT getmasternodestatus
EOL

cat > $HOME/.commands/mn2status << EOL
#!/bin/bash    
$HOME/merge/bin/merge-cli -conf=$HOME/.merge2/merge.conf -datadir=$HOME/.merge2 getmasternodestatus
EOL

cat > $HOME/.commands/startd2 << EOL
#!/bin/bash
systemctl start ccash2.service > /dev/null 2>&1
echo "MERGE Deamon #2 is running..."
EOL

cat > $HOME/.commands/stopd2 << EOL
#!/bin/bash
systemctl stop ccash2.service
sleep 1
echo "MERGE Deamon #2 is innactive..."
EOL


chmod +x  $HOME/.commands/getinfo
chmod +x  $HOME/.commands/mnstart
chmod +x  $HOME/.commands/mnstatus
chmod +x  $HOME/.commands/startd
chmod +x  $HOME/.commands/stopd
chmod +x  $HOME/.commands/commandUpdate
chmod +x  $HOME/.commands/campusUpdate
chmod +x  $HOME/.commands/gethelp
chmod +x  $HOME/.commands/getpeerinfo
chmod +x  $HOME/.commands/clearbanned
chmod +x  $HOME/.commands/getBootstrap
chmod +x  $HOME/.commands/getBootstrap2
chmod +x  $HOME/.commands/getinfo2
chmod +x  $HOME/.commands/mn2setup
chmod +x  $HOME/.commands/mnxsetup
chmod +x  $HOME/.commands/mnxstart
chmod +x  $HOME/.commands/mn2start
chmod +x  $HOME/.commands/mn2status
chmod +x  $HOME/.commands/startd2
chmod +x  $HOME/.commands/stopd2
chmod +x  $HOME/.commands/startdx
chmod +x  $HOME/.commands/stopdx
chmod +x  $HOME/.commands/campusBetaInstall
chmod +x  $HOME/.commands/getBootstrapx
chmod +x  $HOME/.commands/getxinfo
chmod +x  $HOME/.commands/mnxstatus
chmod +x  $HOME/.commands/getPeers
chmod +x  $HOME/.commands/getxPeers
chmod +x  $HOME/.commands/mnxstatus 
chmod +x  $HOME/.commands/campusVersionInstall
chmod +x  $HOME/.commands/addnode
chmod +x  $HOME/.commands/addnodex
chmod +x  $HOME/.commands/addnode2

. .commands/gethelp

rm $HOME/env.sh > /dev/null 2>&1