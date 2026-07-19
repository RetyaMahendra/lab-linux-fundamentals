#!/usr/bin/env bash
# =============================================================================
# check.sh — Workshop Environment Health Check
# =============================================================================
# Purpose: Quickly validates that all required tools and services are
#          available for each module. Prints PASS/FAIL for each check.
#
# Usage:   bash ~/workshop/scripts/check.sh
#          bash ~/workshop/scripts/check.sh --module 5
# =============================================================================

set -uo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

PASS=0
FAIL=0

pass() { echo -e "  ${GREEN}✅ PASS${NC}  $*"; ((PASS++)) || true; }
fail() { echo -e "  ${RED}❌ FAIL${NC}  $*"; ((FAIL++)) || true; }
warn() { echo -e "  ${YELLOW}⚠️  WARN${NC}  $*"; }
section() { echo ""; echo -e "${BOLD}${BLUE}── $* ──${NC}"; }

MODULE="${2:-all}"
if [ "${1:-}" = "--module" ] && [ -n "${2:-}" ]; then
    MODULE="$2"
fi

echo ""
echo "=================================================================="
echo "  Linux Workshop Environment Health Check"
echo "=================================================================="

# ── Module 1: System Info Tools ──────────────────────────────────────────────
check_module1() {
    section "Module 1: Linux Fundamentals"
    command -v hostnamectl &>/dev/null   && pass "hostnamectl available"    || fail "hostnamectl not found"
    command -v uname       &>/dev/null   && pass "uname available"          || fail "uname not found"
    [ -f /etc/os-release ]               && pass "/etc/os-release exists"   || fail "/etc/os-release missing"
    command -v sudo        &>/dev/null   && pass "sudo available"           || fail "sudo not found"
    command -v tree        &>/dev/null   && pass "tree available"           || fail "tree not installed — run: sudo apt install tree"
    id &>/dev/null                       && pass "id command works"         || fail "id command failed"
}

# ── Module 2: Command Line Tools ─────────────────────────────────────────────
check_module2() {
    section "Module 2: Command Line"
    command -v grep  &>/dev/null && pass "grep available"  || fail "grep not found"
    command -v find  &>/dev/null && pass "find available"  || fail "find not found"
    command -v sort  &>/dev/null && pass "sort available"  || fail "sort not found"
    command -v cut   &>/dev/null && pass "cut available"   || fail "cut not found"
    command -v head  &>/dev/null && pass "head available"  || fail "head not found"
    command -v tail  &>/dev/null && pass "tail available"  || fail "tail not found"
    command -v wc    &>/dev/null && pass "wc available"    || fail "wc not found"
    command -v tee   &>/dev/null && pass "tee available"   || fail "tee not found"
    command -v awk   &>/dev/null && pass "awk available"   || fail "awk not found"
    [ -d ~/workshop/lab2 ]       && pass "Lab 2 directory exists"  || warn "Lab 2 dir missing — run setup.sh"
}

# ── Module 3: Filesystem Tools ──────────────────────────────────────────────
check_module3() {
    section "Module 3: Filesystem"
    command -v df       &>/dev/null && pass "df available"       || fail "df not found"
    command -v du       &>/dev/null && pass "du available"       || fail "du not found"
    command -v lsblk    &>/dev/null && pass "lsblk available"    || fail "lsblk not found"
    command -v findmnt  &>/dev/null && pass "findmnt available"  || fail "findmnt not installed"
    command -v ln       &>/dev/null && pass "ln available"       || fail "ln not found"
    df -h &>/dev/null               && pass "df -h works"        || fail "df -h failed"
    [ -d ~/workshop/lab3 ] && pass "Lab 3 directory exists" || warn "Lab 3 dir missing — run setup.sh"
}

# ── Module 4: User Management ────────────────────────────────────────────────
check_module4() {
    section "Module 4: Users & Permissions"
    command -v useradd   &>/dev/null && pass "useradd available"   || fail "useradd not found"
    command -v groupadd  &>/dev/null && pass "groupadd available"  || fail "groupadd not found"
    command -v chmod     &>/dev/null && pass "chmod available"     || fail "chmod not found"
    command -v chown     &>/dev/null && pass "chown available"     || fail "chown not found"
    command -v passwd    &>/dev/null && pass "passwd available"    || fail "passwd not found"
    # Check sudo works
    sudo -n true 2>/dev/null         && pass "sudo works (passwordless)" || warn "sudo requires password (expected in production)"
    # Check lab state
    getent group developers &>/dev/null && pass "developers group exists (Module 4 started)" || warn "developers group not found (run Module 4 lab)"
}

# ── Module 5: Package Management ─────────────────────────────────────────────
check_module5() {
    section "Module 5: Package Management"
    command -v apt   &>/dev/null && pass "apt available"   || fail "apt not found"
    command -v dpkg  &>/dev/null && pass "dpkg available"  || fail "dpkg not found"
    [ -f /etc/apt/sources.list ] && pass "/etc/apt/sources.list exists" || fail "sources.list missing"
    dpkg -l nginx &>/dev/null 2>&1 | grep -q "^ii" && pass "nginx is installed" || warn "nginx not installed — run Module 5 lab"
    dpkg -l htop  &>/dev/null 2>&1 | grep -q "^ii" && pass "htop is installed"  || warn "htop not installed — complete Module 5 challenge"
}

# ── Module 6: Services & Logs ────────────────────────────────────────────────
check_module6() {
    section "Module 6: Processes & Services"
    command -v systemctl   &>/dev/null && pass "systemctl available"   || fail "systemctl not found — systemd required"
    command -v journalctl  &>/dev/null && pass "journalctl available"  || fail "journalctl not found"
    command -v ps          &>/dev/null && pass "ps available"          || fail "ps not found"
    command -v top         &>/dev/null && pass "top available"         || fail "top not found"
    command -v kill        &>/dev/null && pass "kill available"        || fail "kill not found"
    # Check if nginx service is functional
    systemctl is-active nginx &>/dev/null && pass "nginx is running" || warn "nginx not running (expected before Module 6 lab)"
    # Check nginx config is not broken
    sudo nginx -t &>/dev/null 2>&1 && pass "nginx config is valid" || fail "nginx config is BROKEN — check /etc/nginx/nginx.conf"
    [ -d /var/log/nginx ] && pass "/var/log/nginx exists" || warn "/var/log/nginx missing"
}

# ── Module 7: Networking ──────────────────────────────────────────────────────
check_module7() {
    section "Module 7: Networking"
    command -v ip       &>/dev/null && pass "ip command available"   || fail "ip not found — install iproute2"
    command -v ss       &>/dev/null && pass "ss command available"   || fail "ss not found — install iproute2"
    command -v ping     &>/dev/null && pass "ping available"         || fail "ping not found"
    command -v curl     &>/dev/null && pass "curl available"         || fail "curl not installed"
    command -v wget     &>/dev/null && pass "wget available"         || fail "wget not installed"
    command -v ssh      &>/dev/null && pass "ssh client available"   || fail "ssh not installed"
    command -v scp      &>/dev/null && pass "scp available"          || fail "scp not found"
    command -v dig      &>/dev/null && pass "dig available"          || fail "dig not installed — run: sudo apt install dnsutils"
    [ -f ~/.ssh/id_ed25519 ]        && pass "SSH key pair exists"    || warn "No SSH key — SSH key labs will fail"
    ss -tlnp 2>/dev/null | grep -q ":22 " && pass "Port 22 is listening" || warn "Port 22 not listening — start sshd: sudo systemctl start ssh"
    ping -c 1 -W 2 8.8.8.8 &>/dev/null  && pass "External network reachable" || warn "Cannot reach 8.8.8.8 — check network config"
}

# ── Run Checks ────────────────────────────────────────────────────────────────
case "$MODULE" in
    1)    check_module1 ;;
    2)    check_module2 ;;
    3)    check_module3 ;;
    4)    check_module4 ;;
    5)    check_module5 ;;
    6)    check_module6 ;;
    7)    check_module7 ;;
    all)
        check_module1
        check_module2
        check_module3
        check_module4
        check_module5
        check_module6
        check_module7
        ;;
    *)
        echo "Unknown module: $MODULE"
        exit 1
        ;;
esac

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
echo "=================================================================="
echo -e "  Results:  ${GREEN}${PASS} PASS${NC}  /  ${RED}${FAIL} FAIL${NC}"
echo "=================================================================="
echo ""

if [ "$FAIL" -gt 0 ]; then
    echo -e "  ${RED}Some checks failed.${NC} Run setup.sh to fix the environment."
    exit 1
else
    echo -e "  ${GREEN}All checks passed. Environment is ready.${NC}"
    exit 0
fi
