#!/bin/bash

## Update and install packages
sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y

## Install packages
sudo apt install $(cat package.list | tr "\n" " ") -y

## Decrypt secrets
./decrypt.sh

## Copy directories to home
cp -r ./ressources/* ~/
cp -r ./scripts/* ~/scripts/
cp -r ./secrets/* ~/secrets/

## Download Github Repositories
./download_repositories.sh

## Add custom Bash (Downloaded Repository)
~/.bash_custom/append_to_bashrc.sh



