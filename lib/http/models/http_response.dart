import 'package:hyper_net/http/models/http_error.dart';

sealed class HttpResponse<T> {
  const HttpResponse();

  R when<R>({
    required R Function(T data) success,
    required R Function(HttpError error) failure,
  }) {
    if (this is HttpSuccess<T>) {
      return success((this as HttpSuccess<T>).data);
    }
    else if (this is HttpFailure<T>) {
      return failure((this as HttpFailure<T>).error);
    }
    else {
      throw Exception('Unhandled Result type');
    }
  }

  bool get isSuccess => this is HttpSuccess<T>;
  bool get isFailure => this is HttpFailure<T>;

  T? get data => this is HttpSuccess<T> ? (this as HttpSuccess<T>).data : null;
  HttpError? get error => this is HttpFailure<T> ? (this as HttpFailure<T>).error : null;
}

final class HttpSuccess<T> extends HttpResponse<T> {
  @override
  final T data;
  const HttpSuccess(this.data);
}

final class HttpFailure<T> extends HttpResponse<T> {
  @override
  final HttpError error;
  const HttpFailure(this.error);
}
