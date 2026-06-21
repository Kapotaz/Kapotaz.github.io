#!/bin/bash

# Exit immediately if any command fails
set -e

# Check if the script is run as root (sudo)
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Please run this script with sudo (e.g., sudo ./update_server.sh)."
  exit 1
fi

echo "🚀 Starting safe server update..."

# 1. Update package lists
echo "🔄 Fetching the latest package lists..."
apt update

# 2. Upgrade packages 
# (DEBIAN_FRONTEND=noninteractive prevents the script from getting stuck on config prompts)
echo "📦 Installing updates..."
DEBIAN_FRONTEND=noninteractive apt upgrade -y

# 3. Clean up unused dependencies
echo "🧹 Cleaning up old packages..."
apt autoremove -y
apt clean

echo "✨ Update process finished successfully!"

# 4. Safely check if a reboot is required
if [ -f /var/run/reboot-required ]; then
  echo "⚠️  NOTE: A system reboot is required to apply kernel or core updates."
  echo "    Please run 'sudo reboot' at your earliest convenience."
else
  echo "✅ No reboot required. Your CasaOS server is up to date!"
fi
