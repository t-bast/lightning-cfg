#!/bin/bash

# This script tests sending a trampoline payment with a pre-defined route, similar to what Phoenix
# does when sending to a non-trampoline wallet.

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

echo Opening channel between Alice and Bob...
alice-eclair-cli connect --uri=$BOB_ID@localhost:9736
alice-eclair-cli open --nodeId=$BOB_ID --fundingSatoshis=490000

echo Opening channels between Bob and Carol...
bob-eclair-cli connect --uri=$CAROL_ID@localhost:9737
bob-eclair-cli open --nodeId=$CAROL_ID --fundingSatoshis=285000
bob-eclair-cli open --nodeId=$CAROL_ID --fundingSatoshis=305000

echo Opening channels between Carol and Dave...
carol-eclair-cli connect --uri=$DAVE_ID@localhost:9738
carol-eclair-cli open --nodeId=$DAVE_ID --fundingSatoshis=500000

echo Generating a few blocks to confirm channels...
MINER=$(btc-cli getnewaddress)
btc-cli generatetoaddress 10 $MINER

echo Awaiting confirmations...
sleep 60

echo Channels confirmed:
alice-eclair-cli channels | jq '.[] | {shortChannelId: .data.shortChannelId, capacity: .data.channelUpdate.htlcMaximumMsat}'
dave-eclair-cli channels | jq '.[] | {shortChannelId: .data.shortChannelId, capacity: .data.channelUpdate.htlcMaximumMsat}'

echo Generating non-trampoline invoice...
# Dave doesn't have Trampoline enabled.
INVOICE=$(dave-eclair-cli createinvoice --amountMsat=310000000 --description="Trampoline is #reckless" | jq .serialized)

echo Awaiting broadcast network state...
sleep 60

echo Paying trampoline invoice
# Note that the trampoline fee must be the same and needs to be taken into account in the amountMsat values.
PAYMENT1=$(alice-eclair-cli sendtoroute --amountMsat=160050000 --nodeIds=$ALICE_ID,$BOB_ID --trampolineNodes=$BOB_ID,$DAVE_ID --trampolineFeesMsat=80000 --trampolineCltvExpiry=432 --finalCltvExpiry=16 --invoice=$INVOICE)
echo $PAYMENT1
PARENT_ID=$(echo $PAYMENT1 | jq .parentId)
SECRET=$(echo $PAYMENT1 | jq .trampolineSecret)
PAYMENT2=$(alice-eclair-cli sendtoroute --amountMsat=150030000 --parentId=$PARENT_ID --trampolineSecret=$SECRET --nodeIds=$ALICE_ID,$BOB_ID --trampolineNodes=$BOB_ID,$DAVE_ID --trampolineFeesMsat=80000 --trampolineCltvExpiry=432 --finalCltvExpiry=16 --invoice=$INVOICE)
echo $PAYMENT2

sleep 15

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
