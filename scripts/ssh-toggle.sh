#!/bin/bash

# Check if SSH is currently active
if systemctl is-active --quiet ssh; then
    echo "[*] SSH is active. Shutting down service listeners..."
    sudo systemctl stop ssh

    echo "[!] Forcefully killing ALL network connections on port 22..."

    # This command drops the physical TCP socket connection on port 22 immediately,
    # forcing any remote client terminal to instantly disconnect, regardless of process scopes.
    sudo ss -K sport = :22 dport = :*

    echo "[+] All connections severed successfully."
    echo ""
    echo "[*] Window will close automatically in 5 seconds..."
    sleep 5
    exit 0
else
    echo "[*] SSH is stopped. Starting it up..."
    sudo systemctl start ssh
    echo "[+] SSH Server STARTED."

    echo ""
    echo "[*] Window will close automatically in 5 seconds..."
    sleep 5
fi
