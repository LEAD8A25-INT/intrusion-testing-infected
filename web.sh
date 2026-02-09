#!/bin/bash
# Docker Lab - Web Enumeration (Phase 3-5)
# whatweb + dirb + nikto on discovered ports

TARGET_IP=${1:-172.21.104.161}
PORTS="3001 8080"

echo "DOCKER LAB: PHASE 3-5 WEB ENUM"
echo "Target: http://$TARGET_IP"

for PORT in $PORTS; do
  echo ""
  echo "=== PHASE 3: FINGERPRINTING :$PORT ==="
  whatweb "http://$TARGET_IP:$PORT"
  
  echo ""
  echo "=== PHASE 4: DIRECTORY SCAN :$PORT ==="
  dirb "http://$TARGET_IP:$PORT" /usr/share/dirb/wordlists/common.txt \
    -X ".html,.js,.txt,.json,.php" -q
  
  echo ""
  echo "=== PHASE 5: VULN SCAN :$PORT ==="
  nikto -h "http://$TARGET_IP:$PORT" -Tuning 9 -o "nikto-$PORT.txt"
done

echo ""
echo "WEB ENUM COMPLETE"
echo "Check nikto-3001.txt, nikto-8080.txt"
echo "Expected: React(3001) + PUT/DELETE(8080)"
