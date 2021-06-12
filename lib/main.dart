import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personal_expense_app/screens/auth_screen.dart';
import 'package:personal_expense_app/providers/auth.dart';
import 'package:personal_expense_app/providers/transactions.dart';
import 'package:personal_expense_app/screens/splash_screen.dart';
import 'package:personal_expense_app/widgets/chart.dart';
import 'package:personal_expense_app/widgets/new_transactions.dart';
import 'package:personal_expense_app/widgets/transaction_list.dart';
import 'package:provider/provider.dart';

import 'models/transaction.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
        create: (ctx)=>Auth(),),
        ChangeNotifierProxyProvider<Auth,Transactions>(
            create: (ctx)=>Transactions(null,null,[]),
          update: (ctx,auth,previousTx)=>Transactions(auth.userId,auth.token,previousTx==null?[]:previousTx.userTransactions),
        )
      ],
        child: Consumer<Auth>(
          builder: (ctx,auth,_) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Personal Expenses',
              theme: ThemeData(
                  primarySwatch: Colors.purple,
                  accentColor: Colors.amber,
                  fontFamily: 'Quicksand',
                  errorColor: Colors.red,
                  textTheme: ThemeData
                      .light()
                      .textTheme
                      .copyWith(
                    title: TextStyle(fontFamily: 'OpenSans',
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    button: TextStyle(color: Colors.white),
                  ),
                  appBarTheme: AppBarTheme(
                      textTheme: ThemeData
                          .light()
                          .textTheme
                          .copyWith(
                        title: TextStyle(fontFamily: 'OpenSans',
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ))
              ),
              home:auth.isAuth? MyHomePage():AuthScreen(),
            );
          }
        ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  //String titleInput;
  //String amountInput;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Transaction> _userTransactions = [];
  var _isInit = true;
  var _isLoading=false;


  @override
  void didChangeDependencies(){
    if(_isInit){
      setState(() {
        _isLoading=true;
      });
      Provider.of<Transactions>(context).getAndSetTransactions().then((_){
        setState(() {
          _isLoading=false;
        });
      });
      _isInit=false;
    }
    super.didChangeDependencies();
  }
  bool _showChart = false;
  void _showAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            child: NewTransaction(),
            behavior: HitTestBehavior.opaque,
          );
        });
  }
  List<Transaction> get getRecentTransaction{
    return _userTransactions.where((tx){
      return tx.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  void showWarnDialog(BuildContext context){
    showDialog(context: context, builder:(ctx)=>AlertDialog(
      title: Text("Are you sure?"),
      content: Text('Do you want to logout from this app?'),
      actions: [
        FlatButton(onPressed: (){
          Navigator.of(ctx).pop();
        }, child: Text('No')),
        FlatButton(onPressed: (){
          Navigator.of(ctx).pop();
          Navigator.of(ctx).pushReplacementNamed('/');
          Provider.of<Auth>(context,listen: false).logOut();
        }, child: Text('Yes')),
      ],
    ));

  }

  @override
  Widget build(BuildContext context) {
    _userTransactions=Provider.of<Transactions>(context,listen: false).userTransactions;
    final isLandscape = MediaQuery.of(context).orientation==Orientation.landscape;

    final appBar =AppBar(
      title: Text('Personal Expenses'),
      actions: [
        DropdownButton(
          underline: Container(),
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).primaryIconTheme.color,
          ),
          items: [
            DropdownMenuItem(
              child:Container(
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text('Add Expense'),
                  ],
                ),
              ),
              value: 'Add Expense',
            ),
            DropdownMenuItem(
              child:Container(
                child: Row(
                  children: [
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text('Logout'),
                  ],
                ),
              ),
              value: 'logout',
            )
          ],
          onChanged: (itemIdentifier){
            if(itemIdentifier=='logout'){
              showWarnDialog(context);
            }
            if(itemIdentifier=='Add Expense'){
              _showAddNewTransaction(context);
            }
          },
        )
      ],
    );
    return Scaffold(
      appBar: appBar,
      body:_isLoading? SplashScreen():SingleChildScrollView(
        child:isLandscape ? Column(
           crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Show Chart'),
                  Switch(value: _showChart, onChanged: (val){
                    setState(() {
                      _showChart=val;
                    });

                  }),
                ],
              ),
              _showChart?Container(
                height: (MediaQuery.of(context).size.height-
                appBar.preferredSize.height-MediaQuery.of(context).padding.top )*0.7,
                  child: Chart(getRecentTransaction),
              ):
              Container(
                height: (MediaQuery.of(context).size.height-
                    appBar.preferredSize.height-MediaQuery.of(context).padding.top )*0.7,
                  child: TransactionList()
                 ),
                 ],
              ):Column(
                     children: [
                       Container(
                         height: (MediaQuery.of(context).size.height-
                             appBar.preferredSize.height-MediaQuery.of(context).padding.top )*0.3,
                         child: Chart(getRecentTransaction),
                       ),
                       Container(
                           height: (MediaQuery.of(context).size.height-
                               appBar.preferredSize.height-MediaQuery.of(context).padding.top )*0.7,
                           child: TransactionList()
                       ),
                     ],
        ),
           ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => _showAddNewTransaction(context),
      ),
    );
  }
}
