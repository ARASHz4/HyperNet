import 'package:flutter/foundation.dart';
import 'package:hyper_net/l10n/s.dart';

class HttpError {
  final String title;
  late int statusCode;
  String? details;
  String? type;
  List<HttpFieldError> errors;

  HttpError({
    required this.title,
    required this.statusCode,
    this.details,
    this.type,
    this.errors = const [],
  });

  factory HttpError.fromJSON(int statusCode, dynamic jsonError) {
    final Map<int, String> statusCodeMessages = {
      100: "Continue",
      101: "Switching Protocols",
      102: "Processing",
      200: "OK",
      201: "Created",
      202: "Accepted",
      203: "Non-Authoritative Information",
      204: "No Content",
      205: "Reset Content",
      206: "Partial Content",
      207: "Multi-Status",
      208: "Already Reported",
      226: "IM Used",
      300: "Multiple Choices",
      301: "Moved Permanently",
      302: "Found",
      303: "See Other",
      304: "Not Modified",
      305: "Use Proxy",
      306: "Switch Proxy",
      307: "Temporary Redirect",
      308: "Permanent Redirect",
      400: "Bad Request",
      401: "Unauthorized",
      402: "Payment Required",
      403: "Forbidden",
      404: "Not Found",
      405: "Method Not Allowed",
      406: "Not Acceptable",
      407: "Proxy Authentication Required",
      408: "Request Timeout",
      409: "Conflict",
      410: "Gone",
      411: "Length Required",
      412: "Precondition Failed",
      413: "Payload Too Large",
      414: "URI Too Long",
      415: "Unsupported Media Type",
      416: "Range Not Satisfiable",
      417: "Expectation Failed",
      418: "Im A Teapot",
      419: "Authentication Timeout",
      421: "Misdirected Request",
      422: "Unprocessable Entity",
      423: "Locked",
      424: "Failed Dependency",
      426: "Upgrade Required",
      428: "Precondition Required",
      429: "Too Many Requests",
      431: "Request Header Fields Too Large",
      440: "Login Timeout",
      444: "No Response",
      449: "Retry With",
      451: "Unavailable For Legal Reasons",
      494: "Request Header Too Large",
      495: "Cert Error",
      496: "No Cert",
      497: "HTTP To HTTPS",
      498: "Token Expired",
      499: "Client Closed Request",
      500: "Internal Server Error",
      501: "Not Implemented",
      502: "Bad Gateway",
      503: "Service Unavailable",
      504: "Gateway Timeout",
      505: "HTTP Version Not Supported",
      506: "Variant Also Negotiates",
      507: "Insufficient Storage",
      508: "Loop Detected",
      509: "Bandwidth Limit Exceeded",
      510: "Not Extended",
      511: "Network Authentication Required",
      599: "Network Timeout Error",
      1000: "Cannot Connect to Server",
      1001: "Incorrect data",
    };

    if (statusCode >= 400 && statusCode < 600) {
      try {
        if (jsonError is Map) {
          List<HttpFieldError> errors = [];

          dynamic jsonErrors = jsonError["errors"];
          if (jsonErrors is Map) {
            jsonErrors.forEach((error, reasons) {
              if (error is String && reasons is List) {
                final List<String> errorReasons = [];

                for (final reason in reasons) {
                  if (reason is String) {
                    errorReasons.add(reason);
                  }
                }

                errors.add(HttpFieldError(name: error, reasons: errorReasons));
              }
            });
          }

          return HttpError(
            title: jsonError["title"] ?? statusCodeMessages[statusCode] ?? "Unknown error",
            statusCode: statusCode,
            details: jsonError["detail"],
            type: jsonError["type"],
            errors: errors,
          );
        }
      } catch (ex) {
        if (kDebugMode) {
          print("http error parse json $ex");
        }
      }
    }

    return HttpError(
      title: statusCodeMessages[statusCode] ?? "Unknown error",
      statusCode: statusCode,
    );
  }

  String displayMessage({bool showStatusCode = false}) {
    String text;

    if (showStatusCode && statusCode >= 400 && statusCode < 600) {
      text = "$statusCode $title";
    }
    else {
      if (statusCode == 1000) {
        text = S.current.cannotConnectToServer;
      }
      else if (statusCode == 1001) {
        text = S.current.incorrectData;
      }
      else {
        text = title;
      }

      if (text.isEmpty) {
        text = statusCode.toString();
      }
    }

    if (details != null && (details?.isNotEmpty ?? false)) {
      text += "\n${details!}";
    }

    if (errors.isNotEmpty) {
      for (final error in errors) {
        text += "\n${error.name} ${error.reasons.join(", ")}";
      }
    }

    return text;
  }

  @override
  String toString() {
    String text = "$statusCode $title";

    if (details != null && (details?.isNotEmpty ?? false)) {
      text += " ${details!}";
    }

    return text;
  }
}

class HttpFieldError {
  String name;
  List<String> reasons;

  HttpFieldError({
    required this.name,
    required this.reasons,
  });
}
