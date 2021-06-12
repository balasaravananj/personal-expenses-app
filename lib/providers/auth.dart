import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;


import '../models/http_exception.dart';

class Auth with ChangeNotifier{
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;


bool get isAuth {
  return token !=null ;
}
  String get token{
  if(_token!=null&&_expiryDate !=null && _expiryDate.isAfter(DateTime.now())){
    return _token;
  }
  return null;
  }

  String get userId{
    return _userId;
  }



  Future<void> signup(String email,String password) async{
    final url=Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=[API_KEY]');
    try{
      final response = await http.post(url,body: json.encode({
        'email':email,
        'password':password,
        'returnSecureToken':true,
      }));
      final responseData=json.decode(response.body);
      if(responseData['error']!=null){
        throw HttpException(responseData['error']['message']);
      }
      _token=responseData['idToken'];
      _userId=responseData['localId'];
      _expiryDate=DateTime.now().add(Duration(seconds:int.parse(responseData['expiresIn'])));
      _autoLogout();
      notifyListeners();
    }catch(error){
      throw error;
    }
  }
  Future<void> login(String email,String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=[API_KEY]');
    try {
      final response = await http.post(url, body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token=responseData['idToken'];
      _userId=responseData['localId'];
      _expiryDate=DateTime.now().add(Duration(seconds:int.parse(responseData['expiresIn'])));
      _autoLogout();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> logOut() async {
    _token=null;
    _userId=null;
    _expiryDate=null;
    if(_authTimer!=null){
      _authTimer.cancel();
      _authTimer=null;
    }
    notifyListeners();
  }
 void _autoLogout(){
  if(_authTimer!=null){
    _authTimer.cancel();
  }
  final duration=_expiryDate.difference(DateTime.now()).inSeconds;
  _authTimer=Timer(Duration(seconds: duration) ,logOut);
 }
}