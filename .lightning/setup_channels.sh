#!/bin/bash
# This script connects nodes and creates some channels.

shopt -s expand_aliases
source .bash_aliases

MINER=$(btc-cli getnewaddress)

ALICE_ID=$(alice-clightning-cli getinfo | jq -r .id)
BOB_ID=$(bob-clightning-cli getinfo | jq -r .id)
CAROL_ID=$(carol-clightning-cli getinfo | jq -r .id)
DAVE_ID=$(dave-clightning-cli getinfo | jq -r .id)

echo Alice is $ALICE_ID
echo Bob is $BOB_ID
echo Carol is $CAROL_ID
echo Dave is $DAVE_ID

echo Adding some Bitcoins to wallets...
ALICE_ADDR=$(alice-clightning-cli newaddr | jq -r .address)
btc-cli sendtoaddress $ALICE_ADDR 20
BOB_ADDR=$(bob-clightning-cli newaddr | jq -r .address)
btc-cli sendtoaddress $BOB_ADDR 15
CAROL_ADDR=$(carol-clightning-cli newaddr | jq -r .address)
btc-cli sendtoaddress $CAROL_ADDR 10
DAVE_ADDR=$(dave-clightning-cli newaddr | jq -r .address)
btc-cli sendtoaddress $DAVE_ADDR 5

echo Generating a few blocks to confirm wallet balances...
btc-cli generatetoaddress 10 $MINER

echo Opening channels between Alice and Bob...
alice-clightning-cli connect $BOB_ID localhost 9736
alice-clightning-cli fundchannel $BOB_ID 300000

echo Opening channels between Alice and Carol...
alice-clightning-cli connect $CAROL_ID localhost 9737
alice-clightning-cli fundchannel $CAROL_ID 290000

echo Opening channels between Bob and Dave...
bob-clightning-cli connect $DAVE_ID localhost 9738
bob-clightning-cli fundchannel $DAVE_ID 235000

echo Opening channels between Carol and Dave...
carol-clightning-cli connect $DAVE_ID localhost 9738
carol-clightning-cli fundchannel $DAVE_ID 295000

echo Generating a few blocks to confirm channels...
btc-cli generatetoaddress 10 $MINER

echo Awaiting confirmations...
sleep 10

echo Channels confirmed:
bob-clightning-cli listchannels | jq '.channels[] | {shortChannelId: .short_channel_id, capacity: .amount_msat}'
carol-clightning-cli listchannels | jq '.channels[] | {shortChannelId: .short_channel_id, capacity: .amount_msat}'

echo Creating a few invoices:
DAVE_INVOICE=$(dave-clightning-cli invoice 150000000 "#lightning" "Lightning is #reckless" | jq '. | {invoice: .bolt11, paymentHash: .payment_hash}')
echo Dave pending invoice:
echo $DAVE_INVOICE
BOB_INVOICE=$(bob-clightning-cli invoice 200000000 "#lightning" "Lightning is #reckless" | jq '. | {invoice: .bolt11, paymentHash: .payment_hash}')
echo Bob pending invoice:
echo $BOB_INVOICE
