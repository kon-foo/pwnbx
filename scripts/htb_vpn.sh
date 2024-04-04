#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <vpn_name> <protocol (udp|tcp)>"
    exit 1
fi

VPN_NAME=$1
PROTOCOL=$2

CONFIG_FILE=~/secrets/HTB_openvpn/${VPN_NAME}_konfoo_${PROTOCOL}.ovpn

# If the configuration file exists, start openvpn connection
if [ -f "$CONFIG_FILE" ]; then
    echo "Starting OpenVPN with configuration file: $CONFIG_FILE"
    sudo openvpn --config "$CONFIG_FILE"
else
    echo "Error: Configuration file not found at $CONFIG_FILE"
    exit 1
fi
