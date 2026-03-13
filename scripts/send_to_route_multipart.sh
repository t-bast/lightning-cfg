#!/bin/bash

# This script tests sending a multi-part payment with pre-defined routes.

shopt -s expand_aliases
source .bash_aliases

ALICE_ID=$(alice-eclair-cli getinfo | jq -r .nodeId)
BOB_ID=$(bob-eclair-cli getinfo | jq -r .nodeId)
CAROL_ID=$(carol-eclair-cli getinfo | jq -r .nodeId)
DAVE_ID=$(dave-eclair-cli getinfo | jq -r .nodeId)

echo Alice is $ALICE_ID
echo Bob is $BOB_ID
echo Carol is $CAROL_ID
echo Dave is $DAVE_ID

echo Opening channels between Alice and Bob...
alice-eclair-cli connect --uri=$BOB_ID@localhost:9736
alice-eclair-cli open --nodeId=$BOB_ID --fundingSatoshis=630000

echo Opening channels between Alice and Carol...
alice-eclair-cli connect --uri=$CAROL_ID@localhost:9737
alice-eclair-cli open --nodeId=$CAROL_ID --fundingSatoshis=240000

echo Opening channels between Bob and Dave...
bob-eclair-cli connect --uri=$DAVE_ID@localhost:9738
bob-eclair-cli open --nodeId=$DAVE_ID --fundingSatoshis=295000
bob-eclair-cli open --nodeId=$DAVE_ID --fundingSatoshis=305000

echo Opening channels between Carol and Dave...
carol-eclair-cli connect --uri=$DAVE_ID@localhost:9738
carol-eclair-cli open --nodeId=$DAVE_ID --fundingSatoshis=245000

echo Generating a few blocks to confirm channels...
MINER=$(btc-cli getnewaddress)
btc-cli generatetoaddress 10 $MINER

echo Awaiting confirmations...
sleep 30

echo Channels confirmed:
bob-eclair-cli channels | jq '.[] | {shortChannelId: .data.shortChannelId, capacity: .data.channelUpdate.htlcMaximumMsat}'

echo Generating invoice...
INVOICE=$(dave-eclair-cli createinvoice --amountMsat=600000000 --description="MPP is #reckless" | jq .serialized)

echo Awaiting broadcast network state...
sleep 60

echo Paying invoice
PAYMENT=$(alice-eclair-cli sendtoroute --amountMsat=230000000 --nodeIds=$ALICE_ID,$BOB_ID,$DAVE_ID --finalCltvExpiry=16 --invoice=$INVOICE)
echo $PAYMENT
PARENT_ID=$(echo $PAYMENT | jq .parentId)
alice-eclair-cli sendtoroute --amountMsat=220000000 --parentId=$PARENT_ID --nodeIds=$ALICE_ID,$BOB_ID,$DAVE_ID --finalCltvExpiry=16 --invoice=$INVOICE
alice-eclair-cli sendtoroute --amountMsat=150000000 --parentId=$PARENT_ID --nodeIds=$ALICE_ID,$CAROL_ID,$DAVE_ID --finalCltvExpiry=16 --invoice=$INVOICE

sleep 10

echo Checking payment status...
alice-eclair-cli getsentinfo --id=$PARENT_ID

echo Audit Alice
alice-eclair-cli audit
echo Audit Bob
bob-eclair-cli audit
echo Audit Carol
carol-eclair-cli audit
echo Audit Dave
dave-eclair-cli audit
