class Params {
  var login = '';
  var password = '';
  var db = '';

  Params();

  Params.fromJsonMap(Map<String, dynamic> map)
      : login = map['login'] ?? '',
        password = map['password'] ?? '',
        db = map['db'] ?? '';

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['login'] = login;
    data['password'] = password;
    data['db'] = db;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Params &&
          runtimeType == other.runtimeType &&
          login == other.login &&
          password == other.password &&
          db == other.db;

  @override
  int get hashCode => login.hashCode ^ password.hashCode ^ db.hashCode;

  @override
  String toString() {
    return 'Params{login: $login, password: $password, db: $db}';
  }
}
