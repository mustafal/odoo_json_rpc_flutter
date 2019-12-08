import 'dart:core';
import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:odoo_json_rpc_flutter/callback/odoo_callback.dart';
import 'package:odoo_json_rpc_flutter/config/dio_factory.dart';
import 'package:odoo_json_rpc_flutter/entities/web.session.authenticate/authenticate_params.dart';
import 'package:odoo_json_rpc_flutter/entities/web.session.authenticate/authenticate_request.dart';
import 'package:odoo_json_rpc_flutter/entities/web.session.authenticate/authenticate_response.dart';

class Odoo {
  const Odoo._();

  static Future<Void> authenticate({
    @required final String login,
    @required final String password,
    @required final String db,
    @required final OnError onError,
    @required final OnResponse<AuthenticateResponse> onResponse,
  }) async {
    if (login == null || password == null || db == null) {
      if (!kReleaseMode) {
        print('please provide non-null values for parameters');
        print('login: $login, password: $password, db: $db');
      }
      return Void();
    }
    final request = AuthenticateRequest(
      id: 1,
      params: AuthenticateParams(
        login: login,
        password: password,
        db: db,
      ),
    );
    final response = await DioFactory.dio
        .post<Map<String, dynamic>>(
      'web/session/authenticate',
      data: request.toJson(),
    )
        .catchError((final e) {
      if (e is DioError) {
        if (onError != null) {
          onError(e);
        }
      } else {
        if (!kReleaseMode) {
          final message = e.toString();
          debugPrint(message, wrapWidth: 768);
        }
      }
    });
    if (response == null) {
      return Void();
    }
    final responseData = AuthenticateResponse.fromJsonMap(response.data ?? {});
    if (onResponse != null) {
      onResponse(responseData);
    }
    return Void();
  }
}
