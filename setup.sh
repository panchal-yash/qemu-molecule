apt-get update -y

apt-get install qemu-system python3 python3-venv python3-pip genisoimage libvirt-clients libvirt-daemon-system -y

systemctl enable --now libvirtd

VENV_DIR="${HOME}/.venv/molecule_qemu"

python3 -m venv ${VENV_DIR}
source ${VENV_DIR}/bin/activate

pip install --upgrade pip
pip install molecule==25.1.0 molecule-plugins==23.7.0 ansible-core==2.18.13

ansible-galaxy collection install ansible.posix # Needed for selinux and other playbook modules used by Percona

echo "Download VMS"

mkdir -p /var/lib/libvirt/images
cd /var/lib/libvirt/images
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img



ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

qemu-img convert -f qcow2 -O raw /var/lib/libvirt/images/jammy-server-cloudimg-amd64.img /var/lib/libvirt/images/jammy-server-cloudimg-amd64.raw
qemu-img convert -f qcow2 -O raw /var/lib/libvirt/images/noble-server-cloudimg-amd64.img /var/lib/libvirt/images/noble-server-cloudimg-amd64.raw


#!/bin/bash
#source ${HOME}/.venv/molecule_qemu/bin/activate
#echo "Molecule QEMU environment activated!"
#echo "Run 'molecule create' to start a VM"