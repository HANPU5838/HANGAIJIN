# 🦊 HANGAIJIN — Android 上的 OpenClaw

[English](README.en.md)

<div align="center">

<img src="docs/images/openclaw_android.jpg" alt="HANGAIJIN" width="520"/>

![Android 7.0+](https://img.shields.io/badge/Android-7.0%2B-brightgreen)
![Termux](https://img.shields.io/badge/Termux-Required-orange)
![No proot](https://img.shields.io/badge/proot--distro-Not%20Required-blue)
![License MIT](https://img.shields.io/badge/License-MIT-green)
![AArch64](https://img.shields.io/badge/Arch-arm64--v8a-lightgrey)

</div>

> 🚀 **一行命令**，在你的 Android 手机上运行 OpenClaw AI 智能体。
> 不需要 proot，不需要 Linux 发行版，只需要 Termux。

---

## ⚡ 快速开始

```bash
curl -sL https://raw.githubusercontent.com/HANPU5838/HANGAIJIN/main/bootstrap.sh | bash
```

复制上面的命令，在 Termux 中粘贴执行，坐等安装完成。

---

## ✨ 功能特点

| | | |
|:---:|---|---|
| 🚀 | **一键安装** | 全程自动化，无需手动配置，无需编译 |
| 📱 | **原生运行** | 直接在 Termux 上运行，不需要 proot/chroot |
| ⚡ | **零虚拟化开销** | glibc 兼容层 + grun wrapper 架构，原生性能 |
| 🔧 | **高度可扩展** | 插件系统支持自定义工具、技能和工作流 |
| 🛡️ | **平台感知** | 自动检测 CPU 架构，智能选择镜像源 |
| 🧠 | **多模型支持** | Claude、Gemini、Codex 等 AI 模型一键切换 |

---

## 📋 环境要求

| 项目 | 最低配置 | 推荐配置 |
|------|---------|---------|
| Android 版本 | 7.0 (API 24) | 12+ (API 31+) |
| CPU 架构 | arm64-v8a | aarch64 |
| 内存 | 2GB | 4GB+ |
| 存储空间 | 1GB 可用 | 4GB+ 可用 |
| Termux | F-Droid 最新版 | F-Droid 最新版 |

---

## 🛡️ 权限说明

**本项目的安装和使用全程不需要 Android 系统 root 权限。**

所有操作都在 Termux 的用户空间内完成：

| 所需权限 | 类型 | 说明 |
|---------|------|------|
| 🌐 网络访问 | 普通 | 下载安装包和依赖 |
| 📡 前台服务 | 普通 | 保持智能体后台运行 |
| 🔋 电池优化忽略 | 普通 | 防止后台被杀（可选） |
| ⚡ 唤醒锁 | 普通 | 保持设备不睡眠 |
| 🔄 开机启动 | 普通 | 设备重启后自动恢复 |
| 💾 存储访问 | 普通 | 存储配置和模型数据 |
| 📜 脚本执行 | 普通 | `chmod +x` 即可 |

---

## 🏗️ 技术架构

采用 **3 层解耦架构**，在 Android 上原生运行 Linux 二进制文件：

```
┌──────────────────────────────────────────────┐
│  L3 应用层                                    │
│  OpenClaw · CLI 工具 · AI 编程助手             │
├──────────────────────────────────────────────┤
│  L2 运行时                                    │
│  glibc 兼容层 · Node.js v22 LTS · Build Tools │
├──────────────────────────────────────────────┤
│  L1 基础层                                    │
│  系统依赖 · 镜像自适应 · 环境变量 · SSL 证书    │
└──────────────────────────────────────────────┘
```

### 关键技术点

- **glibc 兼容层**：使用 `ld.so` 直接执行 Linux 二进制文件，而非 patchelf，避免了 Android 的 seccomp 限制
- **`glibc-compat.js` 补丁**：修复 `os.cpus()`、`os.networkInterfaces()` 等 Node.js API 与 Android 内核的不兼容问题
- **镜像自适应**：自动检测 GitHub / npm 镜像源，确保在受限网络环境下也能正常安装
- **Android 12+ 兼容**：自动检测后台进程限制并提供处理方案

---

## 🧩 包含组件

| 组件 | 分类 | 说明 |
|------|------|------|
| 🧠 **OpenClaw 核心** | 必装 | AI 智能体运行环境，多模型、工具调用、记忆管理 |
| 📦 **Node.js** | 必装 | Linux-arm64 v22 LTS，glibc wrapper 封装 |
| 🔗 **glibc 兼容层** | 必装 | 通过 `ld-linux-aarch64.so.1` 直接运行 Linux 二进制文件 |
| 🌐 **Chromium** | 可选 | 浏览器自动化引擎（~400MB） |
| 💻 **code-server** | 可选 | 浏览器版 VS Code IDE |
| 🖥️ **tmux** | 可选 | 终端分屏工具 |
| 🌍 **ttyd** | 可选 | 网页终端 |
| 📁 **dufs** | 可选 | 轻量文件服务器 |
| 🔧 **android-tools** | 可选 | ADB 调试工具 |
| 🤖 **Claude / Gemini / Codex** | 可选 | AI 编程 CLI 工具 |

---

## 🎮 使用方法

安装完成后，使用 OpenClaw 官方命令管理：

```bash
openclaw gateway start    启动 OpenClaw 网关
openclaw gateway stop     停止 OpenClaw 网关
openclaw gateway restart  重启 OpenClaw 网关
openclaw gateway status   查看运行状态
openclaw onboard          初始化 & 配置智能体
openclaw update           更新 OpenClaw 核心
openclaw backup           备份配置
```

---

## ⚙️ 自定义配置

编辑 `~/.hangaijin/workspace/agents/main/agent/` 目录下的配置文件，自定义智能体的性格、工具和记忆系统。

---

## 📚 详细文档

### 安装目录结构

```
~/.hangaijin/
├── bin/                # grun 包装器脚本
├── node/               # Node.js 运行时
├── patches/            # 兼容性补丁
├── platforms/          # 平台特定配置
├── scripts/            # 工具脚本
└── .platform           # 平台标记文件
```

### 常见问题

**Q: Android 12+ 后台进程被杀死？**
A: 请参考 [禁用 Phantom 进程杀手文档](docs/disable-phantom-process-killer.md)。

**Q: 安装后看不到 `openclaw` 命令？**
A: 运行 `source ~/.bashrc` 重新加载环境，或重启 Termux。

**Q: glibc 兼容层有什么作用？**
A: Android 使用 Bionic libc（非标准），而 OpenClaw 需要 glibc。本项目通过 `ld-linux-aarch64.so.1` + 包装器脚本的方式运行 Linux 二进制文件，无需 patchelf 或 chroot。

---

## 👥 加入社区

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img src="docs/images/QQ群聊.jpg" alt="QQ 群聊" width="260"/>
        <br/>
        <strong>🐧 QQ 群</strong>
        <br/>
        <em>交流与反馈</em>
      </td>
      <td align="center">
        <img src="docs/images/纸飞机群.jpg" alt="纸飞机群聊" width="260"/>
        <br/>
        <strong>✈️ 纸飞机群</strong>
        <br/>
        <em>核心讨论与协作</em>
      </td>
      <td align="center">
        <img src="docs/images/QQ频道群.jpg" alt="QQ 频道" width="260"/>
        <br/>
        <strong>🎙️ QQ 频道</strong>
        <br/>
        <em>公告与社区活动</em>
      </td>
    </tr>
  </table>
</div>

---

## 📬 联系方式

| 平台 | 链接 / 账号 |
|------|------------|
| ✈️ 飞机频道 | <https://t.me/xhgeievx> |
| 🟢 腾讯频道 | pd19613869 |
| 💬 QQ 群 | 697890831 |

---

<div align="center">

*🦊 HANGAIJIN — 让每一台 Android 设备都拥有 AI 的灵魂*

**MIT License** · © 2026 HANPU5838

</div>
