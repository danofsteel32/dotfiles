#!/usr/bin/env bash

# For all available distros see https://images.linuxcontainers.org/
DISTRO="${DISTRO:-almalinux}"
RELEASE="${RELEASE:-8}"
CONTAINER_NAME="${CONTAINER_NAME:-$DISTRO$RELEASE}"
# TODO: allow specifying a username instead of hardcoded 'deploy' user

# Create an almalinux8 container
incus launch images:"${DISTRO}/${RELEASE}" "${CONTAINER_NAME}"
sleep 4
# Create a user to run the playbook
incus exec "${CONTAINER_NAME}" -- adduser -ms /bin/bash deploy 
# Install minimum packages needed to run ansible playbooks
incus exec "${CONTAINER_NAME}" -- dnf install openssh-server sudo python3 firewalld -y
sleep 1
# Setup deploy user to run sudo w/o password
incus exec "${CONTAINER_NAME}" -- sh -c "echo 'deploy ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/deploy-user"
incus exec "${CONTAINER_NAME}" -- chmod 0440 /etc/sudoers.d/deploy-user
# Enable + start the sshd service
incus exec "${CONTAINER_NAME}" -- systemctl enable --now sshd.service
# Workaround for bugged nftables on almalinux 8
# without this, running firewall-cmd --reload will fail because of an exception in python-nftables
if [[ "$DISTRO" == "almalinux" ]] && [[ "$RELEASE" == "8" ]]; then
    incus exec "${CONTAINER_NAME}" -- sed -i 's/FirewallBackend=nftables/FirewallBackend=iptables/' /etc/firewalld/firewalld.conf
fi
# Enable + start the firewalld service
incus exec "${CONTAINER_NAME}" -- systemctl enable --now firewalld.service
# Create ssh key pair for deploy user
ssh-keygen -t rsa -b 2048 -N "" -q -f ./deploy-key
# Make sure .ssh dir exists
incus exec "${CONTAINER_NAME}" -- mkdir -p /home/deploy/.ssh
# Copy pub key to container
incus file push ./deploy-key.pub "${CONTAINER_NAME}/home/deploy/.ssh/authorized_keys"
# Fix permissions on .ssh dir
incus exec "${CONTAINER_NAME}" -- chown -R deploy:deploy /home/deploy/.ssh
incus exec "${CONTAINER_NAME}" -- chmod 0700 /home/deploy/.ssh
incus exec "${CONTAINER_NAME}" -- chmod 0600 /home/deploy/.ssh/authorized_keys
# Create a snapshot of the system in it's pristine condition
incus snapshot create "${CONTAINER_NAME}" clean

ip=$(incus list | grep "${CONTAINER_NAME}" | awk '{print $6}')
echo ""
echo "Setup complete! Here's how to ssh and run ansible playbooks:"
echo ""
echo "  ssh -i ./deploy-key deploy@${ip}"
echo "  ansible-playbook -u deploy -i ${ip}, --key-file ./deploy-key playbook.yaml"
echo ""
echo "If you bork something you can restore to a clean slate by running:"
echo ""
echo "  incus snapshot restore ${CONTAINER_NAME} clean"
echo ""
echo "To delete the container run:"
echo ""
echo "  incus delete ${CONTAINER_NAME} --force"
