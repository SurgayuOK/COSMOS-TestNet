- Snapshot : https://snap.node.seputar.codes/bb/
- Snapshot File : https://snap.node.seputar.codes/bb/snapshot_latest.tar.lz4

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
curl -L  https://snap.node.seputar.codes/bb/snapshot_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.ojo
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
BONUS_WALLET_ADDRESS=$(ojod keys show $WALLET -a)
BONUS_VALOPER_ADDRESS=$(ojod keys show $WALLET --bech val -a)
echo 'export BONUS_WALLET_ADDRESS='${BONUS_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export BONUS_VALOPER_ADDRESS='${BONUS_VALOPER_ADDRESS} >> $HOME/.bash_profile
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
ojod query bank balances $BONUS_WALLET_ADDRESS
```
### Membuat validator
```
ojod tx staking create-validator \
  --amount 100000ubonus \
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
  --gas-prices=0.025ubonus \
  --chain-id $BONUS_CHAIN_ID
```
### Edit validator
```
ojod tx staking edit-validator \
  --new-moniker="nama-node" \
  --identity="<your_keybase_id>" \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$BONUS_CHAIN_ID \
  --gas=auto \
  --fees=260000000ubonus \
  --gas-adjustment=1.2 \
  --from=$WALLET
```
### Unjail validator
```
ojod tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$BONUS_CHAIN_ID \
  --fees=200000000ubonus \
  --gas-adjustment=1.2 \
  --gas=auto
```
### Voting
```
ojod tx gov vote 1 yes --from $WALLET --chain-id=$BONUS_CHAIN_ID --gas=auto --fees=2500000ubonus
```
## Delegasi dan Rewards
### Delegasi
```
ojod tx staking delegate $BONUS_VALOPER_ADDRESS 1000000000000ubonus --from=$WALLET --chain-id=$BONUS_CHAIN_ID --gas=auto --fees=250000ubonus
```
### Withdraw reward
```
ojod tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$BONUS_CHAIN_ID --gas=auto --fees=2500000ubonus
```
### Withdraw reward beserta komisi
```
ojod tx distribution withdraw-rewards $BONUS_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$BONUS_CHAIN_ID --gas=auto --fees=2500000ubonus
```
## Hapus node
```
sudo systemctl stop ojod && \
sudo systemctl disable ojod && \
rm -rf /etc/systemd/system/ojod.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf BonusBlock-chain && \
rm -rf bonus.sh && \
rm -rf .ojo && \
rm -rf $(which ojod)
```



