#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/lib.sh"
OA_CMD() { echo -e "${BOLD}oa${NC} — FoxTerm CLI v${FOXTERM_VERSION}"; }

case "${1:-}" in
    start)
        echo "🔄 启动 OpenClaw..."
        cd "$PLATFORM_DATA_DIR"
        openclaw gateway restart || openclaw gateway start
        echo "✅ OpenClaw 已启动"
        ;;
    stop)
        echo "🛑 停止 OpenClaw..."
        openclaw gateway stop 2>/dev/null || true
        termux-wake-unlock 2>/dev/null || true
        echo "✅ OpenClaw 已停止"
        ;;
    restart)
        echo "🔄 重启 OpenClaw..."
        openclaw gateway restart 2>/dev/null || true
        echo "✅ OpenClaw 已重启"
        ;;
    status)
        echo -e "  ${BOLD}FoxTerm${NC} v${FOXTERM_VERSION}"
        echo "  OpenClaw: $(openclaw --version 2>/dev/null || echo '未安装')"
        ;;
    update)
        bash "$SCRIPT_DIR/update.sh"
        ;;
    version|--version)
        echo "oa v${FOXTERM_VERSION}"
        ;;
    help|--help)
        OA_CMD
        echo ""
        echo "  命令:"
        echo "    start      启动 OpenClaw"
        echo "    stop       停止"
        echo "    restart    重启"
        echo "    status     查看状态"
        echo "    update     更新到最新版"
        echo "    help       显示帮助"
        ;;
    *)
        OA_CMD
        echo ""
        echo "  用法: oa <命令>"
        echo "  运行 oa help 查看帮助"
        ;;
esac
