#!/bin/bash
# Improved SRBMiner-Multi installer with safety checks
# Usage: ./install.sh [--screen] [--wallet YOUR_WALLET]

set -e  # Exit on any error

# --------------------------
# Configurable Settings
# --------------------------
DEFAULT_WALLET="127b4xNSRF7pWZRL3nSvwJ2utLi2CPiZeituAWTBDhNfody6SMCKACVPkJHynya9PUVMfbK432PtEbCjfAQxqfEXMeL"
MINER_VERSION="2.9.4"
POOL="pool-global.tari.snipanet.com:3333"
PASSWORD="ks_tubun"
RIG_PREFIX="rig_cakar_baroe"

# --------------------------
# Arguments Parsing
# --------------------------
MODE="foreground"
WALLET="$DEFAULT_WALLET"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --screen)
            MODE="screen"
            shift
            ;;
        --wallet)
            WALLET="$2"
            shift 2
            ;;
        *)
            echo "❌ Unknown argument: $1"
            echo "Usage: $0 [--screen] [--wallet YOUR_WALLET]"
            exit 1
            ;;
    esac
done

# --------------------------
# Initial Checks
# --------------------------
echo "🔍 Checking for existing miner processes..."

# Check if SRBMiner-MULTI is already running
if pgrep -f "SRBMiner-MULTI" >/dev/null; then
    echo "⏭️ SRBMiner is already running! Skipping installation."
    exit 0
fi

# Check for existing screen session
if screen -list | grep -q "miner"; then
    echo "⏭️ Found existing 'miner' screen session! Attach with: screen -r miner"
    exit 0
fi

# --------------------------
# System Preparation
# --------------------------
echo "📦 Updating system packages..."
sudo apt update -y
sudo apt install -y screen

# Generate random rig name
RAND_NUM=$(shuf -i 0-999 -n 1 | awk '{printf "%03d", $0}')
RIG_NAME="${RIG_PREFIX}_${RAND_NUM}"
echo "🖥️ Rig name: $RIG_NAME"

# --------------------------
# Miner Installation
# --------------------------
WORK_DIR="$PWD"
MINER_DIR="SRBMiner-Multi-${MINER_VERSION//./-}"

echo "🧹 Cleaning previous installation..."
rm -rf "${MINER_DIR}"* "SRBMiner-Multi-*-Linux.tar.gz"

echo "⬇️ Downloading SRBMiner-Multi v${MINER_VERSION}..."
wget -q --show-progress \
    "https://github.com/doktor83/SRBMiner-Multi/releases/download/${MINER_VERSION}/SRBMiner-Multi-${MINER_VERSION//./-}-Linux.tar.gz" \
    || { echo "❌ Download failed!"; exit 1; }

echo "📂 Extracting archive..."
tar -xzf "SRBMiner-Multi-${MINER_VERSION//./-}-Linux.tar.gz" || { echo "❌ Extraction failed!"; exit 1; }

cd "$MINER_DIR" || { echo "❌ Failed to enter miner directory!"; exit 1; }
chmod +x SRBMiner-MULTI

# --------------------------
# Miner Execution
# --------------------------
THREADS=$(nproc --all)
echo "🧮 Detected CPU threads: $THREADS"

MINER_CMD=(
    "./SRBMiner-MULTI"
    "--algorithm" "randomx"
    "--pool" "$POOL"
    "--wallet" "$WALLET"
    "--password" "$PASSWORD"
    "--randomx-1gb-pages"
    "--keep-alive" "true"
)

if [[ "$MODE" == "screen" ]]; then
    echo "🚀 Starting in screen session (detached)..."
    screen -dmS miner "${MINER_CMD[@]}"
    echo "✅ Miner started in screen. Attach with: screen -r miner"
else
    echo "🚀 Starting in foreground mode (Ctrl+C to stop)..."
    exec "${MINER_CMD[@]}"
fi
