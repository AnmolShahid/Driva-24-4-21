import 'dart:async';


abstract class DBAuth {
  Future<String> registration(String name,String email, String password,String phone);

}

class DbAuth implements DBAuth {
  @override
  Future<String> registration(String name, String email, String password, String phone) {
   
  }

}