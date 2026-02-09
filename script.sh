#!/bin/bash
TARGET_IP=${1:-127.0.0.1}
TMPDIR=$(mktemp -d /tmp/recon.XXXXXX)
trap 'rm -rf "$TMPDIR"; exit' EXIT INT TERM
WORDLIST="$TMPDIR/raft-small.txt"

# Wordlist to temp
wget -q -O "$WORDLIST" https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/raft-small-directories-lowercase.txt

cd "$TMPDIR"

echo "Scanning $TARGET_IP (zero-trace)..."
sudo nmap -sS -sV -T4 -p- --max-retries 1 --max-scan-delay 100ms --host-timeout 30s "$TARGET_IP" -oN recon.nmap
whatweb "http://$TARGET_IP" > whatweb.txt
gobuster dir -u "http://$TARGET_IP" -w "$WORDLIST" -x js,php,html -q -o gobuster.txt
nikto -h "http://$TARGET_IP" -q -o nikto.txt  # -q silent

cp recon.nmap gobuster.txt nikto.txt whatweb.txt ~/
shred -u -z -n 3 recon.nmap gobuster.txt nikto.txt whatweb.txt $WORDLIST  # Wipe copies too? Or keep outputs

echo "Done. ~/recon.nmap etc. Temp shredded."
