#!/bin/bash

echo Resetting c-lightning nodes...

# Remove databases
rm -r **/*.sqlite3

# Remove pipes
rm **/gossip_store
rm **/lightning-rpc
rm **/*.pid

# Remove seeds
rm **/hsm_secret
