#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <IP> [ '-p-' for all ports or a specific port range like '30' or '30-40']"
    exit 1
fi

IP=$1
PORT_SPEC=""

# Check if a port specification is provided
if [ ! -z "$2" ]; then
    # If the user specifies '-p-', it's used directly. Otherwise, add '-p' prefix for port ranges.
    if [ "$2" == "-p-" ]; then
        PORT_SPEC="-p-"
    else
        PORT_SPEC="-p $2"
    fi
fi

# Construct and execute the nmap command with conditional port specification
sudo nmap -sS -sV -sC -O -T5 $PORT_SPEC $IP
