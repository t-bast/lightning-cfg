# Lightning Configurations

Configuration files to run multi-node cross-implementation Lightning nodes.
This is handy when trying to reproduce complex integration issues between
specific versions of eclair, lnd or c-lightning with multi-hop payments.

## How to use

### Run Bitcoin in regtest mode

Copy the `.bitcoin` folder to your home directory (be careful not to overwrite
your previous bitcoin configuration if you have one).

Run bitcoin daemon:

```sh
bitcoind -daemon
```

### Run Lightning Nodes

Copy the `.eclair`, `.lnd` and `.lightning` folders to your home directory (be
careful not to overwrite your previous lightning configurations if you have
some).

Edit the `.bash_aliases` file to fill the required environment variables:

* c-lightning:
  * CLIGHTNING_BIN
  * CLIGHTNING_CLI
* eclair:
  * ECLAIR_JAR
  * ECLAIR_CLI
* lnd:
  * LND_BIN
  * LND_CLI

Source the `.bash_aliases` file:

```bash
source .bash_aliases
```

Use the provided aliases to run your nodes.
