#!/bin/bash
echo "hacker_man ALL=(ALL) NOPASSWD: /usr/bin/nmap" | tee /etc/sudoers.d/hacker_man-nmap
chmod 0440 /etc/sudoers.d/hacker_man-nmap
apt install -y nmap whatweb gobuster nikto dnsutils wget
echo 'export HISTFILE=/dev/null' >> /home/hacker_man/.bashrc
chown -R hacker_man:hacker_man /home/hacker_man
