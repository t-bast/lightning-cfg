# Lightning Configurations

Configuration files to run multi-node cross-implementation Lightning nodes.
This is handy when trying to reproduce complex integration issues between
specific versions of eclair, lnd or c-lightning with multi-hop payments.

## How to use

Note: scripts need to be run from the top-level directory.

### Run Bitcoin in regtest mode

Run the bitcoin daemon with the following script:

```sh
scripts/start_bitcoin.sh
```

Note: you can tweak the default Bitcoin configuration in `.bitcoin/bitcoin.conf`.

### Run Lightning Nodes

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

For example:

```sh
alice-eclair
dave-clightning
```

Nodes will store their data in sub-directories of this repository so it won't
conflict with other nodes you may be running on your machine.

### Test scenario

The `scripts` folder contains some test scenario.
Don't hesitate to tweak them to test other scenario.
If your test script may be useful to others, please open a PR!

For example:

```sh
scripts/multipart_direct_peer.sh
```
