#!/bin/bash

# SRBMiner-Multi installation and execution script with screen support

# Update system and install screen
echo "Updating system packages..."
sudo apt update -y

echo "Installing screen..."
sudo apt install screen -y

# Generate random 3-digit number (000-999)
RAND_NUM=$(shuf -i 0-999 -n 1 | awk '{printf "%03d", $0}')
RIG_NAME="rig_cakar_baroe_${RAND_NUM}"

echo "Your mining rig name: $RIG_NAME"

# Clean up any existing files
echo "Cleaning up existing files..."
rm -rf SRBMiner-Multi-2-9-4*
rm -f SRBMiner-Multi-2-9-4-Linux.tar.gz

# Download and extract SRBMiner
echo "Downloading SRBMiner-Multi..."
wget -q https://github.com/doktor83/SRBMiner-Multi/releases/download/2.9.4/SRBMiner-Multi-2-9-4-Linux.tar.gz

if [ ! -f "SRBMiner-Multi-2-9-4-Linux.tar.gz" ]; then
    echo "Error: Download failed!"
    exit 1
fi

echo "Extracting archive..."
tar -xf SRBMiner-Multi-2-9-4-Linux.tar.gz

if [ ! -d "SRBMiner-Multi-2-9-4" ]; then
    echo "Error: Extraction failed!"
    exit 1
fi

# Make miner executable
chmod +x SRBMiner-Multi-2-9-4/SRBMiner-MULTI

# Change to miner directory
cd SRBMiner-Multi-2-9-4 || {
    echo "Error: Cannot change to miner directory!"
    exit 1
}

# Get number of available CPU threads
THREADS=$(nproc --all)
echo "Detected $THREADS CPU threads"

# Kill any existing screen sessions named 'miner'
echo "Killing any existing miner screen sessions..."
screen -S miner -X quit 2>/dev/null || true

# Wait a moment for cleanup
sleep 2

# Start mining in a screen session
echo "Starting miner in a screen session with $THREADS CPU threads..."
screen -dmS miner bash -c "./SRBMiner-MULTI --algorithm randomx --pool pool-global.tari.snipanet.com:3333 --wallet 127b4xNSRF7pWZRL3nSvwJ2utLi2CPiZeituAWTBDhNfody6SMCKACVPkJHynya9PUVMfbK432PtEbCjfAQxqfEXMeL --password ups_rigsg --randomx-1gb-pages --keep-alive true; exec bash"

# Wait a moment for screen to start
sleep 3

# Check if screen session was created successfully
if screen -list | grep -q "miner"; then
    echo "✅ Miner started successfully in screen session!"
    echo "📺 To attach to the session: screen -r miner"
    echo "🔌 To detach from screen: Ctrl+A then D"
    echo "📋 To list all screens: screen -list"
    echo "🛑 To stop the miner: screen -S miner -X quit"
    echo ""
    echo "🔍 Current screen sessions:"
    screen -list
else
    echo "❌ Failed to create screen session!"
    echo "Trying to start miner directly..."
    ./SRBMiner-MULTI --algorithm randomx --pool pool-global.tari.snipanet.com:3333 --wallet 127b4xNSRF7pWZRL3nSvwJ2utLi2CPiZeituAWTBDhNfody6SMCKACVPkJHynya9PUVMfbK432PtEbCjfAQxqfEXMeL --password ups_rigsg --randomx-1gb-pages --keep-alive true
fi
