#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Molecule QEMU Setup Installation ===${NC}"

# Variables
VENV_DIR="${HOME}/.venv/molecule_qemu"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if running as root for system packages
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Note: Run with sudo for system package installation${NC}"
    SUDO="sudo"
else
    SUDO=""
fi

# Install system packages
echo -e "${GREEN}[1/6] Installing system packages...${NC}"
$SUDO apt update
$SUDO apt install -y \
    qemu-system-x86 \
    qemu-utils \
    genisoimage \
    libvirt-clients \
    libvirt-daemon-system \
    python3 \
    python3-venv \
    python3-pip

# Start and enable libvirtd
echo -e "${GREEN}[2/6] Starting libvirt service...${NC}"
$SUDO systemctl enable --now libvirtd

# Create virtual environment
echo -e "${GREEN}[3/6] Creating Python virtual environment...${NC}"
python3 -m venv ${VENV_DIR}
source ${VENV_DIR}/bin/activate

# Upgrade pip
echo -e "${GREEN}[4/6] Installing Python packages...${NC}"
pip install --upgrade pip
pip install \
    molecule==25.1.0 \
    molecule-plugins==23.7.0 \
    ansible-core==2.18.13

# Install Ansible collections
echo -e "${GREEN}[5/6] Installing Ansible collections...${NC}"
ansible-galaxy collection install \
    ansible.posix:1.6.2 \
    community.general:10.4.0

# Generate SSH key if not exists
echo -e "${GREEN}[6/6] Checking SSH key...${NC}"
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
else
    echo "SSH key already exists."
fi

# Create activation script
cat > ${SCRIPT_DIR}/activate.sh << 'ACTIVATE'
#!/bin/bash
source ${HOME}/.venv/molecule_qemu/bin/activate
echo "Molecule QEMU environment activated!"
echo "Run 'molecule create' to start a VM"
ACTIVATE
chmod +x ${SCRIPT_DIR}/activate.sh

echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo ""
echo "To activate the environment:"
echo "  source ${VENV_DIR}/bin/activate"
echo ""
echo "Or use the activation script:"
echo "  source ${SCRIPT_DIR}/activate.sh"
echo ""
echo "Installed versions:"
echo "  - molecule: $(pip show molecule | grep Version | awk '{print $2}')"
echo "  - molecule-plugins: $(pip show molecule-plugins | grep Version | awk '{print $2}')"
echo "  - ansible-core: $(pip show ansible-core | grep Version | awk '{print $2}')"
echo ""
echo "Usage:"
echo "  molecule create    # Start VM"
echo "  molecule converge  # Run playbook"
echo "  molecule verify    # Run tests"
echo "  molecule destroy   # Clean up"
echo "  molecule test      # Full cycle"