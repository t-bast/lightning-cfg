#!/bin/bash
# This script tests anchor outputs compatibility.

shopt -s expand_aliases
source .bash_aliases

ALICE_ID=$(alice-eclair-cli getinfo | jq -r .nodeId)
BOB_ID=$(bob-lnd-cli getinfo | jq -r .identity_pubkey)
MINER=$(btc-cli getnewaddress)

echo Alice is $ALICE_ID
echo Bob is $BOB_ID

echo Adding some Bitcoins to wallets...
BOB_ADDR=$(bob-lnd-cli newaddress p2wkh | jq -r .address)
btc-cli sendtoaddress $BOB_ADDR 15

echo Generating a few blocks to confirm wallet balances...
btc-cli generatetoaddress 10 $MINER
sleep 15

echo Opening channels between Alice and Bob...
alice-eclair-cli connect --uri=$BOB_ID@localhost:9736
alice-eclair-cli open --nodeId=$BOB_ID --fundingSatoshis=300000

echo Generating a few blocks to confirm channels...
sleep 3
btc-cli generatetoaddress 10 $MINER

echo Awaiting confirmations...
sleep 10

echo Paying invoices...
BOB_INVOICE_REGULAR=$(bob-lnd-cli addinvoice --memo="anchor outputs is #reckless" 15000 | jq .payment_request)
alice-eclair-cli payinvoice --invoice=$BOB_INVOICE_REGULAR
sleep 2
BOB_INVOICE_SMALL=$(bob-lnd-cli addinvoice --memo="almost dust" 546 | jq .payment_request)
alice-eclair-cli payinvoice --invoice=$BOB_INVOICE_SMALL
sleep 2
BOB_INVOICE_DUST=$(bob-lnd-cli addinvoice --memo="dust" 545 | jq .payment_request)
alice-eclair-cli payinvoice --invoice=$BOB_INVOICE_DUST
sleep 2

ALICE_INVOICE_REGULAR=$(alice-eclair-cli createinvoice --amountMsat=11000000 --description="anchor outputs is #reckless" | jq -r .serialized)
bob-lnd-cli sendpayment --pay_req=$ALICE_INVOICE_REGULAR
sleep 2
ALICE_INVOICE_SMALL=$(alice-eclair-cli createinvoice --amountMsat=546000 --description="almost dust" | jq -r .serialized)
bob-lnd-cli sendpayment --pay_req=$ALICE_INVOICE_SMALL
sleep 2
ALICE_INVOICE_DUST=$(alice-eclair-cli createinvoice --amountMsat=545000 --description="dust" | jq -r .serialized)
bob-lnd-cli sendpayment --pay_req=$ALICE_INVOICE_DUST
sleep 2

echo All invoices paid
