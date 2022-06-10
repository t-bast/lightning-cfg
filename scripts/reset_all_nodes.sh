#!/bin/bash

(cd .eclair && ./reset_nodes.sh)
(cd .lightning && ./reset_nodes.sh)
(cd .lnd && ./reset_nodes.sh)
(cd .ldk && ./reset_nodes.sh)
