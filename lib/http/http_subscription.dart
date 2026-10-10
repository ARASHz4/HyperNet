import 'dart:io';
import 'package:hyper_net/http/base_http_client.dart';
import 'package:hyper_net/http/models/http_error.dart';
import 'package:hyper_net/http/models/http_response.dart';
import 'package:hyper_net/http/parse/parse_subscription.dart';
import 'package:hyper_net/models/subscription.dart';

class HttpSubscription extends BaseHttpClient {
  final _parseSubscription = ParseSubscription();
  
  Future<HttpResponse<Subscription>> getSubscription({required String subscriptionUrl}) async {
    final http = await dio();

    final response = await http.get(subscriptionUrl);
    
    if (response.statusCode == HttpStatus.ok) {
      final subscription = _parseSubscription.subscription(
        subscriptionUrl: subscriptionUrl,
        data: response.data,
        headers: response.headers.map,
      );

      if (subscription != null) {
        return HttpSuccess(subscription);
      }

      return HttpFailure(HttpError.fromJSON(1001, null));
    }

    return HttpFailure(HttpError.fromJSON(response.statusCode!, response.data));
  }
}
