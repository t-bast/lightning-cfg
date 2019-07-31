#!/bin/bash

echo Resetting eclair nodes...

# Remove databases
rm -r **/regtest

# Remove logs
rm **/*.log

# Remove seeds
rm **/*.dat
