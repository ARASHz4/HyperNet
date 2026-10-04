part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
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
