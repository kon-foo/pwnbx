#!/bin/bash

gpg --decrypt "secrets.tar.gpg" > "secrets.tar"
tar -xvf "secrets.tar"
rm "secrets.tar"

echo "Folder decrypted and extracted."
