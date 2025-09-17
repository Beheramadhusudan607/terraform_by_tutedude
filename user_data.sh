#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# 1. Update and Install Base Packages
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y python3 python3-pip nodejs npm

# 2. Install PM2 (Process Manager)
# PM2 is used to keep both applications running after the user_data script finishes.
sudo npm install -g pm2

# 3. Setup Flask Backend
FLASK_DIR="/home/ubuntu/flask_app"
mkdir -p $FLASK_DIR

# Create Flask files on the instance
cat <<EOF > $FLASK_DIR/app.py
$(cat app/flask_app/app.py)
EOF

cat <<EOF > $FLASK_DIR/requirements.txt
$(cat app/flask_app/requirements.txt)
EOF

# Install Python dependencies
pip3 install -r $FLASK_DIR/requirements.txt

# Start Flask with PM2
# Note: Using the python3 full path might be necessary in some environments
pm2 start python3 --name "flask_backend" -- $FLASK_DIR/app.py &

# 4. Setup Express Frontend
EXPRESS_DIR="/home/ubuntu/express_app"
mkdir -p $EXPRESS_DIR

# Create Express files on the instance
cat <<EOF > $EXPRESS_DIR/server.js
$(cat app/express_app/server.js)
EOF

cat <<EOF > $EXPRESS_DIR/package.json
$(cat app/express_app/package.json)
EOF

# Move into directory, install NPM dependencies, and start Express
cd $EXPRESS_DIR
npm install

# Start Express with PM2
pm2 start server.js --name "express_frontend" &

# 5. Save PM2 Process List
# This command ensures PM2 processes start automatically after a reboot.
pm2 save
pm2 startup # This generates and runs the necessary systemd/init script

# Clean up apt cache
sudo apt autoremove -y
sudo apt clean