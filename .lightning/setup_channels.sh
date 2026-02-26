#!/bin/bash
# This script connects nodes and creates some channels.

shopt -s expand_aliases
source .bash_aliases

MINER=$(btc-cli getnewaddress)

ALICE_ID=$(alice-cln-cli getinfo | jq -r .id)
BOB_ID=$(bob-cln-cli getinfo | jq -r .id)
CAROL_ID=$(carol-cln-cli getinfo | jq -r .id)
DAVE_ID=$(dave-cln-cli getinfo | jq -r .id)

echo Alice is $ALICE_ID
echo Bob is $BOB_ID
echo Carol is $CAROL_ID
echo Dave is $DAVE_ID

echo Adding some Bitcoins to wallets...
ALICE_ADDR=$(alice-cln-cli newaddr | jq -r .bech32)
btc-cli sendtoaddress $ALICE_ADDR 20
BOB_ADDR=$(bob-cln-cli newaddr | jq -r .bech32)
btc-cli sendtoaddress $BOB_ADDR 15
CAROL_ADDR=$(carol-cln-cli newaddr | jq -r .bech32)
btc-cli sendtoaddress $CAROL_ADDR 10
DAVE_ADDR=$(dave-cln-cli newaddr | jq -r .bech32)
btc-cli sendtoaddress $DAVE_ADDR 5

echo Generating a few blocks to confirm wallet balances...
btc-cli generatetoaddress 10 $MINER

echo Opening channels between Alice and Bob...
alice-cln-cli connect $BOB_ID localhost 9736
alice-cln-cli fundchannel $BOB_ID 300000

echo Opening channels between Alice and Carol...
alice-cln-cli connect $CAROL_ID localhost 9737
alice-cln-cli fundchannel $CAROL_ID 290000

echo Opening channels between Bob and Dave...
bob-cln-cli connect $DAVE_ID localhost 9738
bob-cln-cli fundchannel $DAVE_ID 235000

echo Opening channels between Carol and Dave...
carol-cln-cli connect $DAVE_ID localhost 9738
carol-cln-cli fundchannel $DAVE_ID 295000

echo Generating a few blocks to confirm channels...
btc-cli generatetoaddress 10 $MINER

echo Awaiting confirmations...
sleep 10

echo Channels confirmed:
bob-cln-cli listchannels | jq '.channels[] | {shortChannelId: .short_channel_id, capacity: .amount_msat}'
carol-cln-cli listchannels | jq '.channels[] | {shortChannelId: .short_channel_id, capacity: .amount_msat}'

echo Creating a few invoices:
DAVE_INVOICE=$(dave-cln-cli invoice 150000000 "#lightning" "Lightning is #reckless" | jq '. | {invoice: .bolt11, paymentHash: .payment_hash}')
echo Dave pending invoice:
echo $DAVE_INVOICE
BOB_INVOICE=$(bob-cln-cli invoice 200000000 "#lightning" "Lightning is #reckless" | jq '. | {invoice: .bolt11, paymentHash: .payment_hash}')
echo Bob pending invoice:
echo $BOB_INVOICE
