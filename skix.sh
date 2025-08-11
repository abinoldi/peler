#!/bin/bash

# SRBMiner-Multi installation & execution script
# Supports foreground or screen mode
# Usage:
#   ./install.sh        -> Foreground mode (default)
#   ./install.sh --screen -> Run in screen session named "miner"

MODE="foreground"
if [[ "$1" == "--screen" ]]; then
    MODE="screen"
fi

# Update and install screen if needed
echo "📦 Updating system..."
sudo apt update -y >/dev/null
sudo apt install -y screen >/dev/null

# Random rig name
RAND_NUM=$(shuf -i 0-999 -n 1 | awk '{printf "%03d", $0}')
RIG_NAME="rig_cakar_baroe_${RAND_NUM}"
echo "🖥 Rig name: $RIG_NAME"

# Clean old files
echo "🧹 Cleaning old miner files..."
rm -rf SRBMiner-Multi-2-9-4* SRBMiner-Multi-2-9-4-Linux.tar.gz

# Download miner
echo "⬇ Downloading SRBMiner-Multi..."
wget -q https://github.com/doktor83/SRBMiner-Multi/releases/download/2.9.4/SRBMiner-Multi-2-9-4-Linux.tar.gz
if [[ ! -f SRBMiner-Multi-2-9-4-Linux.tar.gz ]]; then
    echo "❌ Download failed!"
    exit 1
fi

# Extract
echo "📂 Extracting..."
tar -xf SRBMiner-Multi-2-9-4-Linux.tar.gz || { echo "❌ Extraction failed!"; exit 1; }

# Make executable
chmod +x SRBMiner-Multi-2-9-4/SRBMiner-MULTI
cd SRBMiner-Multi-2-9-4 || { echo "❌ Directory change failed!"; exit 1; }

THREADS=$(nproc --all)
echo "🧮 CPU threads: $THREADS"

# Kill any existing miner screen session
screen -S miner -X quit 2>/dev/null || true
sleep 1

if [[ "$MODE" == "screen" ]]; then
    echo "🚀 Starting miner in detached screen session..."
    screen -dmS miner ./SRBMiner-MULTI \
        --algorithm randomx \
        --pool pool-global.tari.snipanet.com:3333 \
        --wallet 127b4xNSRF7pWZRL3nSvwJ2utLi2CPiZeituAWTBDhNfody6SMCKACVPkJHynya9PUVMfbK432PtEbCjfAQxqfEXMeL \
        --password ks_tubun \
        --randomx-1gb-pages \
        --keep-alive true
    echo "✅ Miner started in screen. Use: screen -r miner"
else
    echo "🚀 Starting miner in foreground mode..."
    exec ./SRBMiner-MULTI \
        --algorithm randomx \
        --pool pool-global.tari.snipanet.com:3333 \
        --wallet 127b4xNSRF7pWZRL3nSvwJ2utLi2CPiZeituAWTBDhNfody6SMCKACVPkJHynya9PUVMfbK432PtEbCjfAQxqfEXMeL \
        --password ks_tubun \
        --randomx-1gb-pages \
        --keep-alive true
fi
