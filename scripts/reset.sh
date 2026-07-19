#!/usr/bin/env bash
# =============================================================================
# reset.sh — Linux System Administration Workshop Reset Script
# =============================================================================
# Purpose: Resets the workshop environment to its baseline state so a new
#          student or a retrying student starts fresh.
#
# Usage:   bash ~/workshop/scripts/reset.sh [--module N]
#          --module N  Reset only the specified module (1–7)
#          (no flag)   Reset all modules
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[RESET]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[  OK ]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[ WARN]${NC}  $*"; }
log_done()  { echo -e "${GREEN}[DONE ]${NC}  $*"; }

MODULE="${2:-all}"

usage() {
    echo "Usage: $0 [--module N]"
    echo "  --module 1   Reset Module 1 (Linux Fundamentals)"
    echo "  --module 2   Reset Module 2 (Command Line)"
    echo "  --module 3   Reset Module 3 (Filesystem)"
    echo "  --module 4   Reset Module 4 (Users & Permissions)"
    echo "  --module 5   Reset Module 5 (Package Management)"
    echo "  --module 6   Reset Module 6 (Processes & Services)"
    echo "  --module 7   Reset Module 7 (Networking)"
    echo "  (no args)    Full reset — all modules"
    exit 0
}

if [ "${1:-}" = "--help" ]; then usage; fi
if [ "${1:-}" = "--module" ] && [ -n "${2:-}" ]; then
    MODULE="$2"
fi

echo ""
echo "=================================================================="
echo "  Workshop Reset — Module: ${MODULE}"
echo "=================================================================="
echo ""

# ── Module 2 Reset ──────────────────────────────────────────────────────────
reset_module2() {
    log_info "Resetting Module 2 (Command Line) labs ..."
    rm -rf ~/workshop/lab2/
    mkdir -p ~/workshop/lab2/{config,logs,scripts,backups}
    cat > ~/workshop/lab2/logs/sample.log << 'EOF'
2024-10-10 10:00:01 INFO  Application started on port 8080
2024-10-10 10:01:15 WARN  High memory usage detected: 85%
2024-10-10 10:01:30 ERROR Failed to process request: timeout
2024-10-10 10:04:00 ERROR Disk usage at 92% on /var/data
2024-10-10 10:05:00 WARN  Response time exceeded SLA: 2450ms
EOF
    log_ok "Module 2 reset"
}

# ── Module 3 Reset ──────────────────────────────────────────────────────────
reset_module3() {
    log_info "Resetting Module 3 (Filesystem) labs ..."
    rm -rf ~/workshop/lab3/
    mkdir -p ~/workshop/lab3
    log_ok "Module 3 reset"
}

# ── Module 4 Reset ──────────────────────────────────────────────────────────
reset_module4() {
    log_info "Resetting Module 4 (Users & Permissions) labs ..."
    # Remove lab users
    for user in devuser1 devuser2; do
        if id "$user" &>/dev/null; then
            sudo userdel -rf "$user" 2>/dev/null && log_ok "Removed user: $user" || log_warn "Could not remove $user"
        fi
    done
    # Remove lab group
    if getent group developers &>/dev/null; then
        sudo groupdel developers 2>/dev/null && log_ok "Removed group: developers" || log_warn "Could not remove developers group"
    fi
    # Remove shared directories
    sudo rm -rf /opt/devshare /opt/projects 2>/dev/null || true
    # Clean lab4 directory
    rm -rf ~/workshop/lab4/
    mkdir -p ~/workshop/lab4
    log_ok "Module 4 reset"
}

# ── Module 5 Reset ──────────────────────────────────────────────────────────
reset_module5() {
    log_info "Resetting Module 5 (Package Management) labs ..."
    # NOTE: We do NOT purge nginx here because Module 6 depends on it.
    # If you want a clean package state, uncomment below:
    # sudo apt purge nginx -y 2>/dev/null || true
    # sudo apt autoremove -y 2>/dev/null || true
    rm -rf ~/workshop/lab5/
    mkdir -p ~/workshop/lab5
    log_ok "Module 5 reset (nginx kept installed for Module 6)"
}

# ── Module 6 Reset ──────────────────────────────────────────────────────────
reset_module6() {
    log_info "Resetting Module 6 (Processes & Services) labs ..."
    # Stop nginx and disable it (students will enable it in the lab)
    sudo systemctl stop nginx 2>/dev/null || true
    sudo systemctl disable nginx 2>/dev/null || true
    # Restore nginx config if it was broken during the challenge
    if grep -q "INVALID\|broken_value" /etc/nginx/nginx.conf 2>/dev/null; then
        log_warn "Detected broken nginx config — restoring ..."
        sudo sed -i '/INVALID CONFIGURATION LINE\|broken_value/d' /etc/nginx/nginx.conf
        log_ok "nginx config restored"
    fi
    rm -rf ~/workshop/lab6/
    mkdir -p ~/workshop/lab6
    log_ok "Module 6 reset"
}

# ── Module 7 Reset ──────────────────────────────────────────────────────────
reset_module7() {
    log_info "Resetting Module 7 (Networking) labs ..."
    rm -rf ~/workshop/lab7/
    mkdir -p ~/workshop/lab7
    rm -f /tmp/backup_transferred.txt /tmp/hosts_backup_*.txt 2>/dev/null || true
    log_ok "Module 7 reset"
}

# ── Full Reset ───────────────────────────────────────────────────────────────
reset_all() {
    log_warn "Performing FULL workshop reset ..."
    reset_module2
    reset_module3
    reset_module4
    reset_module5
    reset_module6
    reset_module7
    log_done "All modules reset to baseline"
}

# ── Execute ───────────────────────────────────────────────────────────────────
case "$MODULE" in
    1)    log_info "Module 1 has no persistent state to reset." ;;
    2)    reset_module2 ;;
    3)    reset_module3 ;;
    4)    reset_module4 ;;
    5)    reset_module5 ;;
    6)    reset_module6 ;;
    7)    reset_module7 ;;
    all)  reset_all ;;
    *)    log_warn "Unknown module: $MODULE" && usage ;;
esac

echo ""
log_done "Reset complete. Run setup.sh to reinitialise if needed."
echo ""
