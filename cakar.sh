#!/bin/bash

# Telegram bot configuration
TELEGRAM_TOKEN="8447006911:AAGSl4HNaUv0wKQicWt9a-bUNQdxuZf64lA"
CHAT_ID="7038332643"

# Function to send message to Telegram
send_telegram_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$message" \
        -d parse_mode="HTML" > /dev/null
}

# Function for the pinger
start_pinger() {
    # Function to generate status message
    generate_status() {
        local random_id=$(shuf -i 100-999 -n 1)
        local current_time=$(date +"%d-%m-%Y %H:%M:%S")
        echo -e "Miners [ID: $random_id]\nStatus: Good\nTime Updated: $current_time"
    }

    # Initial message
    send_telegram_message "🔔 <b>Pinger Started</b> $(date +"%d-%m-%Y %H:%M:%S")"

    # Main loop
    while true; do
        status_message=$(generate_status)
        send_telegram_message "$status_message"
        sleep 60
    done
}

# Send startup notification
send_telegram_message "🟢 <b>Miner System Startup</b> $(date +"%d-%m-%Y %H:%M:%S")"

# Update system and install screen
echo "Updating system packages..."
sudo apt update -y

echo "Installing screen..."
sudo apt install screen -y

# Generate random 3-digit number (000-999)
RAND_NUM=$(shuf -i 0-999 -n 1 | awk '{printf "%03d", $0}')
RIG_NAME="rig_cakar_gas"

# Send rig info to Telegram
send_telegram_message "🔧 <b>Miner Configuration</b>\nRig Name: $RIG_NAME\nRig ID: $RAND_NUM"

echo "Your mining rig name: $RIG_NAME"

# Download and extract SRBMiner
echo "Downloading SRBMiner-Multi..."
wget -q https://github.com/doktor83/SRBMiner-Multi/releases/download/2.9.4/SRBMiner-Multi-2-9-4-Linux.tar.gz

if [ ! -f "SRBMiner-Multi-2-9-4-Linux.tar.gz" ]; then
    send_telegram_message "❌ <b>Error:</b> Download failed!"
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

# Start the pinger in a separate screen session
screen -dmS pinger bash -c "$(declare -f send_telegram_message generate_status start_pinger); start_pinger"

# Send mining start notification
send_telegram_message "⛏️ <b>Miner Starting</b>\nThreads: $THREADS\nAlgorithm: randomx\nPool: rx.unmineable.com:3333"

# Start mining in a screen session
echo "Starting miner in a screen session with $THREADS CPU threads..."
screen -dmS muner ./SRBMiner-MULTI --algorithm randomx --pool rx.unmineable.com:3333 --wallet USDT:TThXMire8Q88eDWdVsZQfpS3DFt6jRPyQ2.$RIG_NAME --cpu-threads $THREADS --cpu-threads-intensity 1 --disable-gpu --randomx-1gb-pages

send_telegram_message "✅ <b>System Online</b>\nMiner: Running in 'muner' screen\nPinger: Running in 'pinger' screen"

echo "=========================================="
echo "Miner started in screen session: muner"
echo "Pinger started in screen session: pinger"
echo "To attach to miner: screen -r muner"
echo "To attach to pinger: screen -r pinger"
echo "To detach: Ctrl+A then D"
echo "=========================================="
