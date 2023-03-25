- Registrasi Incentive Testnet : [Google Form](https://docs.google.com/forms/u/0/d/e/1FAIpQLSeIx9mxry0w5oTyiOpSHg04cM4GPZMKvxd1LmhqyhYvqY8bOQ/alreadyresponded)
- OJO Faucet : 
- Twitter Official :
- Discord Official : https://discord.gg/exSfjHM9fH
- Docs Official :
- Github Official : 
- Ojo Explorer : https://ojo.explorers.guru/validators
- Our Snapshot : https://snap.node.seputar.codes/ojo
- Our Snapshot File : https://snap.node.seputar.codes/ojo/snapshot_latest.tar.lz4
- Detile Information : [Medium](https://saonetwork.medium.com/a-complete-guide-to-sao-network-testnet-e70117bd294)
________________________________________________

## Auto install
```
wget -O ojo.sh https://raw.githubusercontent.com/SaujanaOK/COSMOS-TestNet/main/OJO/ojo.sh && chmod +x ojo.sh && ./ojo.sh
```

### Pasca install
```
source $HOME/.bash_profile
```
________________________________________________
## SNAPSHOT
### 1. Stop Node
```
sudo apt install lz4 -y
sudo systemctl stop ojod
cp $HOME/.ojo/data/priv_validator_state.json $HOME/.ojo/priv_validator_state.json.backup
rm -rf $HOME/.ojo/data
```
### 2. Use our Snapshot
```
curl -L  https://snap.node.seputar.codes/ojo/snapshot_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.ojo
mv $HOME/.ojo/priv_validator_state.json.backup $HOME/.ojo/data/priv_validator_state.json
```
### 3. Start Node
```
sudo systemctl restart ojod && sudo journalctl -u ojod -f --no-hostname -o cat
```
________________________________________________
## Informasi node
### Add wallet baru
```
ojod keys add $WALLET
```
### Recover Wallet yang ada
```
ojod keys add $WALLET --recover
```
### List wallet
```
ojod keys list
```
### Simpan informasi wallet
```
OJO_WALLET_ADDRESS=$(ojod keys show $WALLET -a)
OJO_VALOPER_ADDRESS=$(ojod keys show $WALLET --bech val -a)
echo 'export OJO_WALLET_ADDRESS='${OJO_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export OJO_VALOPER_ADDRESS='${OJO_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### Check Sync
```
ojod status 2>&1 | jq .SyncInfo
```
### Check log node
```
journalctl -fu ojod -o cat
```
### Check node info
```
ojod status 2>&1 | jq .NodeInfo
```
### Check validator info
```
ojod status 2>&1 | jq .ValidatorInfo
```
### Check node id
```
ojod tendermint show-node-id
```
________________________________________________
## Membuat validator
### Check balance
```
ojod query bank balances $OJO_WALLET_ADDRESS
```
### Membuat validator
```
ojod tx staking create-validator \
  --amount 100000uojo \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --identity="<your_keybase_id>" \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(ojod tendermint show-validator) \
  --moniker $NODENAME \
  --gas=auto \
  --gas-adjustment=1.2 \
  --gas-prices=0.025uojo \
  --chain-id $OJO_CHAIN_ID
```
### Edit validator
```
ojod tx staking edit-validator \
  --new-moniker="nama-node" \
  --identity="<your_keybase_id>" \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$OJO_CHAIN_ID \
  --gas=auto \
  --fees=260000000uojo \
  --gas-adjustment=1.2 \
  --from=$WALLET
```
### Unjail validator
```
ojod tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$OJO_CHAIN_ID \
  --fees=200000000uojo \
  --gas-adjustment=1.2 \
  --gas=auto
```
### Voting
```
ojod tx gov vote 1 yes --from $WALLET --chain-id=$OJO_CHAIN_ID --gas=auto --fees=2500000uojo
```
## Delegasi dan Rewards
### Delegasi
```
ojod tx staking delegate $OJO_VALOPER_ADDRESS 1000000000000uojo --from=$WALLET --chain-id=$OJO_CHAIN_ID --gas=auto --fees=250000uojo
```
### Withdraw reward
```
ojod tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$OJO_CHAIN_ID --gas=auto --fees=2500000uojo
```
### Withdraw reward beserta komisi
```
ojod tx distribution withdraw-rewards $OJO_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$OJO_CHAIN_ID --gas=auto --fees=2500000uojo
```
## Hapus node
```
sudo systemctl stop ojod && \
sudo systemctl disable ojod && \
rm -rf /etc/systemd/system/ojod.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf ojo && \
rm -rf ojo.sh && \
rm -rf .ojo && \
rm -rf $(which ojod)
```
