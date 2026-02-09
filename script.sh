#!/bin/bash
TARGET_IP=${1:-127.0.0.1}
TMPDIR=$(mktemp -d /tmp/recon.XXXXXX)
trap 'rm -rf "$TMPDIR"; exit' EXIT INT TERM
WORDLIST="$TMPDIR/raft-small.txt"

# Wordlist
wget -q -O "$WORDLIST" https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/raft-small-directories-lowercase.txt

cd "$TMPDIR"
echo "Scanning $TARGET_IP (zero-trace)..."

# Scans (sudoers-enabled nmap)
sudo nmap -sS -sV -T4 -p- --max-retries 1 --host-timeout 30s "$TARGET_IP" -oN recon.nmap
whatweb "http://$TARGET_IP" > whatweb.txt
gobuster dir -u "http://$TARGET_IP" -w "$WORDLIST" -x js,php,html -q -o gobuster.txt
nikto -h "http://$TARGET_IP" -q -o nikto.txt

# Copy outputs
cp recon.nmap gobuster.txt nikto.txt whatweb.txt ~/

# OPSEC wipe
shred -u -z -n 3 ~/.bash_history ~/.viminfo ~/.wget-hsts 2>/dev/null || true
history -c && history -w
unset HISTFILE HISTSIZE HISTFILESIZE

echo "Complete. Check ~/recon.nmap etc. No traces."
