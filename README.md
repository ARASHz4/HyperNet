<p align="center">
  <img src="assets/icon.png" alt="HyperNet Logo" width="128" height="128" />
</p>

<h1 align="center">HyperNet</h1>

<p align="center">
  <strong>An open-source, high-performance cross-platform VPN & proxy client built with Flutter, powered by the Xray core.</strong>
</p>

<p align="center">
  <a href="https://github.com/ARASHz4/HyperNet/releases"><img src="https://img.shields.io/github/v/release/ARASHz4/HyperNet?color=blue&label=Release" alt="Latest Release" /></a>
  <a href="https://github.com/ARASHz4/HyperNet/stargazers"><img src="https://img.shields.io/github/stars/ARASHz4/HyperNet?style=flat&logo=github&color=gold" alt="GitHub Stars" /></a>
  <a href="https://github.com/ARASHz4/HyperNet/network/members"><img src="https://img.shields.io/github/forks/ARASHz4/HyperNet?style=flat&logo=github" alt="GitHub Forks" /></a>
  <a href="https://github.com/ARASHz4/HyperNet/issues"><img src="https://img.shields.io/github/issues/ARASHz4/HyperNet?logo=github" alt="GitHub Issues" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg" alt="License: Apache 2.0" /></a>
  <a href="https://github.com/ARASHz4/HyperNet/pulls"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome" /></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%3E%3D3.13-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-%3E%3D3.0-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Engine-Xray--core-5D3FD3" alt="Xray Core" />
  <img src="https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-brightgreen" alt="Platforms" />
</p>

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
  - [Protocols & Core](#-protocols--core)
  - [Subscription & Node Management](#-subscription--node-management)
  - [Live Stats & Ping Diagnostics](#-live-stats--ping-diagnostics)
  - [Smart Routing & Split Tunneling](#-smart-routing--split-tunneling)
  - [Modern UI & Localization](#-modern-ui--localization)
- [Download & Installation](#-download--installation)
- [Developer Setup](#-developer-setup)
- [Architecture & Tech Stack](#-architecture--tech-stack)
- [Routing Configuration Guide](#-routing-configuration-guide)
- [Contributing](#-contributing)
- [Disclaimer & Responsible Use](#-disclaimer--responsible-use)
- [License & Acknowledgments](#-license--acknowledgments)

---

## 📖 Overview

**HyperNet** is an open-source proxy and VPN client engineered for privacy, speed, and versatility. By combining the power of the **Xray-core** (via [`flutter_vless`](https://pub.dev/packages/flutter_vless)) with a reactive, glassmorphic **Flutter** user interface, HyperNet provides an all-in-one hub to manage subscription feeds, scan and share configs, bypass regional services, and monitor traffic in real time.

---

## ✨ Key Features

### 🌐 Protocols & Core
- **Full Xray-core Integration**: Powered by native tunnel bindings through `flutter_vless`.
- **Supported Protocols**:
  - **VLESS** (Reality, TLS, gRPC, WebSocket, TCP)
  - **VMess** (WebSocket, TCP, mKCP, etc.)
  - **Trojan**
  - **Shadowsocks (SS)**
  - **Hysteria 2**
  - Direct **Xray JSON** configuration input
  - Automated parsing and conversion for Clash YAML & sing-box configuration exports

### 📋 Subscription & Node Management
- **Remote Subscriptions**:
  - Import subscription links via HTTP/HTTPS.
  - Automatically parse subscription metadata (`profile-title`, announcements, and support URLs).
  - Dynamic quota monitoring (`subscription-userinfo`): track used bandwidth, total allowance, and expiration dates.
  - One-tap subscription synchronization.
- **Standalone Configurations**:
  - Add individual nodes manually or batch-import from clipboard.
  - Smart clipboard parser: auto-detects subscription links vs. collections of node URIs.
  - Built-in **QR Code Scanner** (supports live camera with torch/flip controls and gallery photo picker).
  - Share nodes as text or generate instant QR codes.
  - Slidable actions for quick management and deletion.

### ⚡ Live Stats & Ping Diagnostics
- **Concurrent Ping Probes**: Test response latency (in ms) across all servers in a subscription or config group simultaneously.
- **Real-Time Traffic Dashboard**: Glassmorphic connection banner displaying session duration, real-time download/upload speeds, and cumulative byte counts.
- **Reliable VPN Lifecycle**: Instant connection toggle with clear state indicators.

### 🔀 Smart Routing & Split Tunneling
- **Domain Bypass Rules**:
  - Exclude local or trusted domains from VPN routing.
  - Flexible syntax: `domain:`, `full:`, `regexp:`, `keyword:`, and `geosite:` prefixes.
  - Wildcard domains support (`*.domain.com`, `.domain.com`).
  - Automatic URL-to-domain sanitization.
- **Per-App Split Tunneling (Android)**:
  - Route specific apps outside the VPN by package name (e.g., local banking, video streaming, games).
- **Traffic Sniffing Override**: Built-in HTTP, TLS, and QUIC inbound sniffing for accurate domain routing.

### 🎨 Modern UI & Localization
- **Material 3 Design**: Clean typography, smooth transitions, and glassmorphic card layouts.
- **Theme Modes**: System Default, Dark Mode, and Light Mode.
- **Multi-Language Support**:
  - English 🇬🇧
  - Persian (Farsi) 🇮🇷 with complete Right-to-Left (RTL) layout and Solar Hijri (Shamsi) date formatting.

---

## 📥 Download & Installation

Pre-compiled binaries and release packages can be downloaded from the [GitHub Releases](https://github.com/ARASHz4/HyperNet/releases) page:

- **Android**: Download the latest `.apk` and install directly on your device.
- **Desktop & iOS**: Follow the [Developer Setup](#-developer-setup) instructions below to build from source.

---

## 🛠️ Developer Setup

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.13.5`)
- [Dart SDK](https://dart.dev/get-dart) (`>= 3.0.0`)
- **Android**: Android Studio with Android SDK (API 21+) and NDK
- **iOS / macOS**: macOS with Xcode 14+ and CocoaPods installed

### Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ARASHz4/HyperNet.git
   cd HyperNet
   ```

2. **Install project dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate localization files:**
   ```bash
   flutter gen-l10n
   ```

4. **Run in development mode:**
   ```bash
   flutter run
   ```

### Building for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Google Play)
flutter build appbundle --release

# iOS
flutter build ipa --release

# macOS Desktop
flutter build macos --release
```

### Static Analysis

Ensure all linter rules and static type checks pass:
```bash
flutter analyze
```

---

## 🏗️ Architecture & Tech Stack

HyperNet uses clean reactive architecture powered by **BLoC / Cubit** and local key-value caching:

```
lib/
├── application.dart            # Application cubit, themes, global providers
├── extensions.dart             # Utility & UI extensions (context, date, formatting)
├── http/                       # Networking layer
│   ├── base_http_client.dart   # Dio HTTP client wrapper
│   ├── http_subscription.dart  # Remote subscription fetcher
│   └── parse/                  # Header & subscription payload parsers
├── l10n/                       # Localization ARB files (en, fa) & generated delegates
├── models/                     # Data models (Subscription, Language)
├── preferences.dart            # SharedPreferences abstraction
├── screens/                    # UI presentation layer
│   ├── home/                   # Main dashboard, config lists, BLoC
│   ├── settings/               # App appearance, languages, routing rules, about
│   └── qr_scan_screen.dart     # Mobile scanner camera & gallery view
└── storage/                    # Local caching layer (Hive)
```

| Package | Purpose |
| :--- | :--- |
| [`flutter_vless`](https://pub.dev/packages/flutter_vless) | Native bridge to the Xray core and VPN tunnel management |
| [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) | Predictable state management (`HomeBloc`, `ApplicationCubit`) |
| [`hive`](https://pub.dev/packages/hive) / `hive_flutter` | Lightweight, blazingly fast local key-value storage |
| [`dio`](https://pub.dev/packages/dio) | HTTP client for downloading subscriptions and handling headers |
| [`mobile_scanner`](https://pub.dev/packages/mobile_scanner) | Fast, hardware-accelerated QR code scanner |
| [`qr_flutter`](https://pub.dev/packages/qr_flutter) | Interactive QR code generator for node sharing |
| [`glassmorphism_ui`](https://pub.dev/packages/glassmorphism_ui) | Glassmorphic visual components |
| [`shamsi_date`](https://pub.dev/packages/shamsi_date) | Solar Hijri (Jalali) date conversion for Persian locale |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | Persistent user settings and bypass configurations |

---

## ⚙️ Routing Configuration Guide

Under **Settings → Routing**, you can configure bypass rules to route traffic directly without passing through the proxy:

| Rule Type | Syntax / Example | Description |
| :--- | :--- | :--- |
| **Domain** | `example.com` or `domain:example.com` | Matches `example.com` and all subdomains |
| **Wildcard** | `*.google.com` or `.google.com` | Automatically transformed to standard regex |
| **Full Domain** | `full:api.example.com` | Exact match only |
| **GeoSite** | `geosite:ir` | Matches domains classified under predefined GeoSite lists |
| **RegExp** | `regexp:^.*\.internal$` | Matches using custom regular expressions |
| **Keyword** | `keyword:local` | Matches if the keyword is present in the host |
| **Direct URL** | `https://mybank.com/portal` | Host is automatically extracted (`mybank.com`) |

> [!TIP]
> **Android Split Tunneling**: Add app package names (e.g. `com.google.android.youtube` or `org.mozilla.firefox`) under **Bypass apps** to direct their traffic outside the VPN.

---

## 🤝 Contributing

Contributions make the open-source community an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. **Fork the Project**
2. **Create your Feature Branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit your Changes** (`git commit -m 'feat: Add some AmazingFeature'`)
4. **Push to the Branch** (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**

Please make sure to run `flutter analyze` before submitting your PR to ensure code quality.

---

## ⚠️ Disclaimer & Responsible Use

HyperNet is an open-source software project designed for network research, privacy preservation, and educational purposes. 

- The developers do not provide, host, or sell any VPN servers, proxy nodes, or subscription feeds.
- Users are solely responsible for ensuring that their use of this software complies with all applicable local laws, regulations, and terms of service.

---

## 📄 License & Acknowledgments

This project is open-source and licensed under the **[Apache License 2.0](LICENSE)**.

### Special Thanks
- [Xray-core](https://github.com/XTLS/Xray-core) – The supercharged proxy core.
- [flutter_vless](https://pub.dev/packages/flutter_vless) – Flutter bindings for Xray.
- [Flutter](https://flutter.dev) – Multi-platform UI toolkit.
- All open-source contributors and users supporting HyperNet!
