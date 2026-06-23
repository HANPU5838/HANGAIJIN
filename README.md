# 🦊 HANGAIJIN — Android 原生 AI 智能体部署框架

[English](README.en.md)

<div align="center">

![Android 7.0+](https://img.shields.io/badge/Android-7.0%2B-brightgreen)
![Termux](https://img.shields.io/badge/Termux-Native-blue)
![No proot](https://img.shields.io/badge/proot--distro-Not%20Required-orange)
![License MIT](https://img.shields.io/badge/License-MIT-green)

</div>

> **HANGAIJIN** 是一个专为 Android 设备设计的 OpenClaw AI 智能体原生部署框架。采用 **glibc 兼容层 + grun 包装器** 架构，无需 proot/chroot，直接在 Termux 环境中原生运行 Linux 二进制程序，实现零虚拟化开销的 AI 运行时环境。

---

## 📋 技术架构

```
┌─────────────────────────────────────────────────────────┐
│                     HANGAIJIN 架构                       │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────┐   │
│  │  ① 用户层                                       │   │
│  │  ┌─────────┐  ┌─────────┐  ┌──────────────────┐│   │
│  │  │ oa CLI  │  │ OpenClaw│  │   可选工具套件    ││   │
│  │  │ 管理工具 │  │ AI引擎  │  │ code-server/CLI  ││   │
│  │  └─────────┘  └─────────┘  └──────────────────┘│   │
│  └─────────────────────────────────────────────────┘   │
│                           ↓                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │  ② 运行时层 (L2)                                │   │
│  │  ┌──────────────┐  ┌──────────┐  ┌──────────┐  │   │
│  │  │ glibc 兼容层  │  │ Node.js  │  │  编译工具  │  │   │
│  │  │ (grun包装器) │  │ (glibc)  │  │ (build)   │  │   │
│  │  └──────────────┘  └──────────┘  └──────────┘  │   │
│  └─────────────────────────────────────────────────┘   │
│                           ↓                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │  ③ 基础设施层 (L1)                              │   │
│  │  ┌──────────┐  ┌──────────┐  ┌────────────────┐│   │
│  │  │ 系统依赖  │  │ 环境变量  │  │  镜像源自动    ││   │
│  │  │ pkg/apt  │  │ PATH/ENV │  │  切换/mirror   ││   │
│  │  └──────────┘  └──────────┘  └────────────────┘│   │
│  └─────────────────────────────────────────────────┘   │
│                           ↓                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │  ④ Android 系统层                                 │   │
│  │   Termux (bionic libc) · Android 7.0+ · ARM64   │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### 核心设计原理

HANGAIJIN 采用 **三层解耦 + 平台感知** 架构设计：

| 层级 | 名称 | 职责 | 关键技术 |
|------|------|------|---------|
| L1 | 基础设施层 | Termux 环境初始化、包管理、网络适配 | `pkg install`、镜像源自动切换、内核参数检测 |
| L2 | 运行时层 | glibc 兼容环境、Node.js 运行时、编译工具链 | `ld.so` 直加载、`grun` 包装器、glibc-compat.js 补丁 |
| L3 | 应用层 | OpenClaw AI 引擎、CLI 管理工具、可选工具套件 | npm 全局安装、shebang 自动修复、环境变量注入 |

**glibc 兼容机制：**
由于 Android 使用 bionic libc 而非 glibc，绝大多数 Linux 预编译二进制程序无法直接在 Termux 中运行。HANGAIJIN 采用 **grun 风格包装器** 解决此问题——通过 `ld.so` 直接加载 glibc 二进制程序，绕过 Android 的 seccomp 限制，同时通过 `NODE_OPTIONS` 注入 glibc-compat.js 补丁修复 `os.cpus()`、`os.networkInterfaces()` 等 API 在 Android 内核上的兼容性问题。

---

## ⚙️ 系统要求

| 要求 | 最低配置 | 推荐配置 |
|------|---------|---------|
| Android 版本 | 7.0 (API 24) | 12+ (API 31+) |
| 架构 | arm64-v8a | aarch64 |
| 内存 | 2GB | 4GB+ |
| 存储空间 | 1GB 可用 | 4GB+ 可用 |
| Termux | F-Droid 最新版 | F-Droid 最新版 |
| 网络 | 可访问 GitHub | 国内镜像加速 |

---

## 🚀 快速开始

### 一键安装

```bash
curl -sL https://raw.githubusercontent.com/HANPU5838/HANGAIJIN/main/bootstrap.sh | bash
```

### 分步安装流程

安装器将自动执行以下 8 步流程：

```
① 环境检查     → 检测 Termux、架构、磁盘空间、Android 版本
② 平台选择     → 加载 OpenClaw 平台配置
③ 可选工具     → 交互式选择安装的附加组件
④ 基础环境     → 安装系统依赖、配置环境变量、设置 PATH
⑤ 运行环境     → 安装 glibc 兼容层 → 部署 Node.js → 安装编译工具
⑥ 安装引擎     → npm install openclaw + 依赖修复
6.5 环境配置    → 设置 CLI 命令、写入平台标记、部署脚本
⑦ 可选工具     → 安装选择的附加组件
⑧ 验证安装     → 完整性验证测试
```

### 安装后管理

```bash
# 启动 OpenClaw AI 引擎
oa start

# 查看运行状态
oa status

# 停止引擎
oa stop

# 更新到最新版本
oa update
```

---

## 📦 组件清单

### 核心组件

| 组件 | 说明 | 安装方式 |
|------|------|---------|
| **OpenClaw** | AI 智能体核心引擎，提供多模型支持、工具调用、记忆管理和插件系统 | npm 全局安装 |
| **Node.js** | JavaScript 运行时（glibc 编译版 v22 LTS），通过 `ld.so` 包装器执行 | 自动下载安装 |
| **glibc 兼容层** | 提供 `ld-linux-aarch64.so.1` 动态链接器，使 Linux 程序可在 Termux 运行 | apt 源安装 |
| **glibc-compat.js** | 运行时补丁，修复 `os.cpus()` 返回 0、`os.networkInterfaces()` 权限异常等 Android 内核兼容问题 | 自动注入 `NODE_OPTIONS` |

### 可选组件（L3 工具集）

| 组件 | 说明 | 大小 |
|------|------|------|
| **Chromium** | 浏览器自动化引擎，支持 Puppeteer/Playwright | ~400MB |
| **code-server** | 网页版 VS Code，通过浏览器编写和调试代码 | ~300MB |
| **tmux** | 终端复用器，支持多标签页、会话持久化 | ~5MB |
| **ttyd** | 网页终端，可在浏览器中访问 Termux shell | ~10MB |
| **dufs** | HTTP 文件服务器，快速分享和管理文件 | ~3MB |
| **android-tools** | ADB 调试桥，设备调试和系统管理 | ~15MB |
| **Claude Code CLI** | Anthropic 的 AI 编程助手 | npm 包 |
| **Gemini CLI** | Google 的 AI 命令行工具 | npm 包 |
| **Codex CLI** | 开源 AI 编程助手（Termux 适配版） | npm 包 |
| **OpenCode** | 轻量级网页代码编辑器 | ~50MB |

---

## 🔧 高级配置

### 自定义 npm 镜像源

系统自动检测可用镜像源并写入缓存文件 `~/.hangaijin/.npm-registry`，如需手动指定：

```bash
export NPM_CONFIG_REGISTRY="https://registry.npmmirror.com"
```

### 网络代理配置

```bash
export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"
```

### glibc 兼容层手动安装

```bash
pkg install pacman
pacman -S glibc-runner --noconfirm
```

### Chromium 沙箱配置

由于 Android 内核限制，Chromium 通过 `--no-sandbox` 模式运行。若需沙箱支持，需手动配置 user namespace：

```bash
# 检查当前配置
oa status

# 参考文档配置
https://github.com/HANPU5838/HANGAIJIN/blob/main/docs/disable-phantom-process-killer.md
```

---

## 🛡️ 安全机制

| 安全措施 | 说明 |
|---------|------|
| **LD_PRELOAD 保护** | grun 包装器自动清除 `LD_PRELOAD` 环境变量，防止 bionic `libtermux-exec.so` 污染 glibc 进程 |
| **Seccomp 兼容** | 所有 glibc 二进制通过 `ld.so` 直接执行，绕过 Android seccomp 对 patchelf 程序的限制 |
| **NPM 镜像隔离** | 镜像源选择仅通过环境变量 `NPM_CONFIG_REGISTRY` 生效，不写入 `~/.npmrc`，避免污染用户配置 |
| **会话隔离** | 全局安装的 CLI 工具自动修复 shebang，确保使用 glibc Node.js 而非 bionic 版本 |

---

## 🔍 故障排除

| 问题 | 可能原因 | 解决方案 |
|------|---------|---------|
| `glibc dynamic linker not found` | glibc 兼容层未安装 | 运行 `bash ~/.hangaijin/scripts/install-glibc.sh` |
| `npm: command not found` | Node.js 未正确安装或 PATH 未配置 | 运行 `bash ~/.hangaijin/scripts/install-nodejs.sh` |
| 后台进程被杀死 (signal 9) | Android 12+ 幽灵进程限制 | 参考 `docs/disable-phantom-process-killer.md` |
| `sharp` 原生模块编译失败 | 编译工具链缺失 | 运行 `bash ~/.hangaijin/scripts/build-sharp.sh` |
| Chromium 启动崩溃 | 缺少系统依赖 | 运行 `bash ~/.hangaijin/scripts/install-chromium.sh` |

---

## 📁 文件结构

```
~/.hangaijin/
├── bin/                    # glibc 包装器（node/npm/npx）
├── node/                   # Node.js linux-arm64 运行时
├── patches/                # 兼容补丁
│   ├── glibc-compat.js     # Android 内核兼容补丁
│   ├── argon2-stub.js      # code-server 编译兼容
│   └── termux-compat.h     # C/C++ 编译兼容头文件
├── scripts/                # 维护脚本
├── platforms/              # 平台配置
│   └── openclaw/           # OpenClaw 平台定义
├── .platform               # 已安装平台标记
├── .npm-registry           # npm 镜像源缓存
└── uninstall.sh            # 卸载脚本
```

---

## 📜 许可协议

MIT License © 2026 HANPU5838

---

> *HANGAIJIN —— 在 Android 设备上释放 AI 智能体的全部潜力。*
