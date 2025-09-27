#!/usr/bin/env bash
# Install a KVM accelerated virtual machine and attach to it's console

name="fedora-36-dev-vm"
iso="Fedora-Server-netinst-x86_64-36-1.5.iso"

virt-install \
	--name $name \
    --cpu host \
    --vcpus 2 \
    --ram 4096 \
    --disk path=/var/lib/libvirt/images/$name.qcow2,size=64,format=qcow2 \
    --virt-type kvm \
    --os-type linux \
    --graphics none \
    --location $iso \
    --network network=bridged-network \
    --extra-args 'console=ttyS0,115200n8 --- console=ttyS0,115200n8' \
    --serial pty
