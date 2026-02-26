#!/bin/bash
# This script connects nodes and creates some channels.

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
alice-eclair-cli open --nodeId=$BOB_ID --fundingSatoshis=300000 --fundingFeeBudgetSatoshis=10000 --channelType=anchor_outputs_zero_fee_htlc_tx --announceChannel=true
alice-eclair-cli open --nodeId=$BOB_ID --fundingSatoshis=280000 --fundingFeeBudgetSatoshis=10000 --channelType=anchor_outputs_zero_fee_htlc_tx --announceChannel=false

echo Opening channels between Alice and Carol...
alice-eclair-cli connect --uri=$CAROL_ID@localhost:9737
alice-eclair-cli open --nodeId=$CAROL_ID --fundingSatoshis=350000 --fundingFeeBudgetSatoshis=10000 --announceChannel=true
alice-eclair-cli open --nodeId=$CAROL_ID --fundingSatoshis=240000 --fundingFeeBudgetSatoshis=10000

echo Opening channels between Bob and Dave...
bob-eclair-cli connect --uri=$DAVE_ID@localhost:9738
bob-eclair-cli open --nodeId=$DAVE_ID --fundingSatoshis=185000 --fundingFeeBudgetSatoshis=10000
bob-eclair-cli open --nodeId=$DAVE_ID --fundingSatoshis=195000 --fundingFeeBudgetSatoshis=10000
bob-eclair-cli open --nodeId=$DAVE_ID --fundingSatoshis=235000 --fundingFeeBudgetSatoshis=10000

echo Opening channels between Carol and Dave...
carol-eclair-cli connect --uri=$DAVE_ID@localhost:9738
carol-eclair-cli open --nodeId=$DAVE_ID --fundingSatoshis=255000 --fundingFeeBudgetSatoshis=10000
carol-eclair-cli open --nodeId=$DAVE_ID --fundingSatoshis=295000 --fundingFeeBudgetSatoshis=10000

sleep 10

echo Generating a few blocks to confirm channels...
MINER=$(btc-cli getnewaddress)
btc-cli generatetoaddress 10 $MINER

echo Awaiting confirmations...
sleep 10

echo Channels confirmed:
bob-eclair-cli channels | jq '.[] | {shortChannelId: .data.shortChannelId, capacity: .data.channelUpdate.htlcMaximumMsat, localCommit: .data.commitments.localCommit}'
carol-eclair-cli channels | jq '.[] | {shortChannelId: .data.shortChannelId, capacity: .data.channelUpdate.htlcMaximumMsat, localCommit: .data.commitments.localCommit}'

echo Creating and pay few invoices:
CAROL_INVOICE=$(carol-eclair-cli createinvoice --amountMsat=50000000 --description="Lightning is #reckless" | jq .serialized)
alice-eclair-cli payinvoice --invoice=$CAROL_INVOICE --blocking=true
BOB_INVOICE=$(bob-eclair-cli createinvoice --amountMsat=40000000 --description="Lightning is #reckless" | jq .serialized)
alice-eclair-cli payinvoice --invoice=$BOB_INVOICE --blocking=true
DAVE_INVOICE=$(dave-eclair-cli createinvoice --amountMsat=60000000 --description="Lightning is #reckless" | jq .serialized)
carol-eclair-cli payinvoice --invoice=$DAVE_INVOICE --blocking=true
