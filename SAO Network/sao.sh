#!/bin/bash
clear
merah="\e[31m"
kuning="\e[33m"
hijau="\e[32m"
biru="\e[34m"
UL="\e[4m"
bold="\e[1m"
italic="\e[3m"
reset="\e[m"

# logo

curl -s https://raw.githubusercontent.com/SaujanaOK/Node-TestNet-Guide/main/logo.sh | bash


sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi

if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export SAO_CHAIN_ID=sao-devnet" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "moniker : \e[1m\e[32m$NODENAME\e[0m"
echo -e "wallet  : \e[1m\e[32m$WALLET\e[0m"
echo -e "chain-id: \e[1m\e[32m$sao_CHAIN_ID\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt list --upgradable && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1

# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
ver="1.19.5" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME
git clone https://github.com/SAONetwork/sao-node.git
cd $HOME/sao-node
git checkout v0.1.0
make

# Build binaries
cd $HOME/sao-node && make

# Prepare binaries for Cosmovisor
mkdir -p $HOME/.saonode/cosmovisor/genesis/bin
mv build/saod $HOME/.saonode/cosmovisor/genesis/bin/
rm -rf build

# Create application symlinks
ln -s $HOME/.saonode/cosmovisor/genesis $HOME/.saonode/cosmovisor/current
sudo ln -s $HOME/.saonode/cosmovisor/current/bin/saod /usr/local/bin/saod

# Set node configuration
saod config chain-id sao-devnet
saod config keyring-backend test
saod config node tcp://localhost:50657

# Initialize the node
saod init $NODENAME --chain-id sao-devnet

# Download genesis and addrbook
curl -Ls https://snapshots.kjnodes.com/sao-testnet/genesis.json > $HOME/.saonode/config/genesis.json
curl -Ls https://snapshots.kjnodes.com/sao-testnet/addrbook.json > $HOME/.saonode/config/addrbook.json

# Add seeds
sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@sao-testnet.rpc.kjnodes.com:50659\"|" $HOME/.saonode/config/config.toml

# Set minimum gas price
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0usao\"|" $HOME/.saonode/config/app.toml

# Set pruning
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/.saonode/config/app.toml

# Set custom ports
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:50658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:50657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:50060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:50656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":50660\"%" $HOME/.saonode/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:50317\"%; s%^address = \":8080\"%address = \":50080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:50090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:50091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:50545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:50546\"%" $HOME/.saonode/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.saonode/config/config.toml

# Download latest chain snapshot
curl -L https://snapshots.kjnodes.com/sao-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.saonode
[[ -f $HOME/.saonode/data/upgrade-info.json ]] && cp $HOME/.saonode/data/upgrade-info.json $HOME/.saonode/cosmovisor/genesis/upgrade-info.json

# reset
echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
# Download and install Cosmovisor
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0

# Create service
sudo tee /etc/systemd/system/saod.service > /dev/null << EOF
[Unit]
Description=sao-testnet node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.saonode"
Environment="DAEMON_NAME=saod"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.saonode/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable saod
sudo systemctl restart saod
rm -rf $HOME/sao.sh
source $HOME/.bash_profile
sudo journalctl -fu saod -o cat
echo '=============== SETUP FINISHED ==================='
