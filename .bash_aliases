
##### Bitcoin #####

alias btc-cli='bitcoin-cli -datadir=.bitcoin'

##### C-Lightning #####

# Set the path to the lightningd and lightning-cli binaries:
CLIGHTNING_BIN=/usr/local/bin/lightningd
CLIGHTNING_CLI=/usr/local/bin/lightning-cli

alias alice-cln='$CLIGHTNING_BIN --lightning-dir=.lightning/alice --experimental-dual-fund --experimental-splicing'
alias alice-cln-cli='$CLIGHTNING_CLI --lightning-dir=.lightning/alice'
alias bob-cln='$CLIGHTNING_BIN --lightning-dir=.lightning/bob --experimental-dual-fund --experimental-splicing'
alias bob-cln-cli='$CLIGHTNING_CLI --lightning-dir=.lightning/bob'
alias carol-cln='$CLIGHTNING_BIN --lightning-dir=.lightning/carol'
alias carol-cln-cli='$CLIGHTNING_CLI --lightning-dir=.lightning/carol'
alias dave-cln='$CLIGHTNING_BIN --lightning-dir=.lightning/dave'
alias dave-cln-cli='$CLIGHTNING_CLI --lightning-dir=.lightning/dave'

##### Eclair #####

# Set the path to the eclair-node release to use:
ECLAIR=.eclair/bin/eclair-node-0.14.0-SNAPSHOT-d473b53/bin/eclair-node.sh
ECLAIR_RELEASE=.eclair/bin/eclair-node-0.13.0-992ec8c/bin/eclair-node.sh
# Set the path to the eclair-cli file (see https://github.com/ACINQ/eclair/wiki/Usage):
ECLAIR_CLI=.eclair/bin/eclair-node-0.14.0-SNAPSHOT-d473b53/bin/eclair-cli
# Set the path to the eclair logging configuration to use (default one provided in .eclair):
ECLAIR_LOG_CONF=.eclair/logback.xml

alias alice-eclair='$ECLAIR -Dlogback.configurationFile=$ECLAIR_LOG_CONF -Declair.datadir=.eclair/alice -Declair.allow-unsafe-startup=true'
alias alice-eclair-cli='$ECLAIR_CLI -p password -a localhost:9000'
alias bob-eclair='$ECLAIR -Dlogback.configurationFile=$ECLAIR_LOG_CONF -Declair.datadir=.eclair/bob -Declair.allow-unsafe-startup=true'
alias bob-eclair-cli='$ECLAIR_CLI -p password -a localhost:9001'
alias carol-eclair='$ECLAIR -Dlogback.configurationFile=$ECLAIR_LOG_CONF -Declair.datadir=.eclair/carol -Declair.allow-unsafe-startup=true'
alias carol-eclair-cli='$ECLAIR_CLI -p password -a localhost:9002'
alias dave-eclair='$ECLAIR -Dlogback.configurationFile=$ECLAIR_LOG_CONF -Declair.datadir=.eclair/dave -Declair.allow-unsafe-startup=true'
alias dave-eclair-cli='$ECLAIR_CLI -p password -a localhost:9003'

##### LND #####

# Set the path to the lnd and lncli binaries:
LND_BIN=.lnd/bin/lnd
LND_CLI=.lnd/bin/lncli

alias alice-lnd='$LND_BIN --lnddir=.lnd/alice'
alias alice-lnd-cli='$LND_CLI --lnddir=.lnd/alice --rpcserver=localhost:10009 --network=regtest'
alias bob-lnd='$LND_BIN --lnddir=.lnd/bob'
alias bob-lnd-cli='$LND_CLI --lnddir=.lnd/bob --rpcserver=localhost:10010 --network=regtest'
alias carol-lnd='$LND_BIN --lnddir=.lnd/carol'
alias carol-lnd-cli='$LND_CLI --lnddir=.lnd/carol --rpcserver=localhost:10011 --network=regtest'
alias dave-lnd='$LND_BIN --lnddir=.lnd/dave'
alias dave-lnd-cli='$LND_CLI --lnddir=.lnd/dave --rpcserver=localhost:10012 --network=regtest'

##### LDK #####

LDK_BIN=.ldk/bin/ldk-server
LDK_CLI=.ldk/bin/ldk-server-cli

alias alice-ldk='$LDK_BIN .ldk/alice/config.toml'
alias alice-ldk-cli='$LDK_CLI -b localhost:9000'
alias bob-ldk='$LDK_BIN .ldk/bob/config.toml'
alias bob-ldk-cli='$LDK_CLI -b localhost:9001'
