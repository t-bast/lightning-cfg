#!/bin/bash

# This script tests sending a multi-part payment to a remote peer.

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
DAVE_ADDR=$(dave-clightning-cli newaddr | jq -r .address)
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
bob-eclair-cli open --nodeId=$DAVE_ID --fundingSatoshis=420000

echo Opening channels between Carol and Dave...
carol-eclair-cli connect --uri=$DAVE_ID@localhost:9738
carol-eclair-cli open --nodeId=$DAVE_ID --fundingSatoshis=510000

echo Generating a few blocks to confirm channels...
btc-cli generatetoaddress 10 $MINER

echo Awaiting confirmations...
sleep 30

echo Channels confirmed:
bob-eclair-cli channels | jq '.[] | {shortChannelId: .data.shortChannelId, capacity: .data.channelUpdate.htlcMaximumMsat}'
carol-eclair-cli channels | jq '.[] | {shortChannelId: .data.shortChannelId, capacity: .data.channelUpdate.htlcMaximumMsat}'

echo Generating multi-part invoice...
INVOICE=$(dave-clightning-cli invoice 280000000 "#lightning" "MPP is #reckless" | jq .bolt11)

echo Awaiting broadcast network state...
sleep 60

echo Paying multi-part invoice
PAYMENT_ID=$(alice-eclair-cli payinvoice --invoice=$INVOICE --maxAttempts=3)
echo $PAYMENT_ID
sleep 10

alice-eclair-cli getsentinfo --id=$PAYMENT_ID

echo Generating multi-part invoice...
INVOICE2=$(alice-eclair-cli createinvoice --amountMsat=230000000 --description="MPP is #reckless" --allowMultiPart=true | jq .serialized)
PAYMENT_HASH=$(alice-eclair-cli listinvoices | jq '.[0] | .paymentHash')

echo Paying multi-part invoice
dave-clightning-cli pay $INVOICE2
sleep 10

alice-eclair-cli getreceivedinfo --paymentHash=$PAYMENT_HASH
