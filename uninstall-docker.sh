#!/bin/bash
set -e

echo "[docker-uninstall] Stopping and disabling Docker service..."
systemctl stop docker || echo "[docker-uninstall] Docker service not running"
systemctl disable docker || echo "[docker-uninstall] Docker service not enabled"

echo "[docker-uninstall] Removing systemd service file..."
rm -f /etc/systemd/system/docker.service
systemctl daemon-reload

echo "[docker-uninstall] Removing Docker binaries from /usr/bin..."
rm -f /usr/bin/dockerd
rm -f /usr/bin/docker
rm -f /usr/bin/docker-init
rm -f /usr/bin/docker-proxy
rm -f /usr/bin/docker-containerd*
rm -f /usr/bin/docker-runc

echo "[docker-uninstall] Removing Docker Compose binary..."
rm -f /usr/bin/docker-compose

echo "[docker-uninstall] ? Docker and Docker Compose have been fully uninstalled"
