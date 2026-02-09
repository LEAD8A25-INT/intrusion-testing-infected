#!/bin/bash
# Docker Lab - Web Enumeration (Phase 3-5) - BULLETPROOF
# Non-interactive, timeout-protected

TARGET_IP=${1:-172.21.104.161}

echo "=================================="
echo "DOCKER LAB: PHASE 3-5 WEB ENUM"
echo "Target: http://$TARGET_IP"
echo "=================================="

# PHASE 3: Fingerprinting
echo ""
echo "=== PHASE 3: FINGERPRINTING ==="
timeout 10 whatweb "http://$TARGET_IP:3001" || echo "3001 timeout"
timeout 10 whatweb "http://$TARGET_IP:8080" || echo "8080 timeout"

# PHASE 4: Directory enum (smaller lists, no extensions)
echo ""
echo "=== PHASE 4: DIRECTORY SCAN ==="
timeout 30 dirb "http://$TARGET_IP:3001" /usr/share/dirb/wordlists/common.txt || echo "dirb 3001 done"
timeout 30 dirb "http://$TARGET_IP:8080" /usr/share/dirb/wordlists/common.txt || echo "dirb 8080 done"

# PHASE 5: Nikto (basic scan only)
echo ""
echo "=== PHASE 5: VULN SCAN ==="
timeout 20 nikto -h "http://$TARGET_IP:3001" -Tuning 1 -o nikto-3001.txt || echo "nikto 3001 complete"
timeout 20 nikto -h "http://$TARGET_IP:8080" -Tuning 1 -o nikto-8080.txt || echo "nikto 8080 complete"

echo ""
echo "=================================="
echo "COMPLETE - Check nikto-*.txt files"
echo "=================================="
