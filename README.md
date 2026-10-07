# HyperNet

HyperNet is a VPN / proxy client built in Flutter on top of the `flutter_vless`
plugin with the Xray core. It gives a single workspace for managing proxy
subscriptions and standalone configs.

## Features

- **Subscriptions** – import subscription URLs, see used/total traffic, and
  how many days remain until they expire
- **Single configs** – add standalone configs manually, paste from the
  clipboard, or scan a QR code; survive app restarts (stored locally with
  Hive)
- **Config list** – one `ExpansionTile` per subscription plus an "Other
  Servers" tile for single configs; tap a row to select it as the active
  config, or swipe left to delete a single config
- **Ping** – probe all configs in a subscription (or the Other Servers tile)
  and see latency in milliseconds (`timeout` when unreachable)
- **Connect / disconnect** – one button starts or stops the Xray VPN
  session for the currently selected config
- **Import from clipboard** – a ⋮ menu item in the app bar parses the
  clipboard as either a subscription URL (`http(s)`) or many bare configs
- **UI**
  - multi-language (English / Persian) with a language picker in Settings
  - Dark / Light / System theme modes

## Architecture notes

- State is driven by `flutter_bloc` (`Bloc` + events/state) – there are
  `HomeBloc` and `ApplicationCubit` providers
- Subscriptions are cached with Hive (`LocalStorage`), per-setting values are
  kept in `SharedPreferences`
- The Xray core handshake lives inside `flutter_vless`; if you add native
  targets remember that Android foreground-service notification uses
  `ic_notification`

## Getting started

```bash
flutter pub get
flutter run -d <device>
```

You can paste a single proxy link, a bunch of vless/vmess/trojan/ss/hysteria2
URLs, a raw Xray JSON config, or a Clash YAML / sing-box JSON payload into the
Add Config dialog or the app-bar ⋮ → Import from clipboard.

## Running tests

```bash
flutter analyze
```
