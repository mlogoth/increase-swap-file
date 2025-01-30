#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Default swap size (can be changed via command-line argument)
SWAP_SIZE="${1:-16G}"  # Default: 16GB if no argument is given
SWAP_FILE="/swapfile"

echo "--------------------------------------------"
echo "💾 Ubuntu Swap Increase Script"
echo "--------------------------------------------"
echo "🔹 Requested swap size: $SWAP_SIZE"
echo "🔹 Swap file location: $SWAP_FILE"
echo ""

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root! Use: sudo ./increase_swap.sh"
    exit 1
fi

# Check if swap is already enabled
if swapon --show | grep -q "$SWAP_FILE"; then
    echo "🔄 Disabling current swap..."
    swapoff -a
fi

# Remove existing swap file if it exists
if [[ -f "$SWAP_FILE" ]]; then
    echo "🗑️ Removing existing swap file..."
    rm -f "$SWAP_FILE"
fi

# Create new swap file
echo "📂 Creating new swap file of size $SWAP_SIZE..."
if ! fallocate -l "$SWAP_SIZE" "$SWAP_FILE"; then
    echo "⚠️ 'fallocate' failed, using 'dd' instead..."
    dd if=/dev/zero of="$SWAP_FILE" bs=1M count=$(( $(echo $SWAP_SIZE | sed 's/G//') * 1024 )) status=progress
fi

# Set correct permissions
echo "🔑 Setting correct file permissions..."
chmod 600 "$SWAP_FILE"

# Format the swap file
echo "🛠️ Making the file swap-enabled..."
mkswap "$SWAP_FILE"

# Enable swap
echo "🚀 Enabling swap..."
swapon "$SWAP_FILE"

# Make swap persistent after reboot
if ! grep -q "$SWAP_FILE" /etc/fstab; then
    echo "💾 Adding swap file to /etc/fstab..."
    echo "$SWAP_FILE none swap sw 0 0" | tee -a /etc/fstab
fi

# Optimize swappiness
echo "⚙️ Setting swappiness to 10 for better performance..."
echo "vm.swappiness=10" > /etc/sysctl.d/99-swap.conf
sysctl --system

echo ""
echo "✅ Swap setup completed successfully!"
free -h
