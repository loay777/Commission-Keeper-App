import 'dart:async';
import 'package:calculate_commission/DB/ComissionModel.dart';
import 'package:calculate_commission/DB/Database.dart';
class CommissionBloc {
  final _commissionController = StreamController<List<Commission>>.broadcast();

  get commissions => _commissionController.stream;

  dispose() {
    _commissionController.close();
  }

  getCommissions() async {
    _commissionController.sink.add(await DBProvider.db.getAllCommissions());
  }

  CommissionBloc() {
    getCommissions();
  }

  delete(int id) {
    DBProvider.db.deleteCommission(id);
    getCommissions();
  }

  add(Commission commission) {
    DBProvider.db.newCommission(commission);
    getCommissions();
  }
}