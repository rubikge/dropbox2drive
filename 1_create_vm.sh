#!/bin/bash

# Configuration
INSTANCE_NAME="dropbox-migration-vm"
ZONE="us-central1-a"
MACHINE_TYPE="e2-micro"
IMAGE_FAMILY="ubuntu-2204-lts"
IMAGE_PROJECT="ubuntu-os-cloud"

echo "Creating Google Cloud VM Instance: $INSTANCE_NAME..."
echo "Zone: $ZONE"
echo "Machine Type: $MACHINE_TYPE (Free Tier eligible typically)"

gcloud compute instances create $INSTANCE_NAME \
    --zone=$ZONE \
    --machine-type=$MACHINE_TYPE \
    --image-family=$IMAGE_FAMILY \
    --image-project=$IMAGE_PROJECT \
    --boot-disk-size=30GB \
    --boot-disk-type=pd-standard \
    --tags=http-server,https-server

if [ $? -eq 0 ]; then
    echo "--------------------------------------------------------"
    echo "✅ VM Created Successfully!"
    echo "You can now SSH into it using:"
    echo "  gcloud compute ssh $INSTANCE_NAME --zone=$ZONE"
    echo "--------------------------------------------------------"
else
    echo "❌ Failed to create VM via gcloud."
fi
