#!/bin/bash
# Improved xmrig-vrl installer with safety checks
# Usage: ./install.sh [--screen] [--wallet YOUR_WALLET]

set -e  # Exit on any error

# --------------------------
# Configurable Settings
# --------------------------
DEFAULT_WALLET="v1g5udzsr8h9mr0t0r6mfyy2di7xtya6jkfzoc2.oyepx"
POOL="na.rplant.xyz:17155"
ALGO="randomvirel"
PASS="m=solo"
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

# Check if xmrig-vrl is already running
if pgrep -f "xmrig-vrl" >/dev/null; then
    echo "⏭️ xmrig-vrl is already running! Skipping installation."
    exit 0
fi

# Check for existing screen session
if screen -list | grep -q "sprint"; then
    echo "⏭️ Found existing 'sprint' screen session! Attach with: screen -r sprint"
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

echo "🧹 Cleaning previous installation..."
rm -rf "xmrig-vrl"* "xmrig-vrl-linux.tar.xz"

echo "⬇️ Downloading xmrig-vrl..."
wget -q --show-progress \
    "https://github.com/rplant8/xmrig-vrl/releases/download/6.0.24-virel/xmrig-vrl-linux.tar.xz" \
    || { echo "❌ Download failed!"; exit 1; }

echo "📂 Extracting archive..."
tar -xf "xmrig-vrl-linux.tar.xz" || { echo "❌ Extraction failed!"; exit 1; }

cd "xmrig-vrl" || { echo "❌ Failed to enter miner directory!"; exit 1; }
chmod +x xmrig-vrl

# --------------------------
# Miner Execution
# --------------------------
MINER_CMD=(
    "./xmrig-vrl"
    "-a" "$ALGO"
    "--url" "$POOL"
    "--tls"
    "--user" "$WALLET"
    "--pass" "$PASS"
)

if [[ "$MODE" == "screen" ]]; then
    echo "🚀 Starting in screen session (detached)..."
    screen -dmS sprint "${MINER_CMD[@]}"
    echo "✅ Miner started in screen. Attach with: screen -r sprint"
else
    echo "🚀 Starting in foreground mode (Ctrl+C to stop)..."
    exec "${MINER_CMD[@]}"
fi
