#!/bin/bash
# install-node-exporter.sh
# Installs and configures Prometheus Node Exporter as a systemd service on Ubuntu

set -e

VERSION="1.8.1"  # Update to desired version
NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.linux-amd64.tar.gz"

VERSION="1.8.1"  # Update to desired version
ARCH="linux-amd64"
NAME="node_exporter-${VERSION}.${ARCH}"
TARBALL="${NAME}.tar.gz"
DOWNLOAD_URL="https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/${TARBALL}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Extract the archive
echo "Downloading Node Exporter v${VERSION}..."
curl -fsSL -O "$DOWNLOAD_URL"

echo "Copying systemd service file..."
sudo cp "$SCRIPT_DIR/node_exporter.service" /etc/systemd/system/node_exporter.service

echo "Extracting Node Exporter..."
tar xvf "$TARBALL"

echo "Creating node_exporter user if needed..."
if ! id -u node_exporter &>/dev/null; then
  sudo useradd --system --no-create-home --shell /bin/false node_exporter
fi

echo "Installing node_exporter binary to /usr/local/bin..."
sudo install -o node_exporter -g node_exporter -m 0755 "${NAME}/node_exporter" /usr/local/bin/node_exporter

echo "Copying systemd service file..."
sudo cp "$SCRIPT_DIR/node_exporter.service" /etc/systemd/system/node_exporter.service

# Reload systemd and start service
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

echo "Node Exporter installed and running as a systemd service."

echo "Cleaning up..."
rm -rf "$TARBALL" "$NAME"
