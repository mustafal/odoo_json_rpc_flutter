import 'package:odoo_json_rpc_flutter/config/config.dart';
import 'package:odoo_json_rpc_flutter/config/dio_factory.dart';
import 'package:odoo_json_rpc_flutter/entities/web.session.authenticate/authenticate_params.dart';
import 'package:odoo_json_rpc_flutter/entities/web.session.authenticate/authenticate_request.dart';
import 'package:odoo_json_rpc_flutter/entities/web.session.authenticate/authenticate_response.dart';

class Odoo {
  const Odoo._();

  static void authenticate() async {
    final params = AuthenticateParams(
      login: Config.Email,
      password: Config.Password,
      db: Config.Database,
    );
    final request = AuthenticateRequest(id: 1, params: params);
    final response = await DioFactory.dio
        .post<Map<String, dynamic>>('web/session/authenticate',
        data: request.toJson())
        .catchError((final e) {
      final message = e.toString();
      print(message);
    });
    if (response == null) {
      return;
    }
    if (response.statusCode != 200) {
      print('response failed ${response.statusCode}:${response.statusMessage}');
      return;
    }
    final responseData = AuthenticateResponse.fromJsonMap(response.data ?? {});
    if (!responseData.isSuccessful) {
      print('${responseData.errorMessage}');
//      setState(() {
//        this.response = responseData.errorMessage;
//      });
      return;
    }
//    setState(() {
//      this.response = 'authenticated';
//    });
  }
}
