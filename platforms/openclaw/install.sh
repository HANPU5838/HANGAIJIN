#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/lib.sh"

echo "=== 正在安装 OpenClaw 平台包 ==="
echo ""

export CPATH="$PREFIX/include/glib-2.0:$PREFIX/lib/glib-2.0/include"

python -c "import yaml" 2>/dev/null || pip install pyyaml -q || true

mkdir -p "$PROJECT_DIR/patches"
cp "$SCRIPT_DIR/../../patches/glibc-compat.js" "$PROJECT_DIR/patches/glibc-compat.js"

cp "$SCRIPT_DIR/../../patches/systemctl" "$PREFIX/bin/systemctl"
chmod +x "$PREFIX/bin/systemctl"

# Clean up existing installation for smooth reinstall
if npm list -g openclaw &>/dev/null 2>&1 || [ -d "$PREFIX/lib/node_modules/openclaw" ]; then
    echo "Existing installation detected \u2014 cleaning up for reinstall..."
    npm uninstall -g openclaw 2>/dev/null || true
    rm -rf "$PREFIX/lib/node_modules/openclaw" 2>/dev/null || true
    npm uninstall -g clawdhub 2>/dev/null || true
    rm -rf "$PREFIX/lib/node_modules/clawdhub" 2>/dev/null || true
    rm -rf "$HOME/.npm/_cacache" 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC}   Previous installation cleaned"
fi

echo "正在安装：npm install -g openclaw@latest"
echo "这可能需要几分钟..."
echo ""
npm install -g openclaw@latest --ignore-scripts

echo ""
echo -e "${GREEN}[OK]${NC}   OpenClaw installed"

# Restore optional/channel deps that --ignore-scripts skips.
# Uses npm_config_ignore_scripts=true so sharp's native build doesn't block.
OPENCLAW_DIR="$(npm root -g)/openclaw"
if [ -d "$OPENCLAW_DIR" ]; then
    echo "正在恢复可选依赖..."
    (cd "$OPENCLAW_DIR" && npm_config_ignore_scripts=true node scripts/postinstall-bundled-plugins.mjs 2>/dev/null) || true
fi

bash "$SCRIPT_DIR/patches/openclaw-apply-patches.sh"

echo ""
echo "正在安装 clawdhub（技能管理器）..."
if npm install -g clawdhub --no-fund --no-audit; then
    echo -e "${GREEN}[OK]${NC}   clawdhub installed"
    CLAWHUB_DIR="$(npm root -g)/clawdhub"
    if [ -d "$CLAWHUB_DIR" ] && ! (cd "$CLAWHUB_DIR" && node -e "require('undici')" 2>/dev/null); then
        echo "正在安装 clawdhub 的 undici 依赖..."
        if (cd "$CLAWHUB_DIR" && npm install undici --no-fund --no-audit); then
            echo -e "${GREEN}[OK]${NC}   undici installed for clawdhub"
        else
            echo -e "${YELLOW}[WARN]${NC} undici installation 失败 (clawdhub may not work)"
        fi
    fi
else
    echo -e "${YELLOW}[WARN]${NC} clawdhub installation 失败 (non-critical)"
    echo "       Retry manually: npm i -g clawdhub"
fi

mkdir -p "$HOME/.openclaw"

echo ""
echo "正在更新：openclaw update"
echo "  (This includes building native modules and may take 5-10 minutes)"
echo ""
openclaw update || true
