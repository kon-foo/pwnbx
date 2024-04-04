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
done < package.list

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

## Add custom .basrc (Downloaded Repository)
~/.bash_custom/append_to_bashrc.sh

## Add HTB specific bash aliases

touch ~/.bash_aliases
if ! grep -q "alias htbvpn='~/scripts/htb_vpn.sh'" ~/.bash_aliases; then
  echo "alias htbvpn='~/scripts/htb_vpn.sh'" >> ~/.bash_aliases
fi
if ! grep -q "alias htbssh='~/scripts/htb_academy_ssh.sh'" ~/.bash_aliases; then
  echo "alias htbssh='~/scripts/htb_academy_ssh.sh'" >> ~/.bash_aliases
fi
if ! grep -q "alias tunip='~/scripts/tunnel_ip.sh'" ~/.bash_aliases; then
  echo "alias tunip='~/scripts/tunnel_ip.sh'" >> ~/.bash_aliases
fi

source ~/.bash_aliases



## Apply MATE Terminal config
dconf load /org/mate/terminal/ < mate-terminal-settings.dconf
echo "MATE Terminal configuration applied successfully."


## Add KeepassXC to the MATE Autostart
cp /usr/share/applications/parrot-keepassxc.desktop ~/.config/autostart/
