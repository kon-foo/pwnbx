#!/bin/bash
PASSWORD=HTB_@cademy_stdnt!
USER=htb-student
IP=$1
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USER"@"$IP"
