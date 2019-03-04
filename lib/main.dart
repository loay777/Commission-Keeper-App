import 'package:flutter/material.dart';
import 'MyCommissionsScreen.dart';
import 'dart:async';
import 'package:calculate_commission/DB/ComissionModel.dart';
import 'package:calculate_commission/BLOCS/DatabaseBloc.dart';
import 'package:date_format/date_format.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainScreen(),
    theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.indigoAccent,
        primaryColor: Colors.indigo),
  ));
}

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  var _formKey = GlobalKey<FormState>();
  final double _minimumPadding = 5.0;
  String commission = "";
  TextEditingController _dealValueController = TextEditingController();
  TextEditingController _percentageController = TextEditingController();
  TextEditingController _commissionTitleController = TextEditingController();
  final bloc = CommissionBloc();

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveCommissionDialog();
        },
        child: Icon(
          Icons.note_add,
          color: Colors.white,
          size: 35,
        ),
        tooltip: 'Save Commission',
//
        elevation: 6.0,
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
                child: CircleAvatar(
              child: Icon(Icons.account_balance_wallet,
                  size: 60.0, color: Colors.white),
              backgroundColor: Colors.indigo,
            )),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyCommissionsPage()));
              },
              title: Text('My Commessions'),
              leading: CircleAvatar(child: Icon(Icons.monetization_on),),
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Simple Commision Calculator'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
            padding: EdgeInsets.all(_minimumPadding * 2),
            child: ListView(
              children: <Widget>[
                getImageAsset(),
                Padding(
                    padding: EdgeInsets.only(
                        top: _minimumPadding, bottom: _minimumPadding),
                    child: TextFormField(
                      controller: _dealValueController,
                      style: textStyle,
                      keyboardType: TextInputType.number,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter deal value';
                        }
                        if (double.tryParse(value) == null) {
                          //if the input is not a number
                          return 'Please enter numbers only';
                        }
                      },
                      decoration: InputDecoration(
                          labelText: 'Deal Value',
                          hintText: 'Enter Value e.g. 120000',
                          labelStyle: textStyle,
                          hintStyle: textStyle,
                          errorStyle: TextStyle(color: Colors.red),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    )),
                Padding(
                    padding: EdgeInsets.only(
                        top: _minimumPadding, bottom: _minimumPadding),
                    child: TextFormField(
                      controller: _percentageController,
                      style: textStyle,
                      keyboardType: TextInputType.number,
                      validator: (String value) {
                        if (value.isEmpty || double.tryParse(value) == null) {
                          return 'Please enter valid commission percentage';
                        }
                        if (double.parse(value) > 100) {
                          return 'Commission percentage cant be more than 100';
                        }
                      },
                      decoration: InputDecoration(
                          labelText: 'Rate of Commission',
                          hintText: 'In percent',
                          labelStyle: textStyle,
                          hintStyle: textStyle,
                          errorStyle: TextStyle(color: Colors.red),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    )),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: _minimumPadding, top: _minimumPadding),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                            elevation: 9.0,
                            shape: StadiumBorder(),
                            color: Theme.of(context).accentColor,
                            child: Text('Calculate', textScaleFactor: 1.5),
                            onPressed: () {
                              setState(() {
                                if (_formKey.currentState.validate()) {
                                  commission = _commissionCalculator();
                                }
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RaisedButton(
                            splashColor: Colors.red,
                            shape: StadiumBorder(
                              side: BorderSide(color: Colors.red, width: 2.0),
                            ),
                            color: Theme.of(context).primaryColorLight,
                            child: Text(
                              'Reset',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              setState(() {
                                _reset();
                              });
                            },
                          ),
                        ),
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.all(_minimumPadding * 1),
                    child: Card(
                        child: Padding(
                      padding: EdgeInsets.all(_minimumPadding * 2),
                      child: Text(
                        'Comission = $commission ',
                        style: TextStyle(fontSize: 28.0, color: Colors.white),
                      ),
                    )))
              ],
            )),
      ),
    );
  }

  Widget getImageAsset() {
    AssetImage assetImage = AssetImage('images/money.png');
    Image image = Image(
      image: assetImage,
      width: 100.0,
      height: 100.0,
    );

    return Container(
      child: image,
      margin: EdgeInsets.all(_minimumPadding * 3),
    );
  }

  String _commissionCalculator() {
    double _dealValueInput = double.parse(_dealValueController.text);
    double _percentageInput = double.parse(_percentageController.text);
    String commission =
        (_dealValueInput * (_percentageInput / 100)).toStringAsFixed(2);
    return commission;
  }

  void _reset() {
    commission = '';
    _dealValueController.clear();
    _percentageController.clear();
  }

  void _saveCommission() async {
    // saves Commission to DB
    int result;
    var insertionDate = formatDate(DateTime.now(), [d, '-', M, '-', yyyy]);
    Commission newCommission = Commission(
        commissionValue: commission,
        commissionTitle: _commissionTitleController.text,
        date: insertionDate.toString());
    result = await bloc.add(newCommission);
    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Commission Saved Successfully');
      _reset();
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Commission');
    }
  }

  //Dialog form that pops up when save button is pressed
  void _saveCommissionDialog() {
    var alert = AlertDialog(
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _commissionTitleController,
              autofocus: true,
              decoration: InputDecoration(
                  labelText: "Commission Title:",
                  hintText: "e.g. my first deal",
                  icon: Icon(Icons.note_add)),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () {
              _saveCommission();
              // This step to hide the alert add item window after clicked save
              Navigator.pop(context);
              _commissionTitleController.clear();
            },
            child: Text("Save")),
        FlatButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel"))
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
