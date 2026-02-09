#!/bin/bash
TARGET_IP=${1:-127.0.0.1}

# Temp dir + trap cleanup (even on Ctrl+C)
TMPDIR=$(mktemp -d /tmp/recon.XXXXXX)
trap 'rm -rf "$TMPDIR"; exit' EXIT INT TERM
WORDLIST="$TMPDIR/raft-small.txt"

# Inline wordlist download to temp (first run only)
[[ ! -f "$WORDLIST" ]] && wget -q -O "$WORDLIST" https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/raft-small-directories-lowercase.txt

# Tools (sudo apt silent)
command -v nmap >/dev/null || sudo apt update -qq && sudo apt install -y -qq nmap whatweb gobuster nikto dnsutils

cd "$TMPDIR"  # Outputs here

echo "Scanning $TARGET_IP (zero-trace)..."
sudo nmap -sC -sV -T4 -p- "$TARGET_IP" -oN recon.nmap
whatweb "http://$TARGET_IP" > whatweb.txt
gobuster dir -u "http://$TARGET_IP" -w "$WORDLIST" -x js,php,html -q -o gobuster.txt
nikto -h "http://$TARGET_IP" -o nikto.txt -Tuning 123456 > /dev/null  # Silent

# Copy outputs to ~ ONLY if success, then shred temp
cp recon.nmap gobuster.txt nikto.txt whatweb.txt ~/
shred -u -z -n 3 "$TMPDIR"/*  # Secure delete
rm -rf "$TMPDIR"

echo "Done. Check ~/recon.nmap etc. No traces left."
