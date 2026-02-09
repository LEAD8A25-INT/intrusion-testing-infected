#!/bin/bash
# Docker Lab - Web Enumeration (Phase 3-5) - WORKS WITH DIRB v2.22

TARGET_IP=${1:-172.21.104.161}

echo "=================================="
echo "DOCKER LAB: PHASE 3-5 WEB ENUM"
echo "Target: http://$TARGET_IP"
echo "=================================="

# PHASE 3: Fingerprinting (fast)
echo ""
echo "=== PHASE 3: FINGERPRINTING ==="
whatweb "http://$TARGET_IP:3001"
whatweb "http://$TARGET_IP:8080"

# PHASE 4: Directory (NO flags, common.txt only)
echo ""
echo "=== PHASE 4: DIRECTORY SCAN 3001 ==="
dirb "http://$TARGET_IP:3001" /usr/share/dirb/wordlists/common.txt

echo ""
echo "=== PHASE 4: DIRECTORY SCAN 8080 ==="
dirb "http://$TARGET_IP:8080" /usr/share/dirb/wordlists/common.txt

# PHASE 5: Nikto (NON-INTERACTIVE)
echo ""
echo "=== PHASE 5: VULN SCAN 3001 ==="
nikto -h "http://$TARGET_IP:3001" -Tuning 1 > nikto-3001.txt 2>&1

echo ""
echo "=== PHASE 5: VULN SCAN 8080 ==="
nikto -h "http://$TARGET_IP:8080" -Tuning 1 > nikto-8080.txt 2>&1

echo ""
echo "=================================="
echo "COMPLETE! Files: nikto-3001.txt nikto-8080.txt"
cat nikto-8080.txt | grep -i "put\|delete\|allow"
echo "=================================="
