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
wget -O SAOConsensus.sh https://raw.githubusercontent.com/SaujanaOK/COSMOS-TestNet/main/SAO%20Network/SAOConsensus.sh && chmod +x SAOConsensus.sh && ./SAOConsensus.sh
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
sudo systemctl restart saod
```
### 4. Check Logs
```
sudo journalctl -u saod -f --no-hostname -o cat
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
SAO_WALLET_ADDRESS=$(saod keys show $WALLET -a)
SAO_VALOPER_ADDRESS=$(saod keys show $WALLET --bech val -a)
echo 'export SAO_WALLET_ADDRESS='${SAO_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export SAO_VALOPER_ADDRESS='${SAO_VALOPER_ADDRESS} >> $HOME/.bash_profile
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
saod query bank balances $SAO_WALLET_ADDRESS
```
### Membuat validator
```
saod tx staking create-validator \
--amount=1000000sao \
--pubkey=$(saod tendermint show-validator) \
--moniker="YOUR_MONIKER_NAME" \
--identity="YOUR_KEYBASE_ID" \
--details="YOUR_DETAILS" \
--website="YOUR_WEBSITE_URL" \
--chain-id=sao-testnet1 \
--commission-rate=0.10 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--fees=550sao
```
### Edit validator
```
saod tx staking edit-validator \
--new-moniker="YOUR_MONIKER_NAME" \
--identity="YOUR_KEYBASE_ID" \
--details="YOUR_DETAILS" \
--website="YOUR_WEBSITE_URL"
--chain-id=sao-testnet1 \
--commission-rate=0.05 \
--from=wallet \
--fees=550sao
```
### Unjail validator
```
saod tx slashing unjail --broadcast-mode=block --from wallet --chain-id sao-testnet1 --fees=550sao
```
### Voting
```
saod tx gov vote 1 yes --from wallet --chain-id sao-testnet1 --fees=550sao
```
## Delegasi dan Rewards
### Delegate to yourself
```
saod tx staking delegate $(saod keys show wallet --bech val -a) 1000000sao --from wallet --chain-id sao-testnet1 --fees=550sao
```
### Delegate tokens to validator
```
saod tx staking delegate <TO_VALOPER_ADDRESS> 1000000sao --from wallet --chain-id sao-testnet1 --fees=550sao
```
### Redelegate tokens to another validator
```
saod tx staking redelegate $(saod keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 1000000sao --from wallet --chain-id sao-testnet1 --fees=550sao
```
### Unbond tokens from your validator
```
saod tx staking unbond $(saod keys show wallet --bech val -a) 1000000sao --from wallet --chain-id sao-testnet1 --fees=550sao
```
### Send tokens to the wallet
```
saod tx bank send wallet <TO_WALLET_ADDRESS> 1000000sao --from wallet --chain-id sao-testnet1 --fees=550sao
```
### Withdraw all reward
```
saod tx distribution withdraw-all-rewards --from wallet --chain-id sao-testnet1 --fees=550sao
```
### Withdraw reward beserta komisi
```
saod tx distribution withdraw-rewards $(saod keys show wallet --bech val -a) --commission --from wallet --chain-id sao-testnet1 --fees=550sao
```
## Hapus node
```
sudo systemctl stop saod && \
sudo systemctl disable saod && \
rm -rf /etc/systemd/system/saod.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf sao-consensus && \
rm -rf .sao && \
rm -rf $(which saod)
```
