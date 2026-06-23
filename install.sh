#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/lib.sh"

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${BOLD}  FoxTerm - OpenClaw 安卓安装器 v${FOXTERM_VERSION}${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""
echo "本脚本将在 Termux 上安装 OpenClaw，自动适配架构。"
echo ""

step() {
    echo ""
    echo -e "${BOLD}[$1/8] $2${NC}"
    echo "----------------------------------------"
}

# ──────────────────────────────────────────────
# 第一步：环境检查
# ──────────────────────────────────────────────
step 1 "环境检查"
if command -v termux-wake-lock &>/dev/null; then
    termux-wake-lock 2>/dev/null || true
    echo -e "${GREEN}[通过]${NC}  已获取 Termux 唤醒锁"
fi
bash "$SCRIPT_DIR/scripts/check-env.sh"

# ──────────────────────────────────────────────
# 第二步：选择平台
# ──────────────────────────────────────────────
step 2 "选择平台"
SELECTED_PLATFORM="openclaw"
echo -e "${GREEN}[通过]${NC}   平台: OpenClaw"
load_platform_config "$SELECTED_PLATFORM" "$SCRIPT_DIR"

# ──────────────────────────────────────────────
# 第三步：选择可选工具
# ──────────────────────────────────────────────
step 3 "选择可选工具"
INSTALL_TMUX=false
INSTALL_TTYD=false
INSTALL_DUFS=false
INSTALL_ANDROID_TOOLS=false
INSTALL_CODE_SERVER=false
INSTALL_OPENCODE=false
INSTALL_CLAUDE_CODE=false
INSTALL_GEMINI_CLI=false
INSTALL_CODEX_CLI=false
INSTALL_CHROMIUM=false

if ask_yn "安装 tmux（终端分屏工具）？"; then INSTALL_TMUX=true; fi
if ask_yn "安装 ttyd（网页终端）？"; then INSTALL_TTYD=true; fi
if ask_yn "安装 dufs（文件服务器）？"; then INSTALL_DUFS=true; fi
if ask_yn "安装 android-tools（adb）？"; then INSTALL_ANDROID_TOOLS=true; fi
if ask_yn "安装 Chromium（浏览器自动化，约 400MB）？"; then INSTALL_CHROMIUM=true; fi
if ask_yn "安装 code-server（网页版 VS Code）？"; then INSTALL_CODE_SERVER=true; fi
if ask_yn "安装 OpenCode（AI 编程助手）？"; then INSTALL_OPENCODE=true; fi
if ask_yn "安装 Claude Code CLI？"; then INSTALL_CLAUDE_CODE=true; fi
if ask_yn "安装 Gemini CLI？"; then INSTALL_GEMINI_CLI=true; fi
if ask_yn "安装 Codex CLI？"; then INSTALL_CODEX_CLI=true; fi

export INSTALL_TMUX INSTALL_TTYD INSTALL_DUFS INSTALL_ANDROID_TOOLS
export INSTALL_CODE_SERVER INSTALL_OPENCODE INSTALL_CLAUDE_CODE INSTALL_GEMINI_CLI INSTALL_CODEX_CLI
export INSTALL_CHROMIUM

# ──────────────────────────────────────────────
# 第四步：基础环境（L1）
# ──────────────────────────────────────────────
step 4 "基础环境"
bash "$SCRIPT_DIR/scripts/install-infra-deps.sh"
bash "$SCRIPT_DIR/scripts/setup-paths.sh"

# ──────────────────────────────────────────────
# 第五步：运行时依赖（L2）
# ──────────────────────────────────────────────
step 5 "运行环境"
if [ "${PLATFORM_NEEDS_GLIBC:-false}" = true ]; then
    bash "$SCRIPT_DIR/scripts/install-glibc.sh"
fi
if [ "${PLATFORM_NEEDS_NODEJS:-false}" = true ]; then
    bash "$SCRIPT_DIR/scripts/install-nodejs.sh"
fi
if [ "${PLATFORM_NEEDS_BUILD_TOOLS:-false}" = true ]; then
    bash "$SCRIPT_DIR/scripts/install-build-tools.sh"
fi
if [ "${PLATFORM_NEEDS_PROOT:-false}" = true ]; then
    pkg install -y proot
fi

# 设置当前会话环境变量
GLIBC_BIN_DIR="$PROJECT_DIR/bin"
GLIBC_NODE_DIR="$PROJECT_DIR/node"
export PATH="$GLIBC_BIN_DIR:$GLIBC_NODE_DIR/bin:$HOME/.local/bin:$PATH"
export TMPDIR="$PREFIX/tmp"
export TMP="$TMPDIR"
export TEMP="$TMPDIR"
export OA_GLIBC=1

# 自动检测 npm 镜像源
command -v resolve_npm_registry >/dev/null 2>&1 && resolve_npm_registry || true

# ──────────────────────────────────────────────
# 第六步：安装 OpenClaw
# ──────────────────────────────────────────────
step 6 "安装 OpenClaw"
bash "$SCRIPT_DIR/platforms/$SELECTED_PLATFORM/install.sh"

# ──────────────────────────────────────────────
# 第六点五步：环境变量 + CLI 命令 + 标记文件
# ──────────────────────────────────────────────
echo ""
echo -e "${BOLD}[6.5] 环境变量 + 命令工具 + 标记${NC}"
echo "----------------------------------------"
bash "$SCRIPT_DIR/scripts/setup-env.sh"

PLATFORM_ENV_SCRIPT="$SCRIPT_DIR/platforms/$SELECTED_PLATFORM/env.sh"
if [ -f "$PLATFORM_ENV_SCRIPT" ]; then
    eval "$(bash "$PLATFORM_ENV_SCRIPT")"
fi

mkdir -p "$PROJECT_DIR"
echo "$SELECTED_PLATFORM" > "$PLATFORM_MARKER"

cp "$SCRIPT_DIR/oa.sh" "$PREFIX/bin/oa"
chmod +x "$PREFIX/bin/oa"
cp "$SCRIPT_DIR/update.sh" "$PREFIX/bin/oaupdate"
chmod +x "$PREFIX/bin/oaupdate"

cp "$SCRIPT_DIR/uninstall.sh" "$PROJECT_DIR/uninstall.sh"
chmod +x "$PROJECT_DIR/uninstall.sh"

mkdir -p "$PROJECT_DIR/scripts"
mkdir -p "$PROJECT_DIR/platforms"
cp "$SCRIPT_DIR/scripts/lib.sh" "$PROJECT_DIR/scripts/lib.sh"
cp "$SCRIPT_DIR/scripts/setup-env.sh" "$PROJECT_DIR/scripts/setup-env.sh"
cp "$SCRIPT_DIR/scripts/backup.sh" "$PROJECT_DIR/scripts/backup.sh"
rm -rf "$PROJECT_DIR/platforms/$SELECTED_PLATFORM"
cp -R "$SCRIPT_DIR/platforms/$SELECTED_PLATFORM" "$PROJECT_DIR/platforms/$SELECTED_PLATFORM"

# ──────────────────────────────────────────────
# 第七步：安装可选工具（L3）
# ──────────────────────────────────────────────
step 7 "可选工具"
if [ "$INSTALL_TMUX" = true ]; then pkg install -y tmux; fi
if [ "$INSTALL_TTYD" = true ]; then pkg install -y ttyd; fi
if [ "$INSTALL_DUFS" = true ]; then pkg install -y dufs; fi
if [ "$INSTALL_ANDROID_TOOLS" = true ]; then pkg install -y android-tools; fi
if [ "$INSTALL_CHROMIUM" = true ]; then bash "$SCRIPT_DIR/scripts/install-chromium.sh" install; fi
if [ "$INSTALL_CODE_SERVER" = true ]; then
    mkdir -p "$PROJECT_DIR/patches"
    cp "$SCRIPT_DIR/patches/argon2-stub.js" "$PROJECT_DIR/patches/argon2-stub.js"
    bash "$SCRIPT_DIR/scripts/install-code-server.sh" install
fi
if [ "$INSTALL_OPENCODE" = true ]; then bash "$SCRIPT_DIR/scripts/install-opencode.sh" install; fi
if [ "$INSTALL_CLAUDE_CODE" = true ]; then npm install -g @anthropic-ai/claude-code; fi
if [ "$INSTALL_GEMINI_CLI" = true ]; then npm install -g @google/gemini-cli; fi
if [ "$INSTALL_CODEX_CLI" = true ]; then
    npm install -g @mmmbuto/codex-cli-termux
    _codex_bin="$PREFIX/bin/codex"
    _codex_pkg="$PREFIX/lib/node_modules/@mmmbuto/codex-cli-termux/bin"
    if [ -f "$_codex_pkg/codex.bin" ]; then
        [ -L "$_codex_bin" ] && rm -f "$_codex_bin"
        printf '#!%s/bin/bash\nPKG_BIN="%s"\nexport LD_LIBRARY_PATH="$PKG_BIN:${LD_LIBRARY_PATH:-}"\nexec "$PKG_BIN/codex.bin" "$@"\n' \
            "$PREFIX" "$_codex_pkg" > "$_codex_bin"
        chmod +x "$_codex_bin"
    fi
fi

command -v fix_npm_global_shebangs >/dev/null 2>&1 && fix_npm_global_shebangs || true

# ──────────────────────────────────────────────
# 第八步：验证安装
# ──────────────────────────────────────────────
step 8 "验证安装"
bash "$SCRIPT_DIR/tests/verify-install.sh"

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${GREEN}${BOLD}  ✅ 安装完成！${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""
echo -e "  $PLATFORM_NAME $($PLATFORM_VERSION_CMD 2>/dev/null || echo '')"
echo ""
echo "下一步："
echo "  $PLATFORM_POST_INSTALL_MSG"
echo ""
