#!/bin/bash -i  # Force interactive
exec 2>/dev/null  # Silence stderr
set +e  # Continue on error
ulimit -T unlimited  # No timeouts

TARGET_IP=${1:-127.0.0.1}
TMPDIR=$(mktemp -d /tmp/recon.XXXXXX)
trap 'rm -rf "$TMPDIR"' EXIT INT TERM
WORDLIST="$TMPDIR/raft-small.txt"

wget -q -O "$WORDLIST" https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/raft-small-directories-lowercase.txt

cd "$TMPDIR"
echo "Recon $TARGET_IP..."

sudo nmap -sT -T4 --top-ports 20 -Pn --max-retries 0 --host-timeout 5s "$TARGET_IP" -oN recon.nmap 2>/dev/null || true

# Web only if 80 open
nmap -p 80 "$TARGET_IP" -oG - | grep -q "80/open" && {
  whatweb "http://$TARGET_IP" > whatweb.txt 2>/dev/null || true
  gobuster dir -u "http://$TARGET_IP" -w "$WORDLIST" -x js,php -t 10 -fw -o gobuster.txt 2>/dev/null || true
  nikto -h "http://$TARGET_IP" -no404 -o nikto.txt >/dev/null 2>&1 || true
}

cp recon.nmap ~/"recon-${TARGET_IP}.nmap" 2>/dev/null || true

# Shred empty/failed files before copy
[[ ! -s whatweb.txt ]] && rm whatweb.txt || cp whatweb.txt ~/
[[ ! -s gobuster.txt ]] && rm gobuster.txt || cp gobuster.txt ~/
[[ ! -s nikto.txt ]] && rm nikto.txt || cp nikto.txt ~/

# OPSEC
> ~/.bash_history  # Truncate
rm -f ~/.viminfo ~/.wget-hsts
history -c
unset HISTFILE

echo "Recon complete: ~/recon.nmap"
