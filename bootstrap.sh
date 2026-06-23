#!/usr/bin/env bash
# 引导脚本 - 下载并安装
# Usage: curl -sL https://raw.githubusercontent.com/HANPU5838/HANGAIJIN/main/bootstrap.sh | bash
set -euo pipefail

REPO_TARBALL="https://github.com/HANPU5838/HANGAIJIN/archive/refs/heads/main.tar.gz"
INSTALL_DIR="$HOME/.hangaijin/installer"

RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}HANGAIJIN 安装引导${NC}"
echo ""

if ! command -v curl &>/dev/null; then
    echo -e "${RED}[FAIL]${NC} 未找到 curl，请运行: pkg install curl"
    exit 1
fi

echo "⬇️ 正在下载安装程序..."
mkdir -p "$INSTALL_DIR"
curl -sfL "$REPO_TARBALL" | tar xz -C "$INSTALL_DIR" --strip-components=1

bash "$INSTALL_DIR/install.sh"

cp "$INSTALL_DIR/uninstall.sh" "$HOME/.hangaijin/uninstall.sh"
chmod +x "$HOME/.hangaijin/uninstall.sh"
rm -rf "$INSTALL_DIR"
