# 🦊 HANGAIJIN — Native AI Agent Deployment Framework for Android

[中文](README.md)

<div align="center">

![Android 7.0+](https://img.shields.io/badge/Android-7.0%2B-brightgreen)
![Termux](https://img.shields.io/badge/Termux-Native-blue)
![No proot](https://img.shields.io/badge/proot--distro-Not%20Required-orange)
![License MIT](https://img.shields.io/badge/License-MIT-green)

</div>

> **HANGAIJIN** is a native OpenClaw AI agent deployment framework designed for Android devices. It leverages a **glibc compatibility layer + grun wrapper** architecture to run Linux binaries directly in the Termux environment without proot/chroot, achieving zero-virtualization-overhead AI runtime.

---

## 🚀 Quick Start

```bash
curl -sL https://raw.githubusercontent.com/HANPU5838/HANGAIJIN/main/bootstrap.sh | bash
```

## System Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| Android | 7.0 (API 24) | 12+ (API 31+) |
| Architecture | arm64-v8a | aarch64 |
| RAM | 2GB | 4GB+ |
| Storage | 1GB free | 4GB+ free |
| Termux | Latest from F-Droid | Latest from F-Droid |

## Post-Install

```bash
# Start OpenClaw
oa start

# Check status
oa status

# Stop
oa stop

# Update
oa update
```

## Technical Architecture

HANGAIJIN uses a **3-tier decoupled architecture**:

- **L1 (Infrastructure)**: System dependencies, environment variables, mirror auto-detection
- **L2 (Runtime)**: glibc compatibility layer, Node.js runtime, build toolchain
- **L3 (Application)**: OpenClaw AI engine, CLI tools, optional components

The glibc compatibility layer uses `ld.so` direct execution (grun-style wrappers) instead of patchelf, avoiding Android's seccomp restrictions. The `glibc-compat.js` runtime patch fixes `os.cpus()`, `os.networkInterfaces()` and other API incompatibilities with the Android kernel.

## Components

- **OpenClaw**: AI agent engine with multi-model support, tool calling, memory management
- **Node.js**: Linux-arm64 v22 LTS with glibc wrapper
- **glibc**: Compatibility layer via `ld-linux-aarch64.so.1`
- **Optional**: Chromium, code-server, tmux, ttyd, dufs, android-tools, Claude/Gemini/Codex CLI

## License

MIT © 2026 HANPU5838
