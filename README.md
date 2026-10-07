# hyper_net

## Overview

HyperNet is a VPN / proxy client written in Flutter and built on the `flutter_vless` / Xray core.
It lets you:

- Add subscriptions from a URL and parse their configs (VLESS/VMess/Trojan/SS/SOCKS/Hysteria2)
- Add single configs directly from a link, QR code, JSON, or clipboard
- Select a config and connect/disconnect the Xray runtime
- Ping subscription configs for latency (`ms` / `timeout`)
- View subscription usage (progress bar) and days until expiry
- Multi-language UI (English / Persian) with a 3-state theme (System / Light / Dark)

## Requirements

- Flutter SDK – the project uses Dart `sdk: ^3.13.5`
- Android Studio / Android SDK (for the Android target)
- Xcode (for iOS / macOS targets)
- A signing team for iOS/macOS (PacketTunnel targets)

## Getting Started

```bash
flutter pub get
flutter run -d <device>
```

## Native clones

The same app has been re-written natively for demonstration purposes:

- `hyper_net_android` – Kotlin + Jetpack Compose Android project
- `hyper_net_ios` – Swift + SwiftUI iOS project

Build the Android Kotlin project with the bundled Gradle wrapper (Java 21):

```bash
cd ../hyper_net_android
JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home ./gradlew assembleDebug
```

## Notes

- Ping is best-effort and sequential because the underlying Xray provider
  serializes delay measurements.
- Native VPN on iOS / macOS requires a `PacketTunnelProvider` and a shared App
  Group; see the `hyper_net` iOS/macOS folder for reference.

---

This is **HyperNet** – a lightweight client that puts server configs and
subscription management in one screen for quickly connecting through the
flutter_vless / Xray backend.
