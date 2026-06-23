#!/usr/bin/env bash
# 引导脚本 - 下载并安装
# Usage: curl -sL https://raw.githubusercontent.com/HANPU5838/HAN/main/bootstrap.sh | bash
set -euo pipefail

REPO_TARBALL="https://github.com/HANPU5838/HAN/archive/refs/heads/main.tar.gz"
INSTALL_DIR="$HOME/.foxterm/installer"

RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}FoxTerm - OpenClaw on Android Bootstrap${NC}"
echo ""

if ! command -v curl &>/dev/null; then
    echo -e "${RED}[FAIL]${NC} curl not found. Install it with: pkg install curl"
    exit 1
fi

echo "Downloading installer..."
mkdir -p "$INSTALL_DIR"
curl -sfL "$REPO_TARBALL" | tar xz -C "$INSTALL_DIR" --strip-components=1

bash "$INSTALL_DIR/install.sh"

cp "$INSTALL_DIR/uninstall.sh" "$HOME/.foxterm/uninstall.sh"
chmod +x "$HOME/.foxterm/uninstall.sh"
rm -rf "$INSTALL_DIR"
