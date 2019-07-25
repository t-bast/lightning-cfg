
##### C-Lightning #####

# Set the path to the lightningd and lightning-cli binaries:
CLIGHTNING_BIN=/usr/bin/lightningd
CLIGHTNING_CLI=/usr/bin/lightning-cli

alias alice-clightning='$CLIGHTNING_BIN --lightning-dir=$HOME/.lightning/alice'
alias alice-clightning-cli='$CLIGHTNING_CLI --lightning-dir=$HOME/.lightning/alice'
alias bob-clightning='$CLIGHTNING_BIN --lightning-dir=$HOME/.lightning/bob'
alias bob-clightning-cli='$CLIGHTNING_CLI --lightning-dir=$HOME/.lightning/bob'
alias carol-clightning='$CLIGHTNING_BIN --lightning-dir=$HOME/.lightning/carol'
alias carol-clightning-cli='$CLIGHTNING_CLI --lightning-dir=$HOME/.lightning/carol'
alias dave-clightning='$CLIGHTNING_BIN --lightning-dir=$HOME/.lightning/dave'
alias dave-clightning-cli='$CLIGHTNING_CLI --lightning-dir=$HOME/.lightning/dave'

##### Eclair #####

# Set the path to the eclair-node jar to use:
ECLAIR_JAR=$HOME/.m2/repository/fr/acinq/eclair/eclair-node_2.11/0.3.2-SNAPSHOT/eclair-node_2.11-0.3.2-SNAPSHOT-capsule.jar
# Set the path to the eclair-cli file (see https://github.com/ACINQ/eclair/wiki/Usage):
ECLAIR_CLI=/usr/bin/eclair-cli
# Set the path to the eclair logging configuration to use (default one provided in .eclair):
ECLAIR_LOG_CONF=$HOME/.eclair/logback.xml

alias alice-eclair='java -Dlogback.configurationFile=$ECLAIR_LOG_CONF -Declair.datadir=$HOME/.eclair/alice -jar $ECLAIR_JAR'
alias alice-eclair-cli='$ECLAIR_CLI -p password -a localhost:9000'
alias bob-eclair='java -Dlogback.configurationFile=$ECLAIR_LOG_CONF -Declair.datadir=$HOME/.eclair/bob -jar $ECLAIR_JAR'
alias bob-eclair-cli='$ECLAIR_CLI -p password -a localhost:9001'
alias carol-eclair='java -Dlogback.configurationFile=$ECLAIR_LOG_CONF -Declair.datadir=$HOME/.eclair/carol -jar $ECLAIR_JAR'
alias carol-eclair-cli='$ECLAIR_CLI -p password -a localhost:9002'
alias dave-eclair='java -Dlogback.configurationFile=$ECLAIR_LOG_CONF -Declair.datadir=$HOME/.eclair/dave -jar $ECLAIR_JAR'
alias dave-eclair-cli='$ECLAIR_CLI -p password -a localhost:9003'

##### LND #####

# Set the path to the lnd and lncli binaries:
LND_BIN=$HOME/go/bin/lnd
LND_CLI=$HOME/go/bin/lncli

alias alice-lnd='$LND_BIN --lnddir=$HOME/.lnd/alice'
alias alice-lnd-cli='$LND_CLI --lnddir=$HOME/.lnd/alice --rpcserver=localhost:10009 --network=regtest'
alias bob-lnd='$LND_BIN --lnddir=$HOME/.lnd/bob'
alias bob-lnd-cli='$LND_CLI --lnddir=$HOME/.lnd/bob --rpcserver=localhost:10010 --network=regtest'
alias carol-lnd='$LND_BIN --lnddir=$HOME/.lnd/carol'
alias carol-lnd-cli='$LND_CLI --lnddir=$HOME/.lnd/carol --rpcserver=localhost:10011 --network=regtest'
alias dave-lnd='$LND_BIN --lnddir=$HOME/.lnd/dave'
alias dave-lnd-cli='$LND_CLI --lnddir=$HOME/.lnd/dave --rpcserver=localhost:10012 --network=regtest'
