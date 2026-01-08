import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // Headers
  Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Accept-Language': 'ar', // Default language
  };

  // Token storage
  String? _token;

  // Set language for API requests
  void setLanguage(String languageCode) {
    _headers['Accept-Language'] = languageCode;
  }

  // Set authorization token
  void setToken(String token) {
    _token = token;
    _headers['Authorization'] = 'Bearer $token';
  }

  // Remove authorization token
  void clearToken() {
    _token = null;
    _headers.remove('Authorization');
  }

  // Add custom header
  void addHeader(String key, String value) {
    _headers[key] = value;
  }

  // Remove custom header
  void removeHeader(String key) {
    _headers.remove(key);
  }

  // Logging helper
  void _logRequest(String method, String url, {dynamic body, Map<String, String>? headers}) {
    developer.log(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      name: 'API Request',
    );
    developer.log('Method: $method', name: 'API Request');
    developer.log('URL: $url', name: 'API Request');
    developer.log('Headers: ${headers ?? _headers}', name: 'API Request');
    if (body != null) {
      developer.log('Body: $body', name: 'API Request');
    }
    developer.log(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      name: 'API Request',
    );
  }

  void _logResponse(int statusCode, String url, dynamic body) {
    developer.log(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      name: 'API Response',
    );
    developer.log('URL: $url', name: 'API Response');
    developer.log('Status Code: $statusCode', name: 'API Response');
    developer.log('Body: $body', name: 'API Response');
    developer.log(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      name: 'API Response',
    );
  }

  void _logError(String method, String url, dynamic error) {
    developer.log(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      name: 'API Error',
    );
    developer.log('Method: $method', name: 'API Error');
    developer.log('URL: $url', name: 'API Error');
    developer.log('Error: $error', name: 'API Error');
    developer.log(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      name: 'API Error',
    );
  }

  // GET Request
  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final mergedHeaders = {..._headers, ...?headers};
      _logRequest('GET', url, headers: mergedHeaders);

      final response = await http.get(
        Uri.parse(url),
        headers: mergedHeaders,
      );

      _logResponse(response.statusCode, url, response.body);
      return response;
    } catch (e) {
      _logError('GET', url, e);
      rethrow;
    }
  }

  // POST Request
  Future<http.Response> post(
    String url, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final mergedHeaders = {..._headers, ...?headers};
      final jsonBody = body != null ? jsonEncode(body) : null;
      _logRequest('POST', url, body: jsonBody, headers: mergedHeaders);

      final response = await http.post(
        Uri.parse(url),
        headers: mergedHeaders,
        body: jsonBody,
      );

      _logResponse(response.statusCode, url, response.body);
      return response;
    } catch (e) {
      _logError('POST', url, e);
      rethrow;
    }
  }

  // PUT Request
  Future<http.Response> put(
    String url, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final mergedHeaders = {..._headers, ...?headers};
      final jsonBody = body != null ? jsonEncode(body) : null;
      _logRequest('PUT', url, body: jsonBody, headers: mergedHeaders);

      final response = await http.put(
        Uri.parse(url),
        headers: mergedHeaders,
        body: jsonBody,
      );

      _logResponse(response.statusCode, url, response.body);
      return response;
    } catch (e) {
      _logError('PUT', url, e);
      rethrow;
    }
  }

  // PATCH Request
  Future<http.Response> patch(
    String url, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final mergedHeaders = {..._headers, ...?headers};
      final jsonBody = body != null ? jsonEncode(body) : null;
      _logRequest('PATCH', url, body: jsonBody, headers: mergedHeaders);

      final response = await http.patch(
        Uri.parse(url),
        headers: mergedHeaders,
        body: jsonBody,
      );

      _logResponse(response.statusCode, url, response.body);
      return response;
    } catch (e) {
      _logError('PATCH', url, e);
      rethrow;
    }
  }

  // DELETE Request
  Future<http.Response> delete(
    String url, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final mergedHeaders = {..._headers, ...?headers};
      final jsonBody = body != null ? jsonEncode(body) : null;
      _logRequest('DELETE', url, body: jsonBody, headers: mergedHeaders);

      final response = await http.delete(
        Uri.parse(url),
        headers: mergedHeaders,
        body: jsonBody,
      );

      _logResponse(response.statusCode, url, response.body);
      return response;
    } catch (e) {
      _logError('DELETE', url, e);
      rethrow;
    }
  }

  // POST Multipart Request (for file uploads)
  Future<http.Response> postMultipart(
    String url, {
    required Map<String, String> fields,
    Map<String, File>? files,
    Map<String, String>? headers,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Merge headers (exclude Content-Type as it's set automatically for multipart)
      final mergedHeaders = <String, String>{
        'Accept': _headers['Accept'] ?? 'application/json',
        'Accept-Language': _headers['Accept-Language'] ?? 'ar',
      };

      // Add auth header if token exists
      if (_token != null) {
        mergedHeaders['Authorization'] = 'Bearer $_token';
      }

      // Add custom headers
      if (headers != null) {
        mergedHeaders.addAll(headers);
      }

      request.headers.addAll(mergedHeaders);

      // Add text fields
      request.fields.addAll(fields);

      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          final file = entry.value;
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();

          // Determine MIME type based on file extension
          String? mimeType;
          final extension = file.path.split('.').last.toLowerCase();
          if (extension == 'jpg' || extension == 'jpeg') {
            mimeType = 'image/jpeg';
          } else if (extension == 'png') {
            mimeType = 'image/png';
          }

          final multipartFile = http.MultipartFile(
            entry.key,
            stream,
            length,
            filename: file.path.split('/').last,
            contentType: mimeType != null ? http.MediaType.parse(mimeType) : null,
          );
          request.files.add(multipartFile);

          developer.log(
            'File: ${entry.key} => ${file.path.split('/').last} (${(length / 1024).toStringAsFixed(2)} KB, $mimeType)',
            name: 'API Multipart Request',
          );
        }
      }

      developer.log(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
        name: 'API Multipart Request',
      );
      developer.log('Method: POST (Multipart)', name: 'API Multipart Request');
      developer.log('URL: $url', name: 'API Multipart Request');
      developer.log('Headers: $mergedHeaders', name: 'API Multipart Request');
      developer.log('Fields: $fields', name: 'API Multipart Request');
      developer.log('Files: ${files?.keys.toList()}', name: 'API Multipart Request');
      developer.log(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
        name: 'API Multipart Request',
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse(response.statusCode, url, response.body);
      return response;
    } catch (e) {
      _logError('POST (Multipart)', url, e);
      rethrow;
    }
  }
}
