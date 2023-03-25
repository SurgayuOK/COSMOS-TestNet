- Snapshot : https://snap.node.seputar.codes/bb/
- Snapshot File : https://snap.node.seputar.codes/bb/snapshot_latest.tar.lz4

________________________________________________

## Auto install
```
wget -O bonusblock.sh https://raw.githubusercontent.com/SaujanaOK/BonusBlock/main/bonusblock.sh && chmod +x bonusblock.sh && ./bonusblock.sh
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
sudo systemctl stop bonus-blockd
cp $HOME/.bonusblock/data/priv_validator_state.json $HOME/.bonusblock/priv_validator_state.json.backup
rm -rf $HOME/.bonusblock/data
```
### 2. Use our Snapshot
```
curl -L  https://snap.node.seputar.codes/bb/snapshot_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.bonusblock
mv $HOME/.bonusblock/priv_validator_state.json.backup $HOME/.bonusblock/data/priv_validator_state.json
```
### 3. Start Node
```
sudo systemctl restart bonus-blockd && sudo journalctl -u bonus-blockd -f --no-hostname -o cat
```
________________________________________________
## Informasi node
### Add wallet baru
```
bonus-blockd keys add $WALLET
```
### Recover Wallet yang ada
```
bonus-blockd keys add $WALLET --recover
```
### List wallet
```
bonus-blockd keys list
```
### Simpan informasi wallet
```
BONUS_WALLET_ADDRESS=$(bonus-blockd keys show $WALLET -a)
BONUS_VALOPER_ADDRESS=$(bonus-blockd keys show $WALLET --bech val -a)
echo 'export BONUS_WALLET_ADDRESS='${BONUS_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export BONUS_VALOPER_ADDRESS='${BONUS_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### Check Sync
```
bonus-blockd status 2>&1 | jq .SyncInfo
```
### Check log node
```
journalctl -fu bonus-blockd -o cat
```
### Check node info
```
bonus-blockd status 2>&1 | jq .NodeInfo
```
### Check validator info
```
bonus-blockd status 2>&1 | jq .ValidatorInfo
```
### Check node id
```
bonus-blockd tendermint show-node-id
```
________________________________________________
## Membuat validator
### Check balance
```
bonus-blockd query bank balances $BONUS_WALLET_ADDRESS
```
### Membuat validator
```
bonus-blockd tx staking create-validator \
  --amount 100000ubonus \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --identity="<your_keybase_id>" \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(bonus-blockd tendermint show-validator) \
  --moniker $NODENAME \
  --gas=auto \
  --gas-adjustment=1.2 \
  --gas-prices=0.025ubonus \
  --chain-id $BONUS_CHAIN_ID
```
### Edit validator
```
bonus-blockd tx staking edit-validator \
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
bonus-blockd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$BONUS_CHAIN_ID \
  --fees=200000000ubonus \
  --gas-adjustment=1.2 \
  --gas=auto
```
### Voting
```
bonus-blockd tx gov vote 1 yes --from $WALLET --chain-id=$BONUS_CHAIN_ID --gas=auto --fees=2500000ubonus
```
## Delegasi dan Rewards
### Delegasi
```
bonus-blockd tx staking delegate $BONUS_VALOPER_ADDRESS 1000000000000ubonus --from=$WALLET --chain-id=$BONUS_CHAIN_ID --gas=auto --fees=250000ubonus
```
### Withdraw reward
```
bonus-blockd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$BONUS_CHAIN_ID --gas=auto --fees=2500000ubonus
```
### Withdraw reward beserta komisi
```
bonus-blockd tx distribution withdraw-rewards $BONUS_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$BONUS_CHAIN_ID --gas=auto --fees=2500000ubonus
```
## Hapus node
```
sudo systemctl stop bonus-blockd && \
sudo systemctl disable bonus-blockd && \
rm -rf /etc/systemd/system/bonus-blockd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf BonusBlock-chain && \
rm -rf bonus.sh && \
rm -rf .bonusblock && \
rm -rf $(which bonus-blockd)
```



