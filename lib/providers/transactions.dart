import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:personal_expense_app/models/http_exception.dart';

import '../models/transaction.dart';

class Transactions with ChangeNotifier{
  final _userToken;
  final _userId;
  List<Transaction> _userTransactions;

  Transactions(this._userId,this._userToken,this._userTransactions);

  List<Transaction> get userTransactions{
    return [..._userTransactions];
  }

  Future<void> getAndSetTransactions() async {
    final url = Uri.parse('Your Database Url');
    try {
      final response = await http.get(url);
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      List<Transaction> loadedTx = [];
      if(responseData==null||responseData['error']!=null){
        print('null check');
        return;
      }
      responseData.forEach((txId, tx) {
        return loadedTx.add(Transaction(
            id: txId,
            title: tx['title'],
            amount: tx['amount'],
            date: DateTime.parse(tx['date']))
        );
      });
      _userTransactions = loadedTx;
      notifyListeners();
    }
    catch(error){
      throw error;
    }
  }

  Future<void> addNewTransaction(String txTitle, double txAmount,DateTime txDate) async {
    final url = Uri.parse('Your Database Url');

    try{
        final response =await http.post(url,body:json.encode({
          'title':txTitle,
          'amount':txAmount,
          'date':txDate.toIso8601String(),
        }),
        );
       final newTransaction = Transaction(
           id: json.decode(response.body)['name'],
           title: txTitle,
           amount: txAmount,
           date: txDate);
       _userTransactions.add(newTransaction);
       notifyListeners();
    }catch(error){
      throw error;
    }
  }
  
  Future<void> delTransaction(String id) async{
    final txIndex=_userTransactions.indexWhere((tx) =>tx.id==id);
    print(txIndex);
    var _existingTx=_userTransactions[txIndex];
    _userTransactions.removeAt(txIndex);
    notifyListeners();
    final url = Uri.parse('Your Database Url');
    final response = await http.delete(url);
    if(response.statusCode>=400) {
      _userTransactions.insert(txIndex, _existingTx);
      notifyListeners();
    }
      _existingTx = null;
  }

}