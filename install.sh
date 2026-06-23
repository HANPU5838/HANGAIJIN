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

step 1 "环境检查"
if command -v termux-wake-lock &>/dev/null; then
    termux-wake-lock 2>/dev/null || true
    echo -e "${GREEN}[通过]${NC}  已获取 Termux 唤醒锁"
fi
bash "$SCRIPT_DIR/scripts/check-env.sh"

step 2 "选择平台"
SELECTED_PLATFORM="openclaw"
echo -e "${GREEN}[通过]${NC}   平台: OpenClaw"
load_platform_config "$SELECTED_PLATFORM" "$SCRIPT_DIR"

step 3 "可选工具"
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
if ask_yn "安装 opencode（轻量网页编辑器）？"; then INSTALL_OPENCODE=true; fi
if ask_yn "安装 Claude Code CLI？"; then INSTALL_CLAUDE_CODE=true; fi
if ask_yn "安装 Gemini CLI？"; then INSTALL_GEMINI_CLI=true; fi
if ask_yn "安装 Codex CLI？"; then INSTALL_CODEX_CLI=true; fi

export INSTALL_TMUX INSTALL_TTYD INSTALL_DUFS INSTALL_ANDROID_TOOLS
export INSTALL_CODE_SERVER INSTALL_OPENCODE INSTALL_CLAUDE_CODE INSTALL_GEMINI_CLI INSTALL_CODEX_CLI
export INSTALL_CHROMIUM

step 4 "安装系统依赖"
bash "$SCRIPT_DIR/scripts/install-infra-deps.sh"

step 5 "安装 Node.js"
bash "$SCRIPT_DIR/scripts/install-nodejs.sh"

step 6 "安装 OpenClaw 核心"
bash "$SCRIPT_DIR/platforms/$SELECTED_PLATFORM/install.sh"

step 7 "安装可选工具"
bash "$SCRIPT_DIR/install-tools.sh"

step 8 "安装后配置"
bash "$SCRIPT_DIR/post-setup.sh"

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${BOLD}  ✅ 安装完成！${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""
echo "运行 oa.sh start 启动 OpenClaw"
echo "运行 oa.sh stop 停止"
echo "运行 oa.sh update 更新"
echo ""
echo "有问题看: https://github.com/HANPU5838/HAN"
echo ""
