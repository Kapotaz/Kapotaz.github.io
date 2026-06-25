#!/bin/bash

# ==============================================================================
# Script Name: apt_update.sh
# Description: Automated, non-interactive system update and cleanup utility.
# Environment: Debian/Ubuntu (CasaOS)
# ==============================================================================

# --- Configuration ---
LOG_FILE="/var/log/sys_update.log"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# --- Logging Function ---
# This ensures all output goes to the terminal AND a permanent log file
log() {
    local prefix="$1"
    local message="$2"
    
    # Print to terminal
    echo -e "${prefix} ${message}"
    
    # Append to log file with a timestamp
    echo "[${TIMESTAMP}] ${prefix} ${message}" >> "$LOG_FILE"
}

# --- Error Handling ---
# Catch unexpected command failures and log them before exiting
handle_error() {
    log "[ ERROR ]" "A command failed during execution. Check $LOG_FILE for details."
    exit 1
}
trap 'handle_error' ERR

# Exit immediately if any command fails
set -e

# --- Pre-Flight Checks ---
if [ "$EUID" -ne 0 ]; then
    echo "[ ERROR ] Please run this script with sudo (e.g., sudo ./apt_update.sh)."
    exit 1
fi

# ==============================================================================
# Execution
# ==============================================================================

log "[ * ]" "INITIATING SYSTEM UPDATE..."

# 1. Update package lists
# Using apt-get -qq (quiet) is preferred for scripts over standard 'apt'
log "[ * ]" "Fetching latest package lists..."
apt-get update -qq

# 2. Upgrade packages 
log "[ * ]" "Installing package upgrades (non-interactive)..."
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq

# 3. Clean up unused dependencies
log "[ * ]" "Removing orphaned dependencies and clearing cache..."
apt-get autoremove -y -qq
apt-get clean

log "[ + ]" "Update process completed successfully."

# 4. Safely check if a reboot is required
if [ -f /var/run/reboot-required ]; then
    log "[ ! ]" "SYSTEM REBOOT REQUIRED to apply kernel or core updates."
    log "[ ! ]" "Run 'sudo reboot' at your earliest convenience."
else
    log "[ + ]" "No reboot required. System is fully up to date."
fi

exit 0