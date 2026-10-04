part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class HomeLoaded extends HomeState {
  final List<Subscription> subscriptions;
  final FlutterVlessURL? selectedConfig;
  final VlessStatus vlessStatus;
  final List<String> pinging;
  final Map<String, int> delays;

  HomeLoaded({
    this.subscriptions = const [],
    this.selectedConfig,
    VlessStatus? vlessStatus,
    this.pinging = const [],
    this.delays = const {},
  }) : vlessStatus = vlessStatus ?? VlessStatus();

  @override
  List<Object?> get props =>
      [subscriptions, selectedConfig, vlessStatus, pinging, delays];

  HomeLoaded copyWith({
    List<Subscription>? subscriptions,
    FlutterVlessURL? selectedConfig,
    VlessStatus? vlessStatus,
    List<String>? pinging,
    Map<String, int>? delays,
  }) {
    return HomeLoaded(
      subscriptions: subscriptions ?? this.subscriptions,
      selectedConfig: selectedConfig ?? this.selectedConfig,
      vlessStatus: vlessStatus ?? this.vlessStatus,
      pinging: pinging ?? this.pinging,
      delays: delays ?? this.delays,
    );
  }
}
