#!/bin/bash

# Create and setup the mining environment
sudo mkdir -p /opt/srbminer
sudo chown $USER:$USER /opt/srbminer

cd /opt/srbminer

# Download and extract miner
wget -q https://github.com/doktor83/SRBMiner-Multi/releases/download/2.9.4/SRBMiner-Multi-2-9-4-Linux.tar.gz
tar -xf SRBMiner-Multi-2-9-4-Linux.tar.gz --strip-components=1
rm SRBMiner-Multi-2-9-4-Linux.tar.gz
chmod +x SRBMiner-MULTI

# Create the service script
sudo bash -c 'cat > /usr/local/bin/tari_miner.sh << EOF
#!/bin/bash
cd /opt/srbminer
./SRBMiner-MULTI \
    --algorithm randomx \
    --pool pool-global.tari.snipanet.com:3333 \
    --wallet 127b4xNSRF7pWZRL3nSvwJ2utLi2CPiZeituAWTBDhNfody6SMCKACVPkJHynya9PUVMfbK432PtEbCjfAQxqfEXMeL \
    --password ups_vcon \
    --disable-gpu \
    --cpu-threads $(nproc)
EOF'

sudo chmod +x /usr/local/bin/tari_miner.sh

# Setup systemd service
sudo bash -c 'cat > /etc/systemd/system/tari-miner.service << EOF
[Unit]
Description=Tari Miner Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/srbminer
ExecStart=/usr/local/bin/tari_miner.sh
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF'

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable tari-miner.service
sudo systemctl start tari-miner.service

echo "Mining setup complete! Check status with: sudo systemctl status tari-miner.service"
