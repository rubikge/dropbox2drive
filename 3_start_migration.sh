#!/bin/bash

# This script is intended to be run INSIDE the VM, preferably in a tmux session.

SOURCE_REMOTE="dropbox"
DEST_REMOTE="gdrive"

echo "Starting migration from $SOURCE_REMOTE to $DEST_REMOTE..."
echo "Running in dry-run mode first to verify..."

# Dry run
rclone copy "$SOURCE_REMOTE:/" "$DEST_REMOTE:/" --dry-run --transfers=8 --checkers=16 -P

read -p "Does the dry-run look good? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Starting actual transfer..."
    # Actual transfer
    # --drive-chunk-size 64M helps with performance on GDrive
    # --transfers 8 runs 8 parallel file transfers
    rclone copy "$SOURCE_REMOTE:/" "$DEST_REMOTE:/" \
        --transfers=8 \
        --checkers=16 \
        --drive-chunk-size=64M \
        -P \
        -v
else
    echo "Operation cancelled."
fi
