part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class HomeLoaded extends HomeState {
  final List<Subscription> subscriptions;
  final FlutterVlessURL? selectedConfig;
  final VlessStatus vlessStatus;

  HomeLoaded({
    this.subscriptions = const [],
    this.selectedConfig,
    VlessStatus? vlessStatus,
  }) : vlessStatus = vlessStatus ?? VlessStatus();

  @override
  List<Object?> get props => [subscriptions, selectedConfig, vlessStatus];

  HomeLoaded copyWith({
    List<Subscription>? subscriptions,
    FlutterVlessURL? selectedConfig,
    VlessStatus? vlessStatus,
  }) {
    return HomeLoaded(
      subscriptions: subscriptions ?? this.subscriptions,
      selectedConfig: selectedConfig ?? this.selectedConfig,
      vlessStatus: vlessStatus ?? this.vlessStatus,
    );
  }
}
