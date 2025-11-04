#!/bin/bash
set -e

echo "[docker-install] Starting installation of Docker Engine and Docker Compose..."

# Get the current script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

### === Docker Engine Installation === ###
ENGINE_VERSION="24.0.7"
ENGINE_TGZ="engine-${ENGINE_VERSION}.tgz"
ENGINE_URL="https://gitee.com/rakerose/doc/raw/master/${ENGINE_TGZ}"
ENGINE_LOCAL="${SCRIPT_DIR}/${ENGINE_TGZ}"

# Check if Docker is already installed
if command -v docker &> /dev/null; then
  echo "[docker-install] Docker is already installed: $(docker --version)"
else
  # Check for local offline package
  if [ -f "$ENGINE_LOCAL" ]; then
    echo "[docker-install] Found local Docker Engine package, skipping download"
  else
    echo "[docker-install] No local package found, downloading from Gitee..."
    curl -fsSL "$ENGINE_URL" -o "$ENGINE_LOCAL"
  fi

  echo "[docker-install] Extracting and installing Docker Engine to /usr/bin..."
  tar -xzf "$ENGINE_LOCAL" -C "$SCRIPT_DIR"
  sudo cp "${SCRIPT_DIR}/docker/"* /usr/bin/
fi

# Configure systemd service if not already present
if [ ! -f /etc/systemd/system/docker.service ]; then
  echo "[docker-install] Creating systemd service file for Docker..."
  sudo tee /etc/systemd/system/docker.service > /dev/null <<EOF
[Unit]
Description=Docker Service
After=network.target

[Service]
ExecStart=/usr/bin/dockerd
Restart=always
ExecReload=/bin/kill -s HUP \$MAINPID
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF
  sudo systemctl daemon-reexec
  sudo systemctl enable docker
fi

# Start Docker service if not running
if systemctl is-active --quiet docker; then
  echo "[docker-install] Docker service is already running"
else
  echo "[docker-install] Starting Docker service..."
  sudo systemctl start docker
fi

echo "[docker-install] Docker installation complete: $(docker --version)"

### === Docker Compose Installation === ###
COMPOSE_VERSION="2.2.2"
COMPOSE_FILENAME="compose-v${COMPOSE_VERSION}.bin"
COMPOSE_URL="https://gitee.com/rakerose/doc/raw/master/${COMPOSE_FILENAME}"
COMPOSE_LOCAL="${SCRIPT_DIR}/${COMPOSE_FILENAME}"
COMPOSE_DEST="/usr/bin/docker-compose"

# Check if Docker Compose is already installed
if command -v docker-compose &> /dev/null; then
  echo "[compose-install] Docker Compose is already installed: $(docker-compose --version)"
else
  # Check for local Compose binary
  if [ -f "$COMPOSE_LOCAL" ]; then
    echo "[compose-install] Found local Compose binary, skipping download"
  else
    echo "[compose-install] No local Compose binary found, downloading from Gitee..."
    curl -fsSL "$COMPOSE_URL" -o "$COMPOSE_LOCAL"
  fi

  echo "[compose-install] Installing Docker Compose to /usr/bin/docker-compose..."
  sudo cp "$COMPOSE_LOCAL" "$COMPOSE_DEST"
  sudo chmod +x "$COMPOSE_DEST"

  echo "[compose-install] Docker Compose installation complete: $(docker-compose --version)"
fi
