#!/bin/bash
# script for creating template. Needs a path to qcow2 image as an argument. Also needs virt-customie from libguestfs-tools
set -e

echo "verifying tools"
if ! command -v virt-customize >/dev/null 2>&1; then
    echo "virt-customize not found. Please install libguestfs-tools" >&2
    exit 1
fi

read -p "Username: " USER
read -s -p "Password for $USER: " PASS  # -s needs to be FIRST, or this doesnt work
echo
read -e -p "path to your public ssh key: " SSHKEY

ID=9001
STORAGE=main

echo "customizing the image..."
virt-customize -a "$1" \
    --run-command "useradd -m -s /bin/bash $USER" \
    --password "$USER:password:$PASS" \
    --run-command "usermod -aG sudo $USER" \
    --run-command "echo '$USER ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$USER && chmod 0440 /etc/sudoers.d/$USER" \
    --run-command 'truncate -s 0 /etc/machine-id /var/lib/dbus/machine-id 2>/dev/null || true' \
    --ssh-inject "$USER:file:$SSHKEY" \
    --install qemu-guest-agent

echo "creating template..."
qm create "$ID" \
    --name deb-12-template \
    --memory 2048 --cores 2 \
    --net0 virtio,bridge=vmbr1 \    # My virtual network is vmbr1, so this needs to be adjusted for specific usecases
    --ostype l26 \
    --agent 1 \
    --scsihw virtio-scsi-pci

echo "attaching the disk..."
IMPORT=$(qm importdisk "$ID" "$1" "$STORAGE" --format qcow2)
VOLUME=$(echo "$IMPORT" | sed -n "s/.*imported disk '\([^']*\)'.*/\1/p")
qm set "$ID" --scsi0 "$VOLUME" 
qm set "$ID" --boot order=scsi0

qm template "$ID"

echo "Template $ID is created" 