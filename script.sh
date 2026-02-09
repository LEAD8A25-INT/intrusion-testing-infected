#!/bin/bash

TARGET_NET=${1:-172.21.104.0/24}

echo "PHASE 1: NETWORK DISCOVERY (ARP)"
echo "Scanning $TARGET_NET..."
HOSTS=$(sudo nmap -sn -PR "$TARGET_NET" --open -oG - | grep "Up$" | awk '{print $2}')

if [ -z "$HOSTS" ]; then
  echo "ERROR: No hosts found! Check network range."
  exit 1
fi

echo "LIVE HOSTS FOUND:"
echo "$HOSTS"
echo ""

TARGET_IP=$(echo "$HOSTS" | head -n1)
echo "PHASE 2: PORT SCANNING TARGET: $TARGET_IP"
nmap -Pn -sT "$TARGET_IP" --top-ports 50

echo "DISCOVERY COMPLETE: $TARGET_IP"
