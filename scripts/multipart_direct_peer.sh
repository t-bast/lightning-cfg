#!/bin/bash

# This script tests sending a multi-part payment to a direct peer.

shopt -s expand_aliases
source .bash_aliases

MINER=$(btc-cli getnewaddress)
ALICE_ID=$(alice-eclair-cli getinfo | jq -r .nodeId)
DAVE_ID=$(dave-lnd-cli getinfo | jq -r .identity_pubkey)

echo Alice is $ALICE_ID
echo Dave is $DAVE_ID

echo Adding some Bitcoins to wallets...
DAVE_ADDR=$(dave-lnd-cli newaddress p2wkh | jq -r .address)
btc-cli sendtoaddress $DAVE_ADDR 15

echo Generating a few blocks to confirm wallet balances...
btc-cli generatetoaddress 10 $MINER

echo Opening channels between Alice and Dave...
alice-eclair-cli connect --uri=$DAVE_ID@localhost:9738
alice-eclair-cli open --nodeId=$DAVE_ID --fundingSatoshis=110000
alice-eclair-cli open --nodeId=$DAVE_ID --fundingSatoshis=105000

echo Generating a few blocks to confirm channels...
btc-cli generatetoaddress 10 $MINER

echo Awaiting confirmations...
sleep 30

echo Channels confirmed:
alice-eclair-cli channels | jq '.[] | {shortChannelId: .data.shortChannelId, capacity: .data.channelUpdate.htlcMaximumMsat}'

echo Generating multi-part invoice...
INVOICE=$(dave-lnd-cli addinvoice --memo="MPP is #reckless" 130000 | jq .payment_request)

echo Awaiting broadcast network state...
sleep 60

echo Paying multi-part invoice
PAYMENT_ID=$(alice-eclair-cli payinvoice --invoice=$INVOICE --maxAttempts=1)
echo $PAYMENT_ID
sleep 10

alice-eclair-cli getsentinfo --id=$PAYMENT_ID

echo Generating multi-part invoice...
INVOICE2=$(alice-eclair-cli createinvoice --amountMsat=115000000 --description="MPP is #reckless" | jq .serialized)
PAYMENT_HASH=$(alice-eclair-cli listinvoices | jq '.[0] | .paymentHash')

echo Paying multi-part invoice
dave-lnd-cli sendpayment --pay_req=$INVOICE2
sleep 10

alice-eclair-cli getreceivedinfo --paymentHash=$PAYMENT_HASH
