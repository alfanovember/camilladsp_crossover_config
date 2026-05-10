#!/bin/bash
set -e


# Determine IP by looking at default route:
ADDR=$(ip -4 route get 1 |  cut -d ' ' -f7)
#ADDR=$(ip -4 addr show end0 | awk '/inet / {print $2}' | cut -d/ -f1)

if [ -z "$ADDR" ]; then
    echo "ERROR: Could not determine IP address for end0" >&2
    exit 1
fi

# Write to env file:
echo HOST_IP=$ADDR > /opt/crossover/local/environment

# Write into GUI config YML:
sed "s/BIND_ADDRESS_PLACEHOLDER/${ADDR}/" \
    /opt/crossover/camillagui_backend/_internal/config/camillagui.yml.template \
    > /opt/crossover/camillagui_backend/_internal/config/camillagui.yml

echo "camillagui config written with bind_address=${ADDR}"
root@office:/opt/crossover/local/bin# 
