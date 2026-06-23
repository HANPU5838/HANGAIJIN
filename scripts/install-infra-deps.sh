#!/usr/bin/env bash
# install-infra-deps.sh - Install core 基础依赖 packages (L1)
# Extracted from install-deps.sh — 基础依赖 only.
# Always runs regardless of platform selection.
#
# Installs: git (+ pkg update/upgrade)
set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

echo "=== 正在安装 Infrastructure Dependencies ==="
echo ""

# Update and upgrade package repos
echo "Updating package repositories..."
echo "  (This may take a minute depending on mirror speed)"
pkg update -y
pkg upgrade -y

# Install core 基础依赖 packages
echo "正在安装 git..."
pkg install -y git

echo ""
echo -e "${GREEN}Infrastructure 依赖 installed.${NC}"
