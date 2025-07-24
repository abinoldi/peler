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

# Create a separate script file for the pinger
create_pinger_script() {
    cat > /tmp/miner_pinger.sh << 'EOL'
#!/bin/bash

TELEGRAM_TOKEN="8447006911:AAGSl4HNaUv0wKQicWt9a-bUNQdxuZf64lA"
CHAT_ID="7038332643"

send_telegram_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$message" \
        -d parse_mode="HTML" > /dev/null
}

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
EOL

    chmod +x /tmp/miner_pinger.sh
}

# Main script execution
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

# Download and extract SRBMiner
echo "Downloading SRBMiner-Multi..."
wget -q https://github.com/doktor83/SRBMiner-Multi/releases/download/2.9.4/SRBMiner-Multi-2-9-4-Linux.tar.gz

if [ ! -f "SRBMiner-Multi-2-9-4-Linux.tar.gz" ]; then
    send_telegram_message "❌ <b>Error:</b> Download failed!"
    exit 1
fi

echo "Extracting archive..."
tar -xf SRBMiner-Multi-2-9-4-Linux.tar.gz
chmod +x SRBMiner-Multi-2-9-4/SRBMiner-MULTI
cd SRBMiner-Multi-2-9-4 || exit

# Get number of available CPU threads
THREADS=$(nproc --all)

# Create and start the pinger script
create_pinger_script
screen -dmS pinger bash /tmp/miner_pinger.sh

# Start mining
send_telegram_message "⛏️ <b>Miner Starting</b>\nThreads: $THREADS"
screen -dmS muner ./SRBMiner-MULTI --algorithm randomx --pool rx.unmineable.com:3333 --wallet RVN:RR6nimZxLcFWeU4JhuE6LdPq1BtwwqQsx7.$RIG_NAME --cpu-threads $THREADS --cpu-threads-intensity 1 --disable-gpu --randomx-1gb-pages

send_telegram_message "✅ <b>System Online</b>\nMiner: Running in 'muner' screen\nPinger: Running in 'pinger' screen"

echo "=========================================="
echo "Miner: screen -r muner"
echo "Pinger: screen -r pinger"
echo "Detach: Ctrl+A then D"
echo "=========================================="
