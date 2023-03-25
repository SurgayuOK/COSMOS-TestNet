# SAO NETWORK
- Incentive Status : CONFIRMED
- Registrasi Incentive Testnet SAO : [Google Form](https://docs.google.com/forms/u/0/d/e/1FAIpQLSeIx9mxry0w5oTyiOpSHg04cM4GPZMKvxd1LmhqyhYvqY8bOQ/alreadyresponded)
- SAO Faucet : https://faucet.testnet.sao.network/
- Twitter SAO : https://twitter.com/SAONetwork
- Discord SAO : https://discord.gg/Q6TxBYrydz
- Docs SAO : https://docs.sao.network
- Github SAO : https://github.com/SAONetwork/sao-node
- SAO Explorer : https://sao.explorers.guru/validators
- Our Snapshot : https://snap.node.seputar.codes/sao
- Our Snapshot File : https://snap.node.seputar.codes/sao/snapshot_latest.tar.lz4
- SAO Information : [Medium](https://saonetwork.medium.com/a-complete-guide-to-sao-network-testnet-e70117bd294)
________________________________________________

## Auto install
```
wget -O sao.sh https://raw.githubusercontent.com/SaujanaOK/COSMOS-TestNet/main/sao/sao.sh && chmod +x sao.sh && ./sao.sh
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
sudo systemctl stop saod
cp $HOME/.sao/data/priv_validator_state.json $HOME/.sao/priv_validator_state.json.backup
rm -rf $HOME/.sao/data
```
### 2. Use our Snapshot
```
curl -L  https://snap.node.seputar.codes/sao/snapshot_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.sao
mv $HOME/.sao/priv_validator_state.json.backup $HOME/.sao/data/priv_validator_state.json
```
### 3. Start Node
```
sudo systemctl restart saod && sudo journalctl -u saod -f --no-hostname -o cat
```
________________________________________________
## Informasi node
### Add wallet baru
```
saod keys add $WALLET
```
### Recover Wallet yang ada
```
saod keys add $WALLET --recover
```
### List wallet
```
saod keys list
```
### Simpan informasi wallet
```
sao_WALLET_ADDRESS=$(saod keys show $WALLET -a)
sao_VALOPER_ADDRESS=$(saod keys show $WALLET --bech val -a)
echo 'export sao_WALLET_ADDRESS='${sao_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export sao_VALOPER_ADDRESS='${sao_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### Check Sync
```
saod status 2>&1 | jq .SyncInfo
```
### Check log node
```
journalctl -fu saod -o cat
```
### Check node info
```
saod status 2>&1 | jq .NodeInfo
```
### Check validator info
```
saod status 2>&1 | jq .ValidatorInfo
```
### Check node id
```
saod tendermint show-node-id
```
________________________________________________
## Membuat validator
### Check balance
```
saod query bank balances $sao_WALLET_ADDRESS
```
### Membuat validator
```
saod tx staking create-validator \
  --amount 100000usao \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --identity="<your_keybase_id>" \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(saod tendermint show-validator) \
  --moniker $NODENAME \
  --gas=auto \
  --gas-adjustment=1.2 \
  --gas-prices=0.025usao \
  --chain-id $sao_CHAIN_ID
```
### Edit validator
```
saod tx staking edit-validator \
  --new-moniker="nama-node" \
  --identity="<your_keybase_id>" \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$sao_CHAIN_ID \
  --gas=auto \
  --fees=260000000usao \
  --gas-adjustment=1.2 \
  --from=$WALLET
```
### Unjail validator
```
saod tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$sao_CHAIN_ID \
  --fees=200000000usao \
  --gas-adjustment=1.2 \
  --gas=auto
```
### Voting
```
saod tx gov vote 1 yes --from $WALLET --chain-id=$sao_CHAIN_ID --gas=auto --fees=2500000usao
```
## Delegasi dan Rewards
### Delegasi
```
saod tx staking delegate $sao_VALOPER_ADDRESS 1000000000000usao --from=$WALLET --chain-id=$sao_CHAIN_ID --gas=auto --fees=250000usao
```
### Withdraw reward
```
saod tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$sao_CHAIN_ID --gas=auto --fees=2500000usao
```
### Withdraw reward beserta komisi
```
saod tx distribution withdraw-rewards $sao_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$sao_CHAIN_ID --gas=auto --fees=2500000usao
```
## Hapus node
```
sudo systemctl stop saod && \
sudo systemctl disable saod && \
rm -rf /etc/systemd/system/saod.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf sao && \
rm -rf sao.sh && \
rm -rf .sao && \
rm -rf $(which saod)
```
