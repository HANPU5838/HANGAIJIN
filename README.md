# 🦊 FoxTerm — OpenClaw on Android

[中文](README.zh.md)

<img src="docs/images/HAN.jpg" alt="FoxTerm">

![Android 7.0+](https://img.shields.io/badge/Android-7.0%2B-brightgreen)
![Termux](https://img.shields.io/badge/Termux-Required-orange)
![No proot](https://img.shields.io/badge/proot--distro-Not%20Required-blue)
![License MIT](https://img.shields.io/badge/License-MIT-green)

> One command to run OpenClaw on Android — no proot, no Linux distro, just Termux.

## Quick Start

```bash
curl -sL https://raw.githubusercontent.com/HANPU5838/HAN/main/bootstrap.sh | bash
```

## Features

- 🚀 **One-command install** — No manual setup, no compilation
- 📱 **Native Android** — Runs directly on Termux, no proot/chroot needed
- ⚡ **Lightweight** — Minimal footprint, maximum performance
- 🔧 **Extensible** — Plugin system for custom tools and skills
- 🛡️ **Platform-aware** — Auto-detects architecture and optimizes accordingly

## Requirements

- Android 7.0+
- Termux (install from F-Droid)
- 2GB+ RAM recommended
- 1GB+ free storage

## What's Included

| Component | Description |
|-----------|-------------|
| OpenClaw Core | AI agent runtime |
| Chromium | Browser automation engine |
| Node.js | JavaScript runtime |
| Optional Tools | tmux, code-server, ttyd, dufs, android-tools |

## Usage

After installation:

```bash
# Start OpenClaw
oa.sh start

# Stop OpenClaw
oa.sh stop

# Update
oa.sh update

# Check status
oa.sh status
```

## Customization

Edit `~/.openclaw/agents/main/agent/` to configure your AI agent's personality, tools, and memory.

---

*Built for running AI agents on Android devices.*
