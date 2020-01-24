#!/bin/bash

# This script tests sending a multi-part payment to a direct peer.

shopt -s expand_aliases
source .bash_aliases

MINER=$(btc-cli getnewaddress)
ALICE_ID=$(alice-eclair-cli getinfo | jq -r .nodeId)
BOB_ID=$(bob-lnd-cli getinfo | jq -r .identity_pubkey)
CAROL_ID=$(carol-lnd-cli getinfo | jq -r .identity_pubkey)

echo Alice is $ALICE_ID
echo Bob is $BOB_ID
echo Carol is $CAROL_ID

echo Adding some Bitcoins to wallets...
BOB_ADDR=$(bob-lnd-cli newaddress p2wkh | jq -r .address)
btc-cli sendtoaddress $BOB_ADDR 5
CAROL_ADDR=$(carol-lnd-cli newaddress p2wkh | jq -r .address)
btc-cli sendtoaddress $CAROL_ADDR 10

echo Generating a few blocks to confirm wallet balances...
btc-cli generatetoaddress 10 $MINER

echo Opening channels between Alice and Bob...
alice-eclair-cli connect --uri=$BOB_ID@localhost:9736
alice-eclair-cli open --nodeId=$BOB_ID --fundingSatoshis=210000

echo Opening channels between Alice and Carol...
alice-eclair-cli connect --uri=$CAROL_ID@localhost:9737
alice-eclair-cli open --nodeId=$CAROL_ID --fundingSatoshis=215000

echo Opening channels between Bob and Carol...
carol-lnd-cli connect $BOB_ID@localhost:9736
carol-lnd-cli openchannel $BOB_ID 250000

echo Generating a few blocks to confirm channels...
btc-cli generatetoaddress 10 $MINER

echo Awaiting confirmations...
sleep 30

echo Channels confirmed:
alice-eclair-cli channels | jq '.[] | {shortChannelId: .data.shortChannelId, capacity: .data.channelUpdate.htlcMaximumMsat}'
carol-lnd-cli listchannels | jq '.channels[] | {shortChannelId: .chan_id, capacity: .capacity, localBalance: .local_balance}'

echo Awaiting broadcast network state...
sleep 60

echo Generating multi-part invoice...
BOB_INVOICE=$(bob-lnd-cli addinvoice --memo="MPP is #reckless" 300000 | jq .payment_request)
echo $BOB_INVOICE

echo Paying multi-part invoice
PAYMENT_ID=$(alice-eclair-cli payinvoice --invoice=$BOB_INVOICE --maxAttempts=1)
echo $PAYMENT_ID
sleep 10

alice-eclair-cli getsentinfo --id=$PAYMENT_ID

echo Generating multi-part invoice...
ALICE_INVOICE=$(alice-eclair-cli createinvoice --amountMsat=100000000 --description="MPP is #reckless" | jq .serialized)
echo $ALICE_INVOICE
PAYMENT_HASH=$(alice-eclair-cli listinvoices | jq '.[0] | .paymentHash')
echo $PAYMENT_HASH

echo Paying multi-part invoice
bob-lnd-cli sendpayment $ALICE_ID 70000000 $PAYMENT_HASH 12
# TODO: bob -> alice 70k, carol -> alice 30k
sleep 10

alice-eclair-cli getreceivedinfo --paymentHash=$PAYMENT_HASH
