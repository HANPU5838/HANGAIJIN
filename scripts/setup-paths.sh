#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

mkdir -p "$PREFIX/tmp"
echo -e "${GREEN}[通过]${NC}  创建临时目录 $PREFIX/tmp"

mkdir -p "$PROJECT_DIR/patches"
echo -e "${GREEN}[通过]${NC}  创建补丁目录 $PROJECT_DIR/patches"

echo ""
echo "路径映射（标准 → Termux 实际路径）："
echo "  /bin/sh      → $PREFIX/bin/sh"
echo "  /usr/bin/env → $PREFIX/bin/env"
echo "  /tmp         → $PREFIX/tmp"
