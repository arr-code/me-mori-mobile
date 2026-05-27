import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../l10n/copy_id.dart';

/// Unified error surface for the UI layer.
///
/// Backend returns Indonesian-localized `error` strings; we surface
/// those as-is when present and fall back to a generic message otherwise.
/// In debug builds the human-readable [message] is suffixed with the
/// HTTP status + path so schema mismatches and routing bugs surface in
/// the banner instead of getting flattened to "Koneksi bermasalah".
sealed class AppError implements Exception {
  final String message;
  const AppError(this.message);

  @override
  String toString() => 'AppError($message)';
}

class NetworkError extends AppError {
  const NetworkError([super.message = CopyId.errNetwork]);
}

class ApiError extends AppError {
  final int statusCode;
  const ApiError(this.statusCode, super.message);
}

class UnauthorizedError extends AppError {
  const UnauthorizedError([super.message = CopyId.errCreds]);
}

class UnknownError extends AppError {
  const UnknownError([super.message = CopyId.errNetwork]);
}

AppError mapDioError(DioException e) {
  final method = e.requestOptions.method;
  final path = e.requestOptions.path;
  final tag = '$method $path';

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return NetworkError(_debugDecorate(CopyId.errNetwork, tag, 'timeout'));
    case DioExceptionType.connectionError:
      return NetworkError(
        _debugDecorate(CopyId.errNetwork, tag, 'no connection'),
      );
    case DioExceptionType.unknown:
      return NetworkError(
        _debugDecorate(CopyId.errNetwork, tag, e.error?.toString() ?? 'unknown'),
      );
    case DioExceptionType.cancel:
      return UnknownError(_debugDecorate(CopyId.errNetwork, tag, 'cancelled'));
    case DioExceptionType.badCertificate:
      return NetworkError(
        _debugDecorate(CopyId.errNetwork, tag, 'bad cert'),
      );
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode ?? 0;
      final body = e.response?.data;
      final serverMsg = _extractErrorMessage(body);
      if (status == 401) {
        return UnauthorizedError(
          _debugDecorate(serverMsg ?? CopyId.errCreds, tag, 'HTTP $status'),
        );
      }
      return ApiError(
        status,
        _debugDecorate(serverMsg ?? CopyId.errNetwork, tag, 'HTTP $status'),
      );
  }
}

String? _extractErrorMessage(Object? body) {
  if (body is Map) {
    final raw = body['error'] ?? body['message'];
    if (raw is String && raw.isNotEmpty) return raw;
  }
  return null;
}

/// In debug builds, append a `[<tag> · <detail>]` suffix to the
/// user-facing message so schema mismatches and routing bugs are
/// visible in the banner. Release builds keep the message clean.
String _debugDecorate(String message, String tag, String detail) {
  if (!kDebugMode) return message;
  return '$message  ·  $tag · $detail';
}
