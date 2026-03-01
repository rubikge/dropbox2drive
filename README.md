# Dropbox to Google Drive Migration on GCP

This repository contains scripts to help you migrate data (~700GB) from Dropbox to Google Drive using a free-tier eligible Google Cloud Platform (GCP) Compute Engine instance.

**💰 Cost Information**
- **Compute Engine**: The script uses an `e2-micro` instance in `us-central1`, which is typically eligible for the [Google Cloud Free Tier](https://cloud.google.com/free) (assuming you haven't used your monthly allowance).
- **Network Egress**: Data transfer from GCP to other Google products (like Google Drive) is **generally free**, regardless of whether the IP is internal or external. 
    - *However, we strictly recommend monitoring your Billing page in the GCP Console during the first few GBs of transfer to ensure no unexpected charges arrive.*
- **Storage**: Ensure your Google Drive has enough space (2TB plan recommended for 700GB data).


## Prerequisites

1.  **Google Cloud Project**: You need an active GCP project with billing enabled.
2.  **Google Cloud CLI (`gcloud`)**: Installed and authenticated on your local machine.
3.  **Permissions**: Your active account needs permissions to create Compute Engine instances.

## Usage Guide

### Step 1: Initialize Environment
Clone or download this repository. Make all scripts executable:
```bash
chmod +x *.sh
```

### Step 2: Create the VM Instance
Run the creation script. It attempts to provision an `e2-micro` instance (Free Tier eligible) in `us-central1-a`.

```bash
./1_create_vm.sh
```
*Note: You may be prompted to enable the Compute Engine API if it's not active.*

### Step 3: Configure Rclone (Local Authentication)
Since the VM is headless (no browser), you need to generate the configuration tokens on your **local machine** first.

1.  Install rclone locally if you haven't: https://rclone.org/install/
2.  Run `rclone config`
3.  Create a remote for **Dropbox**:
    -   Name: `dropbox`
    -   Choose "dropbox" storage.
    -   Follow instructions to authorize via browser.
4.  Create a remote for **Google Drive**:
    -   Name: `gdrive`
    -   Choose "drive" storage.
    -   Follow instructions to authorize via browser.

Once done, locate your config file (usually `~/.config/rclone/rclone.conf`). You will see the content of this file in the next step.

### Step 4: Setup the VM
Connect to your new VM and set it up.

1.  SSH into the machine:
    ```bash
    gcloud compute ssh dropbox-migration-vm --zone=us-central1-a
    ```
2.  Once inside the VM, run the setup commands (copy-paste the contents of `2_vm_setup.sh` or run the following):
    ```bash
    sudo apt-get update && sudo apt-get install -y tmux curl
    sudo -v ; curl https://rclone.org/install.sh | sudo bash
    mkdir -p ~/.config/rclone
    nano ~/.config/rclone/rclone.conf
    ```
3.  **Paste** the content of your local `rclone.conf` into this file and save it (Ctrl+O, Enter, Ctrl+X).

### Step 5: Start Migration
We use `tmux` to ensure the process keeps running even if you disconnect from SSH.

1.  Start a new session:
    ```bash
    tmux new -s migration
    ```
2.  Run the migration command:
    ```bash
    rclone copy dropbox:/ gdrive:/ --transfers=8 --checkers=16 --drive-chunk-size=64M -P -v
    ```
    *(Adjust paths like `dropbox:/SourceFolder` or `gdrive:/DestFolder` if you don't want to copy the entire root)*

3.  **Detach** from the session and let it run: Press `Ctrl+B`, then `D`.
4.  You can now close the SSH connection.

### Step 6: Monitor & Finish
To check progress later:

1.  Select account/project and authenticate. To see what's available:
    ```bash
    gcloud auth list
    gcloud config set account ACCOUNT_EMAIL

    gcloud projects list
    gcloud config set project PROJECT_ID
    
    gcloud auth login
    ```
2.  SSH back in and attach:
    ```bash
    gcloud compute ssh dropbox-migration-vm --zone=us-central1-a --command="tmux attach -t migration"
    ```

3.  Once finished, **delete the VM** to avoid any potential lingering costs:
    ```bash
    gcloud compute instances delete dropbox-migration-vm --zone=us-central1-a
    ```
