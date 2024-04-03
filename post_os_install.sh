#!/bin/bash

## Update and install packages
sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y

## Install packages
echo "" > failed_packages.log
while read package; do
  echo "Attempting to install $package..."
  if ! sudo apt install "$package" -y; then
    echo "$package" >> failed_packages.log
  fi
done < test.list

if [ -s failed_packages.log ]; then
  echo "Some packages failed to install. Check failed_packages.log for details."
else
  echo "All packages installed successfully."
fi

## Decrypt secrets
./decrypt.sh

## Copy directories to home
mkdir -p ~/ressources
mkdir -p ~/scripts
mkdir -p ~/secrets
cp -r ./ressources/* ~/ressources/
cp -r ./scripts/* ~/scripts/
cp -r ./secrets/* ~/secrets/

## Download Github Repositories
./download_repositories.sh

## Add custom Bash (Downloaded Repository)
~/.bash_custom/append_to_bashrc.sh



