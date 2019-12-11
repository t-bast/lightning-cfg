#!/bin/bash

# This script starts Bitcoin and generates a block.
# This makes sure Bitcoin isn't in IBD mode.

shopt -s expand_aliases
source .bash_aliases

bitcoind -daemon -datadir=.bitcoin

sleep 3

ADDR=$(btc-cli getnewaddress)
btc-cli generatetoaddress 150 $ADDR
