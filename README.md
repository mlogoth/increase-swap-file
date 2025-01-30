# Ubuntu Swap Increase Script

## Overview
This script increases or creates a swap file on an Ubuntu system. It ensures the swap is set up properly and persists across reboots.

## Features
- Dynamically increases swap space
- Safe execution with error handling
- Uses either `fallocate` or `dd` for maximum compatibility
- Automatically makes swap persistent across reboots
- Optimizes swap settings for better performance

## Usage
### Make the script executable:
```bash
chmod +x increase_swap.sh
```
### Run the script with sudo:
```bash
sudo ./increase_swap.sh
```
By default, the **script sets swap to 16GB**.

### (Optional) Specify a custom swap size:
```bash
sudo ./increase_swap.sh 8G
```
This **sets swap size to 8GB instead of the default 16GB**.
