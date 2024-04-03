#!/bin/bash
IP=$(ip address | grep tun0 | grep inet | cut -d " " -f6)
echo $IP
echo "$IP" | xclip -selection clipboard
echo "Copied to Clipboard"