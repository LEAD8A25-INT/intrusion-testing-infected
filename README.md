# Docker Pentest Lab - **Information Gathering Only**

**Objective**: Reconnaissance only. Discover Docker apps via network scanning → enumerate technologies → identify misconfigurations.

**Scope**: Information gathering **NO exploitation**.

**Your IP**: `172.21.104.161` (Target/AttackerWSL share IP)

---

## Phase 1: Network Discovery

```bash
sudo nmap -sn -PR 172.21.104.0/24
# Expected: 172.21.104.161 up (1 host)
```

## Phase 2: Port Scanning

```bash
nmap -Pn -sT 172.21.104.161 --top-ports 50
# Expected: 3001(React), 8080(API) open
```

## Phase 3: Web Fingerprinting

```bash
whatweb http://172.21.104.161:3001
whatweb http://172.21.104.161:8080
# Expected: React + nginx/1.29.4 (3001), API backend (8080)
```

## Phase 4: Directory Enumeration

```bash
# Frontend (React)
dirb http://172.21.104.161:3001 /usr/share/dirb/wordlists/common.txt -X .html,.js,.txt

# Backend (API)  
dirb http://172.21.104.161:8080 /usr/share/dirb/wordlists/common.txt -X .json,.php
# Expected: robots.txt (3001), possible /api/, /health (8080)
```

## Phase 5: Vulnerability Scanning (Passive)

```bash
# React frontend misconfigs
nikto -h http://172.21.104.161:3001 -Tuning 1234567890

# API dangerous methods  
nikto -h http://172.21.104.161:8080 -Tuning x
# Expected: PUT/DELETE methods exposed (8080)
```

## Expected Information Gathered
```
Phase	Port	Intelligence	Risk
2	3001	React SPA + nginx/1.29.4	Client-side recon target
2	8080	HTTP Proxy/API	Backend enumeration
5	8080	PUT/DELETE enabled	High risk misconfig
4	3001	/robots.txt	Info disclosure
```

# Lab Submission (Information Only)

Required Screenshots:
- nmap: Ports 3001/8080 open
- whatweb: React + nginx confirmation
- nikto: PUT/DELETE methods warning (8080)
- dirb: robots.txt or directories found

## Answer these

1. What technology stack runs on port 3001?

2. What dangerous HTTP methods exist on 8080?

3. Why is nginx/1.29.4 significant?

Key Learning: Information gathering reveals Docker misconfigurations without exploitation!
