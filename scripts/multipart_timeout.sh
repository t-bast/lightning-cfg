#!/bin/bash

# This script tests multi-part payment timeout handling.

shopt -s expand_aliases
source .bash_aliases

MINER=$(btc-cli getnewaddress)
ALICE_ID=$(alice-eclair-cli getinfo | jq -r .nodeId)
BOB_ID=$(bob-eclair-cli getinfo | jq -r .nodeId)
CAROL_ID=$(carol-eclair-cli getinfo | jq -r .nodeId)
DAVE_ID=$(dave-clightning-cli getinfo | jq -r .id)

echo Alice is $ALICE_ID
echo Bob is $BOB_ID
echo Carol is $CAROL_ID
echo Dave is $DAVE_ID

echo Adding some Bitcoins to wallets...
DAVE_ADDR=$(dave-clightning-cli newaddr | jq -r .bech32)
btc-cli sendtoaddress $DAVE_ADDR 15

echo Generating a few blocks to confirm wallet balances...
btc-cli generatetoaddress 10 $MINER

echo Opening channels between Alice and Bob...
alice-eclair-cli connect --uri=$BOB_ID@localhost:9736
alice-eclair-cli open --nodeId=$BOB_ID --fundingSatoshis=300000

echo Opening channels between Alice and Carol...
alice-eclair-cli connect --uri=$CAROL_ID@localhost:9737
alice-eclair-cli open --nodeId=$CAROL_ID --fundingSatoshis=240000

echo Opening channels between Bob and Dave...
bob-eclair-cli connect --uri=$DAVE_ID@localhost:9738
bob-eclair-cli open --nodeId=$DAVE_ID --fundingSatoshis=310000

echo Opening channels between Carol and Dave...
carol-eclair-cli connect --uri=$DAVE_ID@localhost:9738
carol-eclair-cli open --nodeId=$DAVE_ID --fundingSatoshis=285000

echo Generating a few blocks to confirm channels...
btc-cli generatetoaddress 10 $MINER

echo Awaiting confirmations...
sleep 30

echo Channels confirmed:
bob-eclair-cli channels | jq '.[] | {shortChannelId: .data.shortChannelId, capacity: .data.channelUpdate.htlcMaximumMsat}'
carol-eclair-cli channels | jq '.[] | {shortChannelId: .data.shortChannelId, capacity: .data.channelUpdate.htlcMaximumMsat}'

echo Generating multi-part invoice...
DAVE_INVOICE=$(dave-clightning-cli invoice 250000000 "#lightning" "MPP is #reckless" | jq '. | {invoice: .bolt11, paymentHash: .payment_hash}')
INVOICE=$(echo $DAVE_INVOICE | jq .invoice)
PAYMENT_HASH=$(echo $DAVE_INVOICE | jq .paymentHash)
echo $PAYMENT_HASH

echo Awaiting broadcast network state...
sleep 60

echo Paying multi-part invoice first part
PAYMENT_ID_1=$(alice-eclair-cli sendtoroute --amountMsat=100000000 --paymentHash=$PAYMENT_HASH --route=$ALICE_ID,$BOB_ID,$DAVE_ID --finalCltvExpiry=144 --invoice=$INVOICE)
echo $PAYMENT_ID_1

echo Paying multi-part invoice second part
PAYMENT_ID_2=$(alice-eclair-cli sendtoroute --amountMsat=100000000 --paymentHash=$PAYMENT_HASH --route=$ALICE_ID,$CAROL_ID,$DAVE_ID --finalCltvExpiry=144 --invoice=$INVOICE)
echo $PAYMENT_ID_2

echo Waiting for a timeout...
sleep 70

alice-eclair-cli getsentinfo --id=$PAYMENT_ID_1
alice-eclair-cli getsentinfo --id=$PAYMENT_ID_2
