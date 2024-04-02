#!/bin/bash

gpg --decrypt "secrets.tar.gpg" > "secrets.tar"
tar -xvf "secrets.tar" -C ./secrets
rm "secrets.tar"

echo "Folder decrypted and extracted."
