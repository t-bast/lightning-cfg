#!/bin/bash

# This script tests sending a multi-part trampoline payment, similar to what Phoenix does when
# sending to another Phoenix.

shopt -s expand_aliases
source .bash_aliases

ALICE_ID=$(alice-eclair-cli getinfo | jq -r .nodeId)
BOB_ID=$(bob-eclair-cli getinfo | jq -r .nodeId)
CAROL_ID=$(carol-eclair-cli getinfo | jq -r .nodeId)

echo Alice is $ALICE_ID
echo Bob is $BOB_ID
echo Carol is $CAROL_ID

echo Opening channel between Alice and Bob...
alice-eclair-cli connect --uri=$BOB_ID@localhost:9736
alice-eclair-cli open --nodeId=$BOB_ID --fundingSatoshis=510000

echo Opening channels between Bob and Carol...
bob-eclair-cli connect --uri=$CAROL_ID@localhost:9737
bob-eclair-cli open --nodeId=$CAROL_ID --fundingSatoshis=370000
bob-eclair-cli open --nodeId=$CAROL_ID --fundingSatoshis=180000

echo Generating a few blocks to confirm channels...
MINER=$(bitcoin-cli getnewaddress)
bitcoin-cli generatetoaddress 10 $MINER

echo Awaiting confirmations...
sleep 30

echo Channels confirmed:
bob-eclair-cli channels | jq '.[] | {shortChannelId: .data.shortChannelId, capacity: .data.channelUpdate.htlcMaximumMsat}'

echo Generating trampoline invoice...
INVOICE=$(carol-eclair-cli createinvoice --amountMsat=420000000 --description="Trampoline is #reckless" | jq .serialized)

echo Awaiting broadcast network state...
sleep 60

echo Paying trampoline invoice
# Note that the trampoline fee must be the same and needs to be taken into account in the amountMsat values.
PAYMENT1=$(alice-eclair-cli sendtoroute --amountMsat=220060000 --route=$ALICE_ID,$BOB_ID --trampolineNodes=$BOB_ID,$CAROL_ID --trampolineFeesMsat=100000 --trampolineCltvExpiry=144 --finalCltvExpiry=16 --invoice=$INVOICE)
echo $PAYMENT1
PARENT_ID=$(echo $PAYMENT1 | jq .parentId)
SECRET=$(echo $PAYMENT1 | jq .trampolineSecret)
PAYMENT2=$(alice-eclair-cli sendtoroute --amountMsat=200040000 --parentId=$PARENT_ID --trampolineSecret=$SECRET --route=$ALICE_ID,$BOB_ID --trampolineNodes=$BOB_ID,$CAROL_ID --trampolineFeesMsat=100000 --trampolineCltvExpiry=144 --finalCltvExpiry=16 --invoice=$INVOICE)
echo $PAYMENT2

sleep 10

echo Checking payment status...
alice-eclair-cli getsentinfo --id=$PARENT_ID

echo Audit Alice
alice-eclair-cli audit
echo Audit Bob
bob-eclair-cli audit
echo Audit Carol
carol-eclair-cli audit
