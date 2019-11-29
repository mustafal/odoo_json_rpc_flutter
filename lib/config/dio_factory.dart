import 'dart:ffi';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:flutter/foundation.dart';
import 'package:odoo_json_rpc_flutter/config/config.dart';
import 'package:path_provider/path_provider.dart';

class DioFactory {
  static final _singleton = DioFactory._instance();

  static Dio get dio => _singleton._dio;

  static var _deviceName = 'Generic Device';
  static var _cookiesPath = './.cookies/';

  static Future<Void> computeDeviceInfo() async {
    if (Platform.isAndroid || Platform.isIOS) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _deviceName = '${androidInfo.brand} ${androidInfo.model}';
      } else {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _deviceName = iosInfo.utsname.machine;
      }
    } else if (Platform.isFuchsia) {
      _deviceName = 'Generic Fuchsia Device';
    } else if (Platform.isLinux) {
      _deviceName = 'Generic Linux Device';
    } else if (Platform.isMacOS) {
      _deviceName = 'Generic Macintosh Device';
    } else if (Platform.isWindows) {
      _deviceName = 'Generic Windows Device';
    }

    final directory = await getApplicationDocumentsDirectory();
    _cookiesPath = '${directory.path}/.cookies/';

    return Void();
  }

  Dio _dio;

  DioFactory._instance() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Config.BaseUrl,
        headers: {
          HttpHeaders.userAgentHeader: _deviceName,
        },
        connectTimeout: Config.Timeout,
        receiveTimeout: Config.Timeout,
        sendTimeout: Config.Timeout,
      ),
    );
    _dio.interceptors.add(CookieManager(PersistCookieJar(dir: _cookiesPath)));
    _dio.transformer = FlutterTransformer();
    if (!kReleaseMode) {
      _dio.interceptors.add(LogInterceptor(
        request: Config.LogNetworkRequest,
        requestHeader: Config.LogNetworkRequestHeader,
        requestBody: Config.LogNetworkRequestBody,
        responseHeader: Config.LogNetworkResponseHeader,
        responseBody: Config.LogNetworkResponseBody,
        error: Config.LogNetworkError,
        logPrint: (Object object) {
          debugPrint(object, wrapWidth: 768);
        },
      ));
    }
  }
}
