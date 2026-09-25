#!/bin/bash

# Check if lspci is installed
if ! command -v lspci &> /dev/null
then
    echo "lspci command not found. Please install pciutils package."
    exit 1
fi

# Detect NVIDIA cards using lspci
nvidia_cards=$(lspci | grep -i nvidia)

if [ -z "$nvidia_cards" ]; then
    echo "No NVIDIA cards detected."
    exit 0
fi

echo "NVIDIA cards detected:"
echo "$nvidia_cards"

# Check if nvidia-smi is installed
if ! command -v nvidia-smi &> /dev/null
then
    echo "NVIDIA driver not detected yet — install drivers, then run nvidia-smi to confirm."
    exit 0
fi

# Use nvidia-smi to get detailed information about NVIDIA cards
echo "Detailed NVIDIA card information:"
nvidia-smi --query-gpu=name --format=csv,noheader

exit 0

