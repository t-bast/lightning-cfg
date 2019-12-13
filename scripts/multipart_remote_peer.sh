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
alice-eclair-cli open --nodeId=$BOB_ID --fundingSatoshis=210000

echo Opening channels between Alice and Carol...
alice-eclair-cli connect --uri=$CAROL_ID@localhost:9737
alice-eclair-cli open --nodeId=$CAROL_ID --fundingSatoshis=240000

echo Opening channels between Bob and Dave...
bob-eclair-cli connect --uri=$DAVE_ID@localhost:9738
bob-eclair-cli open --nodeId=$DAVE_ID --fundingSatoshis=220000

echo Opening channels between Carol and Dave...
carol-eclair-cli connect --uri=$DAVE_ID@localhost:9738
carol-eclair-cli open --nodeId=$DAVE_ID --fundingSatoshis=250000

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
INVOICE2=$(alice-eclair-cli createinvoice --amountMsat=100000000 --description="MPP is #reckless" | jq .serialized)
PAYMENT_HASH=$(alice-eclair-cli listinvoices | jq '.[0] | .paymentHash')
sleep 10

echo Paying multi-part invoice
PAYMENT_SECRET=$(dave-clightning-cli decodepay $INVOICE2 | jq .payment_secret)
ROUTE1=$(dave-clightning-cli getroute $ALICE_ID 50000000 0 null null null [$BOB_ID] | jq -c .route)
dave-clightning-cli sendpay $ROUTE1 $PAYMENT_HASH null 100000000 $INVOICE2 $PAYMENT_SECRET 1
sleep 5

ROUTE2=$(dave-clightning-cli getroute $ALICE_ID 50000000 0 null null null [$CAROL_ID] | jq -c .route)
dave-clightning-cli sendpay $ROUTE2 $PAYMENT_HASH null 100000000 $INVOICE2 $PAYMENT_SECRET 2
sleep 5

alice-eclair-cli getreceivedinfo --paymentHash=$PAYMENT_HASH
