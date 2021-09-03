# $1 - language (RU/EN)
# $2 - raw JSON output (true/false)
#!/bin/bash
language="EN"
raw_output=false
# Data
node_tcp=$(cat $HOME/kichain/kid/config/config.toml | grep -oPm1 "(?<=^laddr = \")([^%]+)(?=\")")
status=$(kid status --node $node_tcp --home $HOME/kichain/kid/ 2>&1)
node_info=$(kid query staking validators --limit 1500 --output json | jq -r '.validators[] | select(.description.moniker=='\"$kichain_moniker\"')')
# Variables
moniker=$(jq ".description.moniker" <<< $node_info | tr -d '"')
identity=$(jq ".description.identity" <<< $node_info | tr -d '"')
website=$(jq ".description.website" <<< $node_info | tr -d '"')
details=$(jq ".description.details" <<< $node_info | tr -d '"')
network=$(jq ".NodeInfo.network" <<< $status | tr -d '"')
version=$(jq ".NodeInfo.version" <<< $status | tr -d '"')
validator_pub_key=$(kid tendermint show-validator --home $HOME/kichain/kid/ | tr -d '"')
validator_address=$(jq ".operator_address" <<< $node_info | tr -d '"')
jailed=$(jq ".jailed" <<< $node_info)
latest_block_height=$(jq ".SyncInfo.latest_block_height" <<< $status | tr -d '"')
catching_up=$(jq ".SyncInfo.catching_up" <<< $status)
delegated=$((`jq ".tokens" <<< $node_info | tr -d '"'`/1000000))
voting_power=$(jq ".ValidatorInfo.VotingPower" <<< $status | tr -d '"')
# Output
if [ "$2" = "true" ]; then
	printf '{"moniker":"%s",
"identity":"%s",
"website":"%s",
"details":"%s",
"network":"%s",
"version":"%s",
"validator_pub_key":"%s",
"validator_address":"%s",
"jailed":%b,
"latest_block_height":%d,
"catching_up":%b,
"delegated":%.2f,
"voting_power":%d}\n' "$moniker" "$identity" "$website" "$details" "$network" "$version" "$validator_pub_key" "$validator_address" "$jailed" "$latest_block_height" "$catching_up" "$delegated" "$voting_power"
else
	if [ "$1" = "RU" ]; then
		echo -e ""
		echo -e "Название ноды:                \e[40m\e[92m$moniker\e[0m"
		echo -e "Keybase ключ:                 \e[40m\e[92m$identity\e[0m"
		echo -e "Сайт:                         \e[40m\e[92m$website\e[0m"
		echo -e "Описание:                     \e[40m\e[92m$details\e[0m"
		echo -e "Сеть:                         \e[40m\e[92m$network\e[0m"
		echo -e "Версия ноды:                  \e[40m\e[92m$version\e[0m"
		echo -e ""
		echo -e "Публичный ключ валидатора:    \e[40m\e[92m$validator_pub_key\e[0m"
		echo -e "Адрес валидатора:             \e[40m\e[92m$validator_address\e[0m"
		if [ "$2" = "true" ]; then
			echo -e "Нода в тюрьме:                \033[0;31mда\e[0m\n"
		else
			echo -e "Нода в тюрьме:                \e[40m\e[92mнет\e[0m"
		fi
		echo -e "Последний блок:               \e[40m\e[92m$latest_block_height\e[0m"
		if [ "$2" = "true" ]; then
			echo -e "Нода синхронизирована:        \033[0;31mнет\e[0m"
		else
			echo -e "Нода синхронизирована:        \e[40m\e[92mда\e[0m"
		fi
		echo -e "Делегировано токенов на ноду: \e[40m\e[92m$delegated\e[0m"
		echo -e "Весомость голоса:                  \e[40m\e[92m$voting_power\e[0m"
		echo -e ""
	else
		echo -e ""
		echo -e "Moniker:                       \e[40m\e[92m$moniker\e[0m"
		echo -e "Keybase key:                   \e[40m\e[92m$identity\e[0m"
		echo -e "Website:                       \e[40m\e[92m$website\e[0m"
		echo -e "Details:                       \e[40m\e[92m$details\e[0m"
		echo -e "Network:                       \e[40m\e[92m$network\e[0m"
		echo -e "Node version:                  \e[40m\e[92m$version\e[0m"
		echo -e ""
		echo -e "Validator public key:          \e[40m\e[92m$validator_pub_key\e[0m"
		echo -e "Validator address:             \e[40m\e[92m$validator_address\e[0m"
		if [ "$2" = "true" ]; then
			echo -e "The node in a jail:            \033[0;31myes\e[0m\n"
		else
			echo -e "The node in a jail:            \e[40m\e[92mno\e[0m"
		fi
		echo -e "Latest block height:           \e[40m\e[92m$latest_block_height\e[0m"
		if [ "$2" = "true" ]; then
			echo -e "The node is synchronized:      \033[0;31mno\e[0m"
		else
			echo -e "The node is synchronized:      \e[40m\e[92myes\e[0m"
		fi
		echo -e "Delegated tokens to the node:  \e[40m\e[92m$delegated\e[0m"
		echo -e "Voting power:                  \e[40m\e[92m$voting_power\e[0m"
		echo -e ""
	fi
fi
