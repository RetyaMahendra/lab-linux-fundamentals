#!/usr/bin/env bash
# =============================================================================
# setup.sh — Linux System Administration Workshop Environment Setup
# =============================================================================
# Purpose: Provisions the Educates session container with all tools and
#          baseline configuration needed for the 7-module workshop.
#
# Run at:  Session start (copy to workshop/setup.d/ for automatic execution)
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Colour

log_info()    { echo -e "${BLUE}[SETUP]${NC}  $*"; }
log_ok()      { echo -e "${GREEN}[  OK ]${NC}  $*"; }
log_warn()    { echo -e "${YELLOW}[ WARN]${NC}  $*"; }
log_error()   { echo -e "${RED}[FAIL ]${NC}  $*"; }

echo ""
echo "=================================================================="
echo "  Linux System Administration Fundamentals — Workshop Setup"
echo "=================================================================="
echo ""

# ── 1. Update package index ──────────────────────────────────────────────────
log_info "Updating package index ..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq

# ── 2. Install required tools ────────────────────────────────────────────────
log_info "Installing workshop packages ..."
sudo apt-get install -y -qq \
    tree \
    net-tools \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    nginx \
    openssh-server \
    openssh-client \
    dnsutils \
    iproute2 \
    iputils-ping \
    lsof \
    tcpdump \
    traceroute \
    jq \
    unzip \
    2>/dev/null
log_ok "All packages installed"

# ── 3. Enable and start SSH ──────────────────────────────────────────────────
log_info "Configuring OpenSSH server ..."
sudo systemctl enable ssh 2>/dev/null || sudo systemctl enable sshd 2>/dev/null || log_warn "systemctl not available (container mode)"
sudo systemctl start  ssh 2>/dev/null || sudo systemctl start  sshd 2>/dev/null || {
    log_warn "Starting sshd manually ..."
    sudo /usr/sbin/sshd 2>/dev/null || log_warn "Could not start sshd — SSH labs will use terminal directly"
}
log_ok "SSH configured"

# ── 4. Enable and start nginx (but do NOT start it — students do this) ───────
log_info "Installing nginx (students will start it in Module 6) ..."
sudo systemctl disable nginx 2>/dev/null || true
log_ok "nginx installed and disabled at boot (ready for Module 6 labs)"

# ── 5. Create student SSH key pair ───────────────────────────────────────────
log_info "Setting up SSH keys for student ..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "student@workshop" -f ~/.ssh/id_ed25519 -N "" -q
    cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    log_ok "SSH key pair created"
else
    log_ok "SSH key pair already exists"
fi

# ── 6. Create lab directory skeleton ─────────────────────────────────────────
log_info "Creating lab directory structure ..."
mkdir -p ~/workshop/{lab2/{config,logs,scripts,backups},lab3,lab4,lab5,lab6,lab7}
log_ok "Lab directories created at ~/workshop/"

# ── 7. Create sample log files for Module 2 labs ─────────────────────────────
log_info "Creating sample log files ..."
cat > ~/workshop/lab2/logs/sample.log << 'EOF'
2024-10-10 10:00:01 INFO  Application started on port 8080
2024-10-10 10:00:02 INFO  Database connection established
2024-10-10 10:01:15 WARN  High memory usage detected: 85%
2024-10-10 10:01:30 ERROR Failed to process request: timeout
2024-10-10 10:02:00 INFO  Retry attempt 1 for job #4421
2024-10-10 10:02:05 INFO  Retry attempt 2 for job #4421
2024-10-10 10:02:10 ERROR Job #4421 failed after 3 retries
2024-10-10 10:03:00 INFO  Scheduled cleanup started
2024-10-10 10:03:05 INFO  Cleaned 128 temp files
2024-10-10 10:04:00 ERROR Disk usage at 92% on /var/data
2024-10-10 10:05:00 WARN  Response time exceeded SLA: 2450ms
2024-10-10 10:06:00 INFO  Health check: OK
EOF
log_ok "Sample log files created"

# ── 8. Create sample config files for Module 2 ───────────────────────────────
cat > ~/workshop/lab2/config/app.conf << 'EOF'
# Application Configuration
server_name=webserver-01
port=8080
debug=false
log_level=info
max_connections=100
timeout=30
database_host=localhost
database_port=5432
database_name=appdb
EOF
log_ok "Sample config files created"

# ── 9. Configure hostname ─────────────────────────────────────────────────────
log_info "Setting workshop hostname ..."
if sudo hostnamectl set-hostname ubuntu-workshop 2>/dev/null; then
    log_ok "Hostname set to ubuntu-workshop"
else
    log_warn "Could not set hostname (may not have permission in container)"
fi

# ── 10. Verify examiner test scripts are executable ──────────────────────────
log_info "Setting examiner test permissions ..."
EXAM_DIR="$(dirname "$0")/../examiner/tests"
if [ -d "$EXAM_DIR" ]; then
    chmod +x "$EXAM_DIR"/* 2>/dev/null || true
    log_ok "Examiner tests made executable"
else
    log_warn "Examiner tests directory not found at $EXAM_DIR"
fi

# ── 11. Print success summary ────────────────────────────────────────────────
echo ""
echo "=================================================================="
echo -e "  ${GREEN}Workshop environment ready!${NC}"
echo "=================================================================="
echo ""
echo "  Student home:  ~/workshop/"
echo "  nginx:         installed (start it in Module 6)"
echo "  SSH:           enabled (use for Module 7)"
echo ""
echo "  Quick checks:"
echo "    nginx version:  $(nginx -v 2>&1)"
echo "    ssh version:    $(ssh -V 2>&1)"
echo "    bash version:   $(bash --version | head -1)"
echo ""
