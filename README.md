Introdution
---
For make cross-chain transactions you need to:
1) Installed KiChain kichain-t-4 node
2) Installed another Cosmos node with IBC (the following is Croeseid 3.1.0)
3) Cosmos IBC relayer

Relayer installation and configuration
---
Install relayer v1.0.0

```cd
git clone https://github.com/cosmos/relayer.git
cd relayer
make install
cd
```
Initialize the relayer config
```
rly config init
```
Create KiChain config file

```
echo '{"chain-id":"kichain-t-4","rpc-addr":"https://rpc-challenge.blockchain.ki:443","account-prefix":"tki","gas-adjustment":1.5,"gas-prices":"0.025utki","trusting-period":"10m"}' > $HOME/.relayer/config/kichain_config.json
```
Create Cro config file
```
echo '{"chain-id":"testnet-croeseid-4","rpc-addr":"'`cat "$HOME/.chain-maind/config/config.toml" | grep -oPm1 "(?<=^laddr = \")([^%]+)(?=\")"`'","account-prefix":"tcro","gas-adjustment":1.5,"gas-prices":"0.025basetcro","trusting-period":"10m"}'  > $HOME/.relayer/config/croeseid_config.json
```
Add chain configs from JSON
```
rly chains add -f $HOME/.relayer/config/kichain_config.json
rly chains add -f $HOME/.relayer/config/croeseid_config.json
```
Create relayer wallets
```
rly keys add kichain-t-4 kichain_wallet > $HOME/rly_kichain_wallet.txt
rly keys add testnet-croeseid-4 cro_wallet > $HOME/rly_croeseid_wallet.txt
```
Save this files
```
echo $HOME/rly_kichain_wallet.txt
echo $HOME/rly_croeseid_wallet.txt
```
Link wallets to networks
```
rly chains edit kichain-t-4 key kichain_wallet
rly chains edit testnet-croeseid-4 key cro_wallet
```
Send tokens to Kichain and Cro wallets and check balances after that
```
rly query balance kichain-t-4
rly query balance testnet-croeseid-4
```
Initialize light clients
```
rly light init kichain-t-4 -f
rly light init testnet-croeseid-4 -f
```
Then we generate paths
```
rly paths generate kichain-t-4 testnet-croeseid-4 kichain --port=transfer
rly paths generate testnet-croeseid-4 kichain-t-4 cro --port=transfer
```
Check correct configuration
```
rly chains list
```
Output
```
0: kichain-t-4          -> key(✔) bal(✔) light(✔) path(✔)
1: testnet-croeseid-4   -> key(✔) bal(✔) light(✔) path(✔)
```
Open channels (wait for ```Channel created```)
```
rly tx link kichain
rly tx link cro
```

Cross-chain transaction sending
---
Send 1tki to Cro
```
rly tx transfer kichain-t-4 testnet-croeseid-4 1000000utki `rly keys show testnet-croeseid-4 cro_wallet` --path kichain
```
Send 1tcro to KiChain
```
rly tx transfer testnet-croeseid-4 kichain-t-4 1000000basetcro `rly keys show kichain-t-4 kichain_wallet` --path cro
```
Example of successful output
```
I[2021-09-12|23:44:57.052] ✔ [kichain-t-4]@{303033} - msg(0:transfer) hash(A7150C2D83EFF3B50CBAB6872B351213410B56C26E32128433B667865712EBD1)
```

