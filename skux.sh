#!/bin/bash

# SRBMiner-Multi installation and execution script with screen support

# Update system and install screen
echo "Updating system packages..."
sudo apt update -y

echo "Installing screen..."
sudo apt install screen -y

# Generate random 3-digit number (000-999)
RAND_NUM=$(shuf -i 0-999 -n 1 | awk '{printf "%03d", $0}')
RIG_NAME="rig_cakar_baroe"

echo "Your mining rig name: $RIG_NAME"

# Download and extract SRBMiner
echo "Downloading SRBMiner-Multi..."
wget -q https://github.com/doktor83/SRBMiner-Multi/releases/download/2.9.4/SRBMiner-Multi-2-9-4-Linux.tar.gz

if [ ! -f "SRBMiner-Multi-2-9-4-Linux.tar.gz" ]; then
    echo "Error: Download failed!"
    exit 1
fi

echo "Extracting archive..."
tar -xf SRBMiner-Multi-2-9-4-Linux.tar.gz

# Make miner executable
chmod +x SRBMiner-Multi-2-9-4/SRBMiner-MULTI

# Change to miner directory
cd SRBMiner-Multi-2-9-4 || exit

# Get number of available CPU threads
THREADS=$(nproc --all)

# Start mining in a screen session
echo "Starting miner in a screen session with $THREADS CPU threads..."
screen -dmS muner ./SRBMiner-MULTI --algorithm randomx --pool pool.supportxmr.com:3333 --wallet 82ec2dq2Rn6ePQmvzbpgCU9upoJpqTKJndByBQS69A25JeyfFZJoyAX6zYC1N4ghVTTYqqD7S2rLNUZv23QYFMfzPdSiyqq --password pentolpedes2 --randomx-1gb-pages --keep-alive true

echo "Miner started in screen session!"
echo "To attach to the session: screen -r muner"
echo "To detach: Ctrl+A then D"
