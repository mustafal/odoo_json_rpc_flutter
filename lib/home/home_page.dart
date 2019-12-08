import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:odoo_json_rpc_flutter/config/config.dart';
import 'package:odoo_json_rpc_flutter/config/dio_factory.dart';
import 'package:odoo_json_rpc_flutter/entities/web.session.authenticate/authenticate_request.dart';
import 'package:odoo_json_rpc_flutter/entities/web.session.authenticate/authenticate_response.dart';
import 'package:odoo_json_rpc_flutter/entities/web.session.authenticate/authenticate_params.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var response = 'Response will display here';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: FlatButton(
              child: Text(
                'Post Request',
                style: TextStyle(
                  color: Colors.lightBlue,
                  fontSize: 18.0,
                ),
              ),
              onPressed: () {
                _authenticate();
              },
            ),
          ),
          Text(response)
        ],
      ),
    );
  }

  void _authenticate() async {
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
      setState(() {
        this.response = responseData.errorMessage;
      });
      return;
    }
    setState(() {
      this.response = 'authenticated';
    });
    _searchRead();
  }

  void _searchRead() async {
    try {
      final data = {
        'jsonrpc': '2.0',
        'method': 'call',
        'id': 2,
        'params': {
          'model': 'res.partner',
          'fields': ['id', 'name', 'email'],
          'domain': [
            ['customer', '=', true]
          ],
          'offset': 0,
          'limit': 10,
          'sort': 'name ASC'
        }
      };
      final response = await DioFactory.dio
          .post<Map<String, dynamic>>('web/dataset/search_read', data: data);
      if (response.statusCode == 200) {
        debugPrint('search_read response is ${response.data}', wrapWidth: 1024);
        setState(() {
          this.response = 'Search Read: ${response.data}';
        });
      } else {
        print(
            'response failed with ${response.statusCode}:${response.statusMessage}');
      }
    } catch (e) {
      print(e);
    }
  }
}
