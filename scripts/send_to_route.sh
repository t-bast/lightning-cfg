#!/bin/bash

# This script tests sending a payment with a pre-defined route.

shopt -s expand_aliases
source .bash_aliases

ALICE_ID=$(alice-eclair-cli getinfo | jq -r .nodeId)
BOB_ID=$(bob-eclair-cli getinfo | jq -r .nodeId)
CAROL_ID=$(carol-eclair-cli getinfo | jq -r .nodeId)

echo Alice is $ALICE_ID
echo Bob is $BOB_ID
echo Carol is $CAROL_ID

echo Opening channels between Alice and Bob...
alice-eclair-cli connect --uri=$BOB_ID@localhost:9736
alice-eclair-cli open --nodeId=$BOB_ID --fundingSatoshis=600000

echo Opening channels between Bob and Carol...
bob-eclair-cli connect --uri=$CAROL_ID@localhost:9737
bob-eclair-cli open --nodeId=$CAROL_ID --fundingSatoshis=500000

echo Generating a few blocks to confirm channels...
MINER=$(bitcoin-cli getnewaddress)
bitcoin-cli generatetoaddress 10 $MINER

echo Awaiting confirmations...
sleep 30

echo Channels confirmed:
bob-eclair-cli channels | jq '.[] | {shortChannelId: .data.shortChannelId, capacity: .data.channelUpdate.htlcMaximumMsat}'

echo Generating invoices...
INVOICE1=$(carol-eclair-cli createinvoice --amountMsat=250000000 --description="yolo" | jq .serialized)
INVOICE2=$(carol-eclair-cli createinvoice --amountMsat=200000000 --description="swag" | jq .serialized)

echo Awaiting broadcast network state...
sleep 60

echo Paying first invoice
PAYMENT_ID1=$(alice-eclair-cli sendtoroute --amountMsat=250000000 --route=$ALICE_ID,$BOB_ID,$CAROL_ID --finalCltvExpiry=16 --invoice=$INVOICE1 | jq .parentId)
sleep 10

echo Checking payment status...
alice-eclair-cli getsentinfo --id=$PAYMENT_ID1

echo Paying second invoice
PAYMENT_ID2=$(alice-eclair-cli sendtoroute --amountMsat=200000000 --route=$ALICE_ID,$BOB_ID,$CAROL_ID --finalCltvExpiry=16 --invoice=$INVOICE2 | jq .parentId)
sleep 10

echo Checking payment status...
alice-eclair-cli getsentinfo --id=$PAYMENT_ID2

echo Audit Alice
alice-eclair-cli audit
echo Audit Bob
bob-eclair-cli audit
echo Audit Carol
carol-eclair-cli audit
