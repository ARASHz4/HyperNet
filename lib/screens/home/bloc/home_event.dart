part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class InitializeVless extends HomeEvent {
  const InitializeVless();
}

final class LoadConfigs extends HomeEvent {
  const LoadConfigs();
}

final class RemoveAllConfigs extends HomeEvent {
  const RemoveAllConfigs();
}

final class AddConfig extends HomeEvent {
  final String rawUrl;

  const AddConfig(this.rawUrl);

  @override
  List<Object?> get props => [rawUrl];
}

final class AddConfigs extends HomeEvent {
  final List<FlutterVlessURL> configs;

  const AddConfigs(this.configs);

  @override
  List<Object?> get props => [configs];
}

final class RemoveConfig extends HomeEvent {
  final String rawUrl;

  const RemoveConfig(this.rawUrl);

  @override
  List<Object?> get props => [rawUrl];
}

final class LoadSubscriptions extends HomeEvent {
  const LoadSubscriptions();
}

final class AddSubscription extends HomeEvent {
  final String url;

  const AddSubscription(this.url);

  @override
  List<Object?> get props => [url];
}

final class SelectConfig extends HomeEvent {
  final FlutterVlessURL config;

  const SelectConfig(this.config);

  @override
  List<Object?> get props => [config];
}

final class VlessStatusChanged extends HomeEvent {
  final VlessStatus status;

  const VlessStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

final class Connect extends HomeEvent {
  final FlutterVlessURL config;

  const Connect(this.config);

  @override
  List<Object?> get props => [config];
}

final class Disconnect extends HomeEvent {
  const Disconnect();
}

final class SubscriptionRefreshed extends HomeEvent {
  final String url;
  final Subscription? subscription;

  const SubscriptionRefreshed({required this.url, required this.subscription});

  @override
  List<Object?> get props => [url, subscription];
}

final class RefreshSubscription extends HomeEvent {
  final String url;

  const RefreshSubscription(this.url);

  @override
  List<Object?> get props => [url];
}

final class RemoveSubscription extends HomeEvent {
  final String url;

  const RemoveSubscription(this.url);

  @override
  List<Object?> get props => [url];
}

final class PingConfigs extends HomeEvent {
  final List<FlutterVlessURL> configs;

  const PingConfigs(this.configs);

  @override
  List<Object?> get props => [configs];
}
