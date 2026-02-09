#!/bin/bash
TARGET_IP=${1:-127.0.0.1}
TMPDIR=$(mktemp -d /tmp/recon.XXXXXX)
trap 'rm -rf "$TMPDIR"; exit' EXIT INT TERM
WORDLIST="$TMPDIR/raft-small.txt"

wget -q -O "$WORDLIST" https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/raft-small-directories-lowercase.txt

cd "$TMPDIR"
echo "Recon $TARGET_IP (handles down hosts)..."

# Always run nmap host discovery + top ports
sudo nmap -sn --host-timeout 5s "$TARGET_IP" -oN hostcheck.nmap
sudo nmap -sS -sV -T4 --top-ports 100 --max-retries 1 --host-timeout 10s "$TARGET_IP" -oN recon.nmap

HOST_UP=$?

# Web tools only if responsive
if [[ $HOST_UP -eq 0 ]]; then
  whatweb "http://$TARGET_IP" -q > whatweb.txt 2>/dev/null || true
  gobuster dir -u "http://$TARGET_IP" -w "$WORDLIST" -x js,php,html -t 10 -fw -q -o gobuster.txt 2>/dev/null || true
  nikto -h "http://$TARGET_IP" -no404 -Tuning x -o nikto.txt >/dev/null 2>&1 || true
  echo "Web recon complete."
else
  echo "Target down - network recon only."
fi

# Copy all available
cp recon.nmap ~/"recon-${TARGET_IP}.nmap" 2>/dev/null || true
cp hostcheck.nmap ~/"hostcheck-${TARGET_IP}.nmap" 2>/dev/null || true
[[ -f gobuster.txt ]] && cp gobuster.txt ~/
[[ -f nikto.txt ]] && cp nikto.txt ~/
[[ -f whatweb.txt ]] && cp whatweb.txt ~/

# OPSEC
shred -u ~/.bash_history ~/.viminfo ~/.wget-hsts 2>/dev/null || true
history -c && history -w
unset HISTFILE HISTSIZE HISTFILESIZE

echo "Recon done. Check ~/recon* files (even if target down)."
