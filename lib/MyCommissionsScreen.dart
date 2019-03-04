import 'package:flutter/material.dart';
import 'package:calculate_commission/BLOCS/DatabaseBloc.dart';
import 'DB/ComissionModel.dart';
import 'dart:math' as math;

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
      appBar: AppBar(title: Text("My Commissions")),
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
                          child:Icon(
                          Icons.delete,
                          textDirection: TextDirection.rtl,
                        ))),
                    onDismissed: (direction) {
                      bloc.delete(item.id);
                    },
                    child: Card(
                      color: Colors.white30,
                      elevation: 2.0,
                      child: ListTile(
                        title: Text(item.commissionTitle),
                        leading: Text(item.id.toString()),
                        subtitle: Text(item.commissionValue),
                        trailing: Text("Date: " + item.date),
                      ),
                    ));
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
//      floatingActionButton: FloatingActionButton(
//        child: Icon(Icons.add),
//        onPressed: () async {
//          Commission rnd =
//              testCommissions[math.Random().nextInt(testCommissions.length)];
//          bloc.add(rnd);
//          await bloc.getCommissions();
//        },
//      ),
    );
  }
}
