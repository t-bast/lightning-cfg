#!/bin/bash
# This script connects nodes and creates some channels.

shopt -s expand_aliases
source .bash_aliases

MINER=$(btc-cli getnewaddress)

ALICE_ID=$(alice-lnd-cli getinfo | jq -r .identity_pubkey)
BOB_ID=$(bob-lnd-cli getinfo | jq -r .identity_pubkey)
CAROL_ID=$(carol-lnd-cli getinfo | jq -r .identity_pubkey)
DAVE_ID=$(dave-lnd-cli getinfo | jq -r .identity_pubkey)

echo Alice is $ALICE_ID
echo Bob is $BOB_ID
echo Carol is $CAROL_ID
echo Dave is $DAVE_ID

echo Adding some Bitcoins to wallets...
ALICE_ADDR=$(alice-lnd-cli newaddress p2wkh | jq -r .address)
btc-cli sendtoaddress $ALICE_ADDR 20
BOB_ADDR=$(bob-lnd-cli newaddress p2wkh | jq -r .address)
btc-cli sendtoaddress $BOB_ADDR 15
CAROL_ADDR=$(carol-lnd-cli newaddress p2wkh | jq -r .address)
btc-cli sendtoaddress $CAROL_ADDR 10
DAVE_ADDR=$(dave-lnd-cli newaddress p2wkh | jq -r .address)
btc-cli sendtoaddress $DAVE_ADDR 5

echo Generating a few blocks to confirm wallet balances...
btc-cli generatetoaddress 10 $MINER

echo Opening channels between Alice and Bob...
alice-lnd-cli connect $BOB_ID@localhost:9736
alice-lnd-cli openchannel $BOB_ID 300000
alice-lnd-cli openchannel $BOB_ID 280000

echo Opening channels between Alice and Carol...
alice-lnd-cli connect $CAROL_ID@localhost:9737
alice-lnd-cli openchannel $CAROL_ID 290000
alice-lnd-cli openchannel $CAROL_ID 240000

echo Opening channels between Bob and Dave...
bob-lnd-cli connect $DAVE_ID@localhost:9738
bob-lnd-cli openchannel $DAVE_ID 185000
bob-lnd-cli openchannel $DAVE_ID 195000
bob-lnd-cli openchannel $DAVE_ID 235000

echo Opening channels between Carol and Dave...
carol-lnd-cli connect $DAVE_ID@localhost:9738
carol-lnd-cli openchannel $DAVE_ID 255000
carol-lnd-cli openchannel $DAVE_ID 295000

echo Generating a few blocks to confirm channels...
btc-cli generatetoaddress 10 $MINER

echo Awaiting confirmations...
sleep 10

echo Channels confirmed:
bob-lnd-cli listchannels | jq '.channels[] | {shortChannelId: .chan_id, capacity: .capacity, localBalance: .local_balance}'
carol-lnd-cli listchannels | jq '.channels[] | {shortChannelId: .chan_id, capacity: .capacity, localBalance: .local_balance}'

echo Creating a few invoices:
DAVE_INVOICE=$(dave-lnd-cli addinvoice --memo="Lightning is #reckless" 150000 | jq '. | {invoice: .payment_request, paymentHash: .r_hash}')
echo Dave pending invoice:
echo $DAVE_INVOICE
BOB_INVOICE=$(bob-lnd-cli addinvoice --memo="Lightning is #reckless" 200000 | jq '. | {invoice: .payment_request, paymentHash: .r_hash}')
echo Bob pending invoice:
echo $BOB_INVOICE
