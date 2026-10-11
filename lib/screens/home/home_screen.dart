import 'package:flutter/material.dart';
import 'package:hyper_net/theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hyper_net/extensions.dart';
import 'package:hyper_net/l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:hyper_net/screens/qr_scan_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hyper_net/models/subscription.dart';
import 'package:flutter_vless/flutter_vless.dart';
import 'package:hyper_net/screens/home/bloc/home_bloc.dart';
import 'package:hyper_net/screens/settings/settings_screen.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) {
          return const SizedBox.shrink();
        }

        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icon.png', height: 28),
                const SizedBox(width: 10),
                Text(
                  l10n.appTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: l10n.settings,
                onPressed: () {
                  context.navigatorPush(screen: const SettingsScreen());
                },
              ),
              buildAddMenu(context),
              const SizedBox(width: 4),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              buildHeroCard(context, state: state),
              if (state.subscriptions.isEmpty && state.singleConfigs.isEmpty)
                buildEmptyView(context)
              else ...[
                if (state.singleConfigs.isNotEmpty)
                  buildYourConfigsExpansionTile(context, state: state),
                ...state.subscriptions.map(
                  (subscription) => buildSubscriptionExpansionTile(
                    context,
                    subscription: subscription,
                    state: state,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget buildAddMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<int>(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add, size: 20, color: colorScheme.primary),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (menuContext) => [
        PopupMenuItem<int>(
          value: 0,
          onTap: () async {
            final bloc = context.read<HomeBloc>();
            final url = await addSubscription(context);
            if (url != null) {
              bloc.add(AddSubscription(url));
            }
          },
          child: ListTile(
            title: Text(l10n.addSubscription),
            leading: Icon(Icons.add_link_rounded, color: colorScheme.primary),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<int>(
          value: 1,
          onTap: () async {
            final bloc = context.read<HomeBloc>();
            final url = await addConfigUrl(context);
            if (url != null) {
              bloc.add(AddConfig(url));
            }
          },
          child: ListTile(
            title: Text(l10n.addConfig),
            leading: Icon(Icons.link_rounded, color: colorScheme.secondary),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<int>(
          value: 2,
          onTap: () async {
            await importFromClipboardIntoApp(context);
          },
          child: ListTile(
            title: Text(l10n.importFromClipboard),
            leading: const Icon(Icons.content_paste_rounded),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<int>(
          value: 3,
          onTap: () async {
            final text = await QrScanInput.scan(context);
            if (text == null || text.trim().isEmpty || !context.mounted) {
              return;
            }
            await addFromText(context, text.trim());
          },
          child: ListTile(
            title: Text(l10n.scanQrCode),
            leading: const Icon(Icons.qr_code_scanner_rounded),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget buildHeroCard(BuildContext context, {required HomeLoaded state}) {
    final l10n = AppLocalizations.of(context)!;
    final isConnected = state.vlessStatus.connectionState == VlessConnectionState.connected;
    final isConnecting = state.vlessStatus.connectionState == VlessConnectionState.connecting;
    final isStopping = canStop(state.vlessStatus);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedConfig = state.selectedConfig;

    final configProtocol = selectedConfig != null ? (selectedConfig.outbound1["protocol"] as String? ?? "") : "";

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isConnected
                ? [
                    AppTheme.connectedGradientStart.withValues(alpha: theme.brightness == Brightness.dark ? 0.45 : 0.08),
                    AppTheme.connectedGradientEnd.withValues(alpha: theme.brightness == Brightness.dark ? 0.35 : 0.04),
                  ]
                : [
                    colorScheme.primaryContainer.withValues(alpha: theme.brightness == Brightness.dark ? 0.25 : 0.4),
                    colorScheme.surfaceContainer.withValues(alpha: 0.2),
                  ],
          ),
          border: Border.all(
            color: isConnected
                ? AppTheme.success.withValues(alpha: 0.4)
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isConnected
                          ? AppTheme.success.withValues(alpha: 0.15)
                          : isConnecting
                              ? AppTheme.warning.withValues(alpha: 0.15)
                              : colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isConnected
                                ? AppTheme.success
                                : isConnecting
                                    ? AppTheme.warning
                                    : colorScheme.outline,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isConnected
                              ? l10n.connected
                              : isConnecting
                                  ? l10n.pingingEllipsis.replaceFirst('...', '')
                                  : l10n.disconnect,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isConnected
                                ? AppTheme.success
                                : isConnecting
                                    ? AppTheme.warningDark
                                    : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            Duration(seconds: state.vlessStatus.duration).format(context),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  if (state.selectedConfig == null) {
                    context.showSnackBar(message: l10n.selectConfigToConnect);
                    return;
                  }
                  if (isStopping) {
                    context.read<HomeBloc>().add(const Disconnect());
                  } else {
                    context.read<HomeBloc>().add(Connect(state.selectedConfig!));
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isConnected
                          ? [AppTheme.success, AppTheme.successDark]
                          : isConnecting
                              ? [AppTheme.warningMedium, AppTheme.warningDeep]
                              : [AppTheme.primaryDark, AppTheme.primaryLight],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isConnected
                                ? AppTheme.success
                                : isConnecting
                                    ? AppTheme.warning
                                    : AppTheme.primaryDark)
                            .withValues(alpha: 0.35),
                        blurRadius: isConnected ? 24 : 16,
                        spreadRadius: isConnected ? 2 : 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: isConnecting
                        ? const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              color: AppTheme.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(
                            Icons.power_settings_new_rounded,
                            size: 44,
                            color: AppTheme.white,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        selectedConfig != null
                            ? (_countryFlagEmoji(selectedConfig.remark) ??
                                (configProtocol.isNotEmpty ? configProtocol[0].toUpperCase() : '⚡'))
                            : '🌐',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedConfig != null ? _stripFlag(selectedConfig.remark) : l10n.selectConfigToConnect,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          if (selectedConfig != null)
                            Text(
                              "${configProtocol.toUpperCase()} • ${selectedConfig.address}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                    if (selectedConfig != null && state.delays.containsKey(selectedConfig.url))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (state.delays[selectedConfig.url]! < 0
                                  ? AppTheme.error
                                  : state.delays[selectedConfig.url]! < 250
                                      ? AppTheme.success
                                      : AppTheme.warning)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          state.delays[selectedConfig.url]! < 0
                              ? l10n.timeout
                              : '${state.delays[selectedConfig.url]!.formatToString(context)} ms',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: state.delays[selectedConfig.url]! < 0
                                ? AppTheme.error
                                : state.delays[selectedConfig.url]! < 250
                                    ? AppTheme.success
                                    : AppTheme.warningDark,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isConnected) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_upward_rounded, size: 16, color: AppTheme.uploadSpeed),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _formatBytes(context, bytes: state.vlessStatus.upload),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_downward_rounded, size: 16, color: AppTheme.downloadSpeed),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _formatBytes(context, bytes: state.vlessStatus.download),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmptyView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.12),
              ),
              child: Icon(
                Icons.vpn_lock_rounded,
                size: 38,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noSubscriptionsYet,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final bloc = context.read<HomeBloc>();
                  final url = await addSubscription(context);
                  if (url != null) {
                    bloc.add(AddSubscription(url));
                  }
                },
                icon: const Icon(Icons.add_link_rounded),
                label: Text(l10n.addSubscription),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await importFromClipboardIntoApp(context);
                    },
                    icon: const Icon(Icons.content_paste_rounded, size: 18),
                    label: Text(l10n.importFromClipboard, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final text = await QrScanInput.scan(context);
                      if (text != null && text.trim().isNotEmpty && context.mounted) {
                        await addFromText(context, text.trim());
                      }
                    },
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                    label: Text(l10n.scanQrCode, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildYourConfigsExpansionTile(BuildContext context, {required HomeLoaded state}) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Card(
        margin: EdgeInsets.zero,
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.tune_rounded, size: 20, color: colorScheme.onSecondaryContainer),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.yourConfigs,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${state.singleConfigs.length}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: l10n.pingAll,
                iconSize: 20,
                onPressed: () {
                  context.read<HomeBloc>().add(PingConfigs(state.singleConfigs));
                },
                icon: const Icon(Icons.speed_rounded),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'removeAll') {
                    context.read<HomeBloc>().add(const RemoveAllConfigs());
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'removeAll',
                    child: ListTile(
                      leading: const Icon(Icons.delete_sweep_outlined, color: AppTheme.error),
                      title: Text(l10n.removeAllConfigs),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: state.singleConfigs.map((config) {
            return buildConfig(
              context,
              config: config,
              state: state,
              deletable: true,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildSubscriptionExpansionTile(BuildContext context, {required Subscription subscription, required HomeLoaded state}) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isRefreshing = state.refreshing.contains(subscription.url);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Card(
        margin: EdgeInsets.zero,
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.cloud_outlined, size: 20, color: colorScheme.onPrimaryContainer),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  subscription.getTitle ?? l10n.subscription,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${subscription.configs.length}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 4),
              isRefreshing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      iconSize: 20,
                      tooltip: l10n.refreshLabel,
                      onPressed: () {
                        context.read<HomeBloc>().add(RefreshSubscription(subscription.url));
                      },
                      icon: const Icon(Icons.refresh_rounded),
                    ),
              IconButton(
                iconSize: 20,
                tooltip: l10n.pingAll,
                onPressed: () {
                  context.read<HomeBloc>().add(PingConfigs(subscription.configs));
                },
                icon: const Icon(Icons.speed_rounded),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'remove') {
                    context.read<HomeBloc>().add(RemoveSubscription(subscription.url));
                  } else if (value == 'share') {
                    showShareQrCodeDialog(context, subscription.url);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'share',
                    child: ListTile(
                      leading: const Icon(Icons.share_outlined),
                      title: Text(l10n.shareSubscriptionUrl),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: ListTile(
                      leading: const Icon(Icons.delete_outline, color: AppTheme.error),
                      title: Text(l10n.removeSubscription),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          subtitle: buildSubscriptionUsage(context, subscription: subscription),
          children: List.generate(
            subscription.announce != null ? subscription.configs.length + 1 : subscription.configs.length,
            (index) {
              if (subscription.announce != null && index == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.campaign_outlined, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            subscription.announce!,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        if (subscription.announceUrl != null)
                          IconButton(
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              context.urlLauncher(subscription.announceUrl!);
                            },
                            icon: const Icon(Icons.open_in_new_rounded),
                          ),
                      ],
                    ),
                  ),
                );
              }

              final config = subscription.configs[subscription.announce != null ? index - 1 : index];
              return buildConfig(
                context,
                config: config,
                state: state,
                deletable: false,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildConfig(BuildContext context, {required FlutterVlessURL config, required HomeLoaded state, bool deletable = false}) {
    final isSelected = identical(state.selectedConfig, config) || state.selectedConfig?.url == config.url;
    final protocol = (config.outbound1["protocol"] as String? ?? "").toUpperCase();
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final protocolColor = switch (protocol) {
      'VLESS' => AppTheme.protocolVless,
      'VMESS' => AppTheme.protocolVmess,
      'TROJAN' => AppTheme.protocolTrojan,
      'SHADOWSOCKS' => AppTheme.protocolShadowsocks,
      'HYSTERIA2' => AppTheme.protocolHysteria,
      _ => colorScheme.primary,
    };

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              showShareQrCodeDialog(context, config.url);
            },
            backgroundColor: AppTheme.slidableShare,
            foregroundColor: AppTheme.white,
            icon: Icons.share_rounded,
            label: l10n.share,
            borderRadius: BorderRadius.circular(12),
          ),
          if (deletable)
            SlidableAction(
              onPressed: (_) {
                context.read<HomeBloc>().add(RemoveConfig(config.url));
              },
              backgroundColor: AppTheme.slidableDelete,
              foregroundColor: AppTheme.white,
              icon: Icons.delete_outline_rounded,
              label: l10n.remove,
              borderRadius: BorderRadius.circular(12),
            ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.35)
              : AppTheme.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: colorScheme.primary.withValues(alpha: 0.6), width: 1.2)
              : Border.all(color: AppTheme.transparent),
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.15)
                  : colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              _countryFlagEmoji(config.remark) ?? (protocol.isNotEmpty ? protocol[0] : '⚡'),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          title: Text(
            _stripFlag(config.remark),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          subtitle: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: protocolColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  protocol,
                  style: TextStyle(
                    color: protocolColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  config.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.pinging.contains(config.url))
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (state.delays.containsKey(config.url))
                Builder(
                  builder: (_) {
                    final delay = state.delays[config.url]!;
                    final isTimeout = delay < 0;
                    final isFast = delay >= 0 && delay < 200;
                    final isMedium = delay >= 200 && delay < 500;

                    final badgeColor = isTimeout
                        ? AppTheme.error
                        : isFast
                            ? AppTheme.success
                            : isMedium
                                ? AppTheme.warningMedium
                                : AppTheme.deepOrange;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isTimeout ? l10n.timeout : '${delay.formatToString(context)} ms',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(width: 4),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
            ],
          ),
          onTap: () {
            context.read<HomeBloc>().add(SelectConfig(config));
          },
        ),
      ),
    );
  }

  Widget? buildSubscriptionUsage(BuildContext context, {required Subscription subscription}) {
    if (subscription.usedBytes == null && subscription.totalBytes == null && subscription.expireAt == null) {
      return null;
    }

    final progress = (subscription.usedBytes != null && subscription.totalBytes != null && subscription.totalBytes! > 0)
        ? (subscription.usedBytes! / subscription.totalBytes!).clamp(0.0, 1.0)
        : null;

    final daysLeft = subscription.expireAt?.difference(DateTime.now()).inDays;
    final isExpired = (daysLeft != null && daysLeft < 0);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (progress != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.9 ? AppTheme.error : colorScheme.primary,
                ),
              ),
            ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (subscription.usedBytes != null || subscription.totalBytes != null)
                Flexible(
                  child: Text(
                    '${_formatBytes(context, bytes: subscription.usedBytes ?? 0)} ${l10n.ofLabel} ${_formatBytes(context, bytes: subscription.totalBytes ?? 0)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: (subscription.usedBytes != null &&
                              subscription.totalBytes != null &&
                              subscription.usedBytes! >= subscription.totalBytes!)
                          ? AppTheme.error
                          : colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (daysLeft != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: (isExpired ? AppTheme.error : daysLeft <= 3 ? AppTheme.warning : colorScheme.surfaceContainerHighest)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isExpired ? l10n.expired : l10n.daysLeft(daysLeft.formatToString(context)),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isExpired
                          ? Colors.red
                          : daysLeft <= 3
                              ? Colors.amber.shade800
                              : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool canStop(VlessStatus status) {
    return switch (status.connectionState) {
      VlessConnectionState.connected || VlessConnectionState.connecting || VlessConnectionState.disconnecting => true,
      VlessConnectionState.disconnected || VlessConnectionState.unknown => false,
    };
  }

  Future<String?> addSubscription(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final subscriptionTextController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final result = await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (builderContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.add_link_rounded, color: colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.addSubscription,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: formKey,
                    child: TextFormField(
                      controller: subscriptionTextController,
                      decoration: InputDecoration(
                        labelText: l10n.url,
                        hintText: 'https://...',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: l10n.importFromClipboard,
                              onPressed: () async {
                                final text = await importFromClipboard();
                                if ((text ?? "").isNotEmpty) {
                                  subscriptionTextController.text = text!;
                                }
                              },
                              icon: const Icon(Icons.content_paste_rounded, size: 20),
                            ),
                            IconButton(
                              tooltip: l10n.scanQrCode,
                              onPressed: () async {
                                final text = await scanSubscriptionQrCode(context);
                                if (text != null) {
                                  subscriptionTextController.text = text;
                                }
                              },
                              icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                            ),
                          ],
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? "").isEmpty) {
                          return l10n.enterSubscriptionUrl;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(builderContext),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(builderContext, subscriptionTextController.text);
                            }
                          },
                          child: Text(l10n.add),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result is String) {
      return result;
    }
    return null;
  }

  Future<String?> addConfigUrl(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final configTextController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final result = await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (builderContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.link_rounded, color: colorScheme.secondary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.addConfig,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: formKey,
                    child: TextFormField(
                      controller: configTextController,
                      decoration: InputDecoration(
                        labelText: l10n.url,
                        hintText: 'vless://, vmess://, trojan://, ss://...',
                        suffixIcon: IconButton(
                          tooltip: l10n.importFromClipboard,
                          onPressed: () async {
                            final text = await importFromClipboard();
                            if ((text ?? "").isNotEmpty) {
                              configTextController.text = text!;
                            }
                          },
                          icon: const Icon(Icons.content_paste_rounded, size: 20),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? "").isEmpty) {
                          return l10n.enterSubscriptionUrl;
                        }
                        try {
                          FlutterVless.parse(value!);
                        } catch (_) {
                          return l10n.invalidConfigUrl;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(builderContext),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(builderContext, configTextController.text);
                            }
                          },
                          child: Text(l10n.add),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result is String) {
      return result;
    }
    return null;
  }

  bool isSubscriptionUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  void showShareQrCodeDialog(BuildContext context, String url) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.shareQrCode,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(dialogContext),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: CustomPaint(
                  size: const Size(220, 220),
                  painter: QrPainter(
                    data: url,
                    version: QrVersions.auto,
                    gapless: false,
                    eyeStyle: const QrEyeStyle(color: Colors.black),
                    dataModuleStyle: const QrDataModuleStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Share.share(url);
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: Text(l10n.share),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: url));
                        if (context.mounted) {
                          context.showSnackBar(message: l10n.linkCopied);
                        }
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: Text(l10n.copyLink),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> scanSubscriptionQrCode(BuildContext context) async {
    final result = await QrScanInput.scan(context);

    if (result == null) return null;

    if (isSubscriptionUrl(result)) {
      return result;
    }

    if (context.mounted) {
      context.showSnackBar(message: AppLocalizations.of(context)!.qrInvalidSubscriptionLink);
    }

    return null;
  }

  Future<String?> importFromClipboard() async {
    if (await Clipboard.hasStrings()) {
      return (await Clipboard.getData('text/plain'))?.text?.trim();
    }

    return null;
  }

  String _formatBytes(BuildContext context, {required int bytes}) {
    final units = [
      AppLocalizations.of(context)!.byte,
      AppLocalizations.of(context)!.kb,
      AppLocalizations.of(context)!.mb,
      AppLocalizations.of(context)!.gb,
      AppLocalizations.of(context)!.tb,
    ];

    double value = bytes.toDouble();
    int unitIndex = 0;

    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }

    return '${value.formatToString(context, maximumFractionDigits: value >= 10 || unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
  }

  Future<void> importFromClipboardIntoApp(BuildContext context) async {
    final text = (await Clipboard.getData('text/plain'))?.text?.trim() ?? '';

    if (text.isEmpty || !context.mounted) {
      return;
    }

    await addFromText(context, text);
  }

  Future<void> addFromText(BuildContext context, String text) async {
    if (text.isEmpty || !context.mounted) {
      return;
    }

    final bloc = context.read<HomeBloc>();

    try {
      if (text.toLowerCase().startsWith('http://') || text.toLowerCase().startsWith('https://')) {
        bloc.add(AddSubscription(text));
      }
      else {
        final configs = FlutterVless.parseMany(text);
        bloc.add(AddConfigs(configs));
      }
    } catch (ex) {
      if (context.mounted) {
        context.showSnackBar(message: ex.toString());
      }
    }
  }

  String? _countryFlagEmoji(String input) {
    if (input.isEmpty) return null;

    final nationalFlag = RegExp(r'[\u{1F1E6}-\u{1F1FF}]{2}', unicode: true);
    final subdivisionFlag = RegExp(r'\u{1F3F4}(?:[\u{E0000}-\u{E007F}])+', unicode: true);

    final match = nationalFlag.firstMatch(input) ?? subdivisionFlag.firstMatch(input);

    return match?.group(0);
  }

  String _stripFlag(String input) {
    final flagRegex = RegExp(r'([\u{1F1E6}-\u{1F1FF}]{2}|\u{1F3F4}(?:[\u{E0000}-\u{E007F}])+)', unicode: true);
    return input.replaceFirst(flagRegex, '').trim();
  }
}
