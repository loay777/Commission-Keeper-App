import 'package:flutter/material.dart';
import 'package:calculate_commission/BLOCS/DatabaseBloc.dart';
import 'DB/ComissionModel.dart';

//Saved Commissions UI
class MyCommissionsPage extends StatefulWidget {
  @override
  _MyCommissionsPageState createState() => _MyCommissionsPageState();
}

class _MyCommissionsPageState extends State<MyCommissionsPage> {
  final bloc = CommissionBloc();

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: <Widget>[
          Hero(tag: 'Money', child: Icon(Icons.monetization_on)),
          Expanded(child: Text("   My Commissions"))
        ]),
      ),
      body: StreamBuilder<List<Commission>>(
        stream: bloc.commissions,
        builder:
            (BuildContext context, AsyncSnapshot<List<Commission>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Commission item = snapshot.data[index];
                return Dismissible(
                    direction: DismissDirection.endToStart,
                    key: UniqueKey(),
                    background: Container(
                        color: Colors.red,
                        child: Align(
                            alignment: FractionalOffset(0.9, 0.5),
                            child: Icon(
                              Icons.delete,
                            ))),
                    onDismissed: (direction) {
                      bloc.delete(item.id);
                    },
                    child: GestureDetector(
                        onTap: () {
                          _commissionDetailsDialog(item.commissionTitle,
                              item.commissionValue, item.date);
                        },
                        child: Card(
                          color: Colors.white30,
                          elevation: 2.0,
                          child: ListTile(
                            title: Text(item.commissionTitle),
                            leading: Icon(Icons.monetization_on),
                            subtitle: Text(item.commissionValue),
                            trailing: Text("Date: " + item.date),
                          ),
                        )));
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void _commissionDetailsDialog(String title, String value, String date) {
    AlertDialog alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.indigo, style: BorderStyle.solid)),
      title: Text(
        title,
        style: TextStyle(color: Colors.indigo),
      ),
      content: Text('Commission: ' + value + '\nDate:' + date),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
