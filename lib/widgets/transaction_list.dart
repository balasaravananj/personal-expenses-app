import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_expense_app/providers/transactions.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';

class TransactionList extends StatefulWidget {



  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {

  void delTransaction(String id){
    showDialog(context: context, builder: (ctx)=>AlertDialog(
      title: Text('Are you sure?'),
      content: Text('Do you really want to delete this ?'),
      actions: [
        FlatButton(onPressed: (){
          Navigator.of(ctx).pop();
        }, child: Text('No')),
        FlatButton(onPressed: ()async{
          try{
            Navigator.of(ctx).pop();
             await Provider.of<Transactions>(context,listen: false).delTransaction(id);
          }catch(error){
            print(error);
          }
        }, child: Text('Yes')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {

    final userTransactions = Provider.of<Transactions>(context,listen: false).userTransactions;


    return  userTransactions.isEmpty ? LayoutBuilder(builder: (context,constrains){
      return Column(
        children: [
          Text('No transactions yet!', style: Theme.of(context).textTheme.title,),
          SizedBox(
              height: 20
          ),
          Container(
              height: constrains.maxHeight* 0.6,
              child: Image.asset('assets/images/waiting.png', fit: BoxFit.cover,)),
        ],
      );
    }) :ListView.builder(
          itemBuilder: (ctx,index){
            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8,horizontal: 5),
              child: ListTile(
                leading: CircleAvatar(radius: 30,
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: FittedBox(
                    child: Text('₹${userTransactions[index].amount.toStringAsFixed(2)}'
                    ),
                  ),
                ),
                ),
                title: Text(userTransactions[index].title ,style: Theme.of(context).textTheme.title,),
                subtitle: Text(DateFormat.yMMMd().format(userTransactions[index].date),),
                trailing:MediaQuery.of(context).size.width > 460 ?
                    FlatButton.icon(
                      icon:Icon(Icons.delete) ,
                      textColor: Theme.of(context).errorColor,
                      label: Text('Delete'),
                      onPressed:()=>delTransaction(userTransactions[index].id),
                    ): IconButton(
                  icon: Icon(Icons.delete),
                  color: Theme.of(context).errorColor,
                  onPressed: ()=>delTransaction(userTransactions[index].id),),
              ),
            );
          },
          itemCount: userTransactions.length,
    );
  }
}
