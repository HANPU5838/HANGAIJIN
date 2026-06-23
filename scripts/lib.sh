#!/usr/bin/env bash
# lib.sh — 共享函数库
# 用法: source "$SCRIPT_DIR/scripts/lib.sh"

# ── 颜色常量 ──
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# ── 项目常量 ──
PROJECT_DIR="$HOME/.hangaijin"
BIN_DIR="$PROJECT_DIR/bin"
PLATFORM_MARKER="$PROJECT_DIR/.platform"
REPO_BASE_ORIGIN="https://raw.githubusercontent.com/HANPU5838/HANGAIJIN/main"
REPO_BASE_MIRRORS=(
    "https://ghfast.top/https://raw.githubusercontent.com/HANPU5838/HANGAIJIN/main"
    "https://ghproxy.net/https://raw.githubusercontent.com/HANPU5838/HANGAIJIN/main"
    "https://mirror.ghproxy.com/https://raw.githubusercontent.com/HANPU5838/HANGAIJIN/main"
)
NPM_REGISTRY_ORIGIN="https://registry.npmjs.org/"
NPM_REGISTRY_MIRROR="https://registry.npmmirror.com/"
NPM_REGISTRY_CACHE="$PROJECT_DIR/.npm-registry"

# 检测可达的仓库地址（优先源地址，然后镜像）
resolve_repo_base() {
    if curl -sI --connect-timeout 3 "$REPO_BASE_ORIGIN/oa.sh" >/dev/null 2>&1; then
        REPO_BASE="$REPO_BASE_ORIGIN"
        return 0
    fi
    for mirror in "${REPO_BASE_MIRRORS[@]}"; do
        if curl -sI --connect-timeout 3 "$mirror/oa.sh" >/dev/null 2>&1; then
            echo -e "  ${YELLOW}[镜像]${NC} 使用镜像: ${mirror%%/oa.sh*}"
            REPO_BASE="$mirror"
            return 0
        fi
    done
    REPO_BASE="$REPO_BASE_ORIGIN"
    return 1
}

# 检测可达的 npm 源
resolve_npm_registry() {
    local choice
    local cache_file="$NPM_REGISTRY_CACHE"
    local reachable=0
    if curl -sI --connect-timeout 5 "$NPM_REGISTRY_ORIGIN" >/dev/null 2>&1; then
        choice="$NPM_REGISTRY_ORIGIN"
        reachable=1
    elif curl -sI --connect-timeout 5 "$NPM_REGISTRY_MIRROR" >/dev/null 2>&1; then
        echo -e "  ${YELLOW}[镜像]${NC} 使用 npm 镜像: ${NPM_REGISTRY_MIRROR}"
        choice="$NPM_REGISTRY_MIRROR"
        reachable=1
    else
        choice="$NPM_REGISTRY_ORIGIN"
    fi
    mkdir -p "$(dirname "$cache_file")"
    printf '%s' "$choice" > "$cache_file.tmp" && mv "$cache_file.tmp" "$cache_file"
    export NPM_CONFIG_REGISTRY="$choice"
    [ "$reachable" -eq 1 ] && return 0 || return 1
}

# 修复 npm 全局安装的 shebang
fix_npm_global_shebangs() {
    local _js
    for _js in "$PREFIX/lib/node_modules"/*/bin/*.js \
               "$PREFIX/lib/node_modules"/@*/*/bin/*.js; do
        [ -f "$_js" ] || continue
        head -1 "$_js" | grep -q '^#!/usr/bin/env node$' || continue
        sed -i "1s|#!/usr/bin/env node|#!$BIN_DIR/node|" "$_js"
    done
}

REPO_BASE="$REPO_BASE_ORIGIN"
BASHRC_MARKER_START="# >>> HANGAIJIN >>>"
BASHRC_MARKER_END="# <<< HANGAIJIN <<<"
FOXTERM_VERSION="1.0.0"

# ── 平台检测 ──
detect_platform() {
    if [ -f "$PLATFORM_MARKER" ]; then
        cat "$PLATFORM_MARKER"
        return 0
    fi
    if command -v openclaw &>/dev/null; then
        echo "openclaw"
        mkdir -p "$(dirname "$PLATFORM_MARKER")"
        echo "openclaw" > "$PLATFORM_MARKER"
        return 0
    fi
    echo ""
    return 1
}

# ── 平台名称校验 ──
validate_platform_name() {
    local name="$1"
    if [ -z "$name" ]; then
        echo -e "${RED}[失败]${NC} 平台名称为空"
        return 1
    fi
    if [[ ! "$name" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
        echo -e "${RED}[失败]${NC} 平台名称格式无效: $name"
        return 1
    fi
    return 0
}

# ── 用户确认 ──
ask_yn() {
    local prompt="$1"
    local reply
    if (echo -n "" > /dev/tty) 2>/dev/null; then
        read -rp "$prompt [Y/n] " reply < /dev/tty
    else
        read -rp "$prompt [Y/n] " reply
    fi
    [[ "${reply:-}" =~ ^[Nn]$ ]] && return 1
    return 0
}

# ── 加载平台配置 ──
# $1: 平台名称, $2: 基础目录
load_platform_config() {
    local platform="$1"
    local base_dir="$2"
    local config_path="$base_dir/platforms/$platform/config.env"

    validate_platform_name "$platform" || return 1

    if [ ! -f "$config_path" ]; then
        echo -e "${RED}[失败]${NC} 找不到平台配置: $config_path"
        return 1
    fi
    source "$config_path"
    return 0
}
