
##### Bitcoin #####

alias btc-cli='bitcoin-cli -datadir=.bitcoin'

##### C-Lightning #####

# Set the path to the lightningd and lightning-cli binaries:
CLIGHTNING_BIN=/usr/local/bin/lightningd
CLIGHTNING_CLI=/usr/local/bin/lightning-cli

alias alice-clightning='$CLIGHTNING_BIN --lightning-dir=.lightning/alice'
alias alice-clightning-cli='$CLIGHTNING_CLI --lightning-dir=.lightning/alice'
alias bob-clightning='$CLIGHTNING_BIN --lightning-dir=.lightning/bob'
alias bob-clightning-cli='$CLIGHTNING_CLI --lightning-dir=.lightning/bob'
alias carol-clightning='$CLIGHTNING_BIN --lightning-dir=.lightning/carol'
alias carol-clightning-cli='$CLIGHTNING_CLI --lightning-dir=.lightning/carol'
alias dave-clightning='$CLIGHTNING_BIN --lightning-dir=.lightning/dave'
alias dave-clightning-cli='$CLIGHTNING_CLI --lightning-dir=.lightning/dave'

##### Eclair #####

# Set the path to the eclair-node release to use:
ECLAIR=$HOME/Downloads/eclair-node-x.x.x-xxxxxxx/bin/eclair-node.sh
# Set the path to the eclair-cli file (see https://github.com/ACINQ/eclair/wiki/Usage):
ECLAIR_CLI=$HOME/Downloads/eclair-node-x.x.x-xxxxxxx/bin/eclair-cli
# Set the path to the eclair logging configuration to use (default one provided in .eclair):
ECLAIR_LOG_CONF=.eclair/logback.xml

alias alice-eclair='$ECLAIR -Dlogback.configurationFile=$ECLAIR_LOG_CONF -Declair.datadir=.eclair/alice'
alias alice-eclair-cli='$ECLAIR_CLI -p password -a localhost:9000'
alias bob-eclair='$ECLAIR -Dlogback.configurationFile=$ECLAIR_LOG_CONF -Declair.datadir=.eclair/bob'
alias bob-eclair-cli='$ECLAIR_CLI -p password -a localhost:9001'
alias carol-eclair='$ECLAIR -Dlogback.configurationFile=$ECLAIR_LOG_CONF -Declair.datadir=.eclair/carol'
alias carol-eclair-cli='$ECLAIR_CLI -p password -a localhost:9002'
alias dave-eclair='$ECLAIR -Dlogback.configurationFile=$ECLAIR_LOG_CONF -Declair.datadir=.eclair/dave'
alias dave-eclair-cli='$ECLAIR_CLI -p password -a localhost:9003'

##### LND #####

# Set the path to the lnd and lncli binaries:
LND_BIN=$HOME/go/bin/lnd
LND_CLI=$HOME/go/bin/lncli

alias alice-lnd='$LND_BIN --lnddir=.lnd/alice'
alias alice-lnd-cli='$LND_CLI --lnddir=.lnd/alice --rpcserver=localhost:10009 --network=regtest'
alias bob-lnd='$LND_BIN --lnddir=.lnd/bob'
alias bob-lnd-cli='$LND_CLI --lnddir=.lnd/bob --rpcserver=localhost:10010 --network=regtest'
alias carol-lnd='$LND_BIN --lnddir=.lnd/carol'
alias carol-lnd-cli='$LND_CLI --lnddir=.lnd/carol --rpcserver=localhost:10011 --network=regtest'
alias dave-lnd='$LND_BIN --lnddir=.lnd/dave'
alias dave-lnd-cli='$LND_CLI --lnddir=.lnd/dave --rpcserver=localhost:10012 --network=regtest'
