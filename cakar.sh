#!/bin/bash

# ==========================================
# Miner Installation + Persistent Pinger
# ==========================================

# Telegram configuration
TELEGRAM_TOKEN="8447006911:AAGSl4HNaUv0wKQicWt9a-bUNQdxuZf64lA"
CHAT_ID="7038332643"

# Generate FIXED ID for this miner (only once)
MINER_ID=$(shuf -i 100-999 -n 1)
RIG_ID=$(shuf -i 1-3 -n 1)
RIG_NAME="rig_cakar_$RIG_ID"

# Function to send Telegram messages
send_telegram_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$message" \
        -d parse_mode="HTML" > /dev/null
}

# Create permanent pinger script in /usr/local/bin
create_pinger_script() {
    sudo cat > /usr/local/bin/miner_pinger <<EOL
#!/bin/bash

# Persistent configuration
TELEGRAM_TOKEN="8447006911:AAGSl4HNaUv0wKQicWt9a-bUNQdxuZf64lA"
CHAT_ID="7038332643"
MINER_ID="$MINER_ID"

send_telegram_message() {
    local message="\$1"
    curl -s -X POST "https://api.telegram.org/bot\$TELEGRAM_TOKEN/sendMessage" \\
        -d chat_id="\$CHAT_ID" \\
        -d text="\$message" \\
        -d parse_mode="HTML" > /dev/null
}

# First run message
send_telegram_message "🔔 <b>Pinger Started</b>\\nMiner ID: \$MINER_ID\\nRig: $RIG_NAME"

# Main loop
while true; do
    current_time=\$(date +"%d-%m-%Y %H:%M:%S")
    send_telegram_message "⛏️ <b>Miner Status</b>\\nID: \$MINER_ID\\nStatus: Operational\\nUpdated: \$current_time\\nRig: $RIG_NAME"
    sleep 60
done
EOL

    sudo chmod +x /usr/local/bin/miner_pinger
}

# ==========================================
# Installation Process
# ==========================================

# Initial notification
send_telegram_message "🟢 <b>Miner Installation Started</b>\\nID: $MINER_ID\\nRig: $RIG_NAME"

# System setup
echo "Updating packages..."
sudo apt update -y
sudo apt install -y screen curl

# Download miner
echo "Downloading SRBMiner..."
wget -q https://github.com/doktor83/SRBMiner-Multi/releases/download/2.9.4/SRBMiner-Multi-2-9-4-Linux.tar.gz

if [ ! -f "SRBMiner-Multi-2-9-4-Linux.tar.gz" ]; then
    send_telegram_message "❌ <b>Download Failed!</b>\\nMiner setup aborted."
    exit 1
fi

# Extract and prepare miner
tar -xf SRBMiner-Multi-2-9-4-Linux.tar.gz
chmod +x SRBMiner-Multi-2-9-4/SRBMiner-MULTI
cd SRBMiner-Multi-2-9-4 || exit

# Create and start pinger
create_pinger_script
screen -dmS miner_pinger /usr/local/bin/miner_pinger

# Start mining
THREADS=$(nproc --all)
send_telegram_message "⚙️ <b>Starting Miner</b>\\nThreads: \$THREADS\\nWallet: RVN:RR6nimZxLcFWeU4JhuE6LdPq1BtwwqQsx7.$RIG_NAME"

screen -dmS miner ./SRBMiner-MULTI \
    --algorithm randomx \
    --pool rx.unmineable.com:3333 \
    --wallet RVN:RR6nimZxLcFWeU4JhuE6LdPq1BtwwqQsx7.$RIG_NAME \
    --cpu-threads $THREADS \
    --cpu-threads-intensity 1 \
    --disable-gpu \
    --randomx-1gb-pages

# Final status
send_telegram_message "✅ <b>System Online</b>\\n\\n🆔 <b>Miner ID:</b> $MINER_ID\\n🔧 <b>Rig Name:</b> $RIG_NAME\\n⏱ <b>Started:</b> \$(date +'%d-%m-%Y %H:%M:%S')\\n\\n💻 Miner: screen -r miner\\n🔔 Pinger: screen -r miner_pinger"

echo "========================================"
echo " Miner ID: $MINER_ID"
echo " Rig Name: $RIG_NAME"
echo "========================================"
echo " Miner screen: screen -r miner"
echo " Pinger screen: screen -r miner_pinger"
echo "========================================"
