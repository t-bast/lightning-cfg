#!/bin/bash

echo Resetting lnd nodes...

# Remove databases
rm -r **/data

# Remove logs
rm -r **/logs

# Remove seeds
rm **/*.cert && rm **/*.key
