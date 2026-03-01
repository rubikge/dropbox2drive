#!/bin/bash

# Update package list and install dependencies
echo "Updating system and installing dependencies..."
sudo apt-get update
sudo apt-get install -y tmux curl unzip

# Install Rclone
echo "Installing Rclone..."
sudo -v ; curl https://rclone.org/install.sh | sudo bash

echo "--------------------------------------------------------"
echo "✅ Setup Complete!"
echo "Next Steps:"
echo "1. Run 'rclone config' or manually create ~/.config/rclone/rclone.conf"
echo "2. Paste your local configuration (from 'rclone config file' on your local machine) into that file."
echo "3. Run the migration command inside a tmux session."
echo "--------------------------------------------------------"
