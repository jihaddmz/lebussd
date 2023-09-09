import 'package:lebussd/models/model_purchase_history.dart';
import 'package:lebussd/singleton.dart';
import 'package:sqflite/sqflite.dart';

class SqliteActions {
  Future<void> createPurchaseHistoryTable(Database db) async {
    await db.execute(
        "create table purchase_history (id integer primary key, bundle double, price double, date text, color text, phoneNumber text)");
  }

  Future<void> insertPurchaseHistory(
      ModelPurchaseHistory modelPurchaseHistory) async {
    int maxID = await getMaxIdOfPurchasesHistory();
    await Singleton().databaseSqlite.insert(
        "purchase_history", modelPurchaseHistory.toMap(maxID + 1),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ModelPurchaseHistory>> getAllPurchasesHistory() async {
    final List<Map<String, dynamic>> listOfRecords =
        await Singleton().databaseSqlite.query("purchase_history");
    return List.generate(listOfRecords.length, (index) {
      return ModelPurchaseHistory(
          id: listOfRecords[index]['id'],
          bundle: listOfRecords[index]['bundle'],
          price: listOfRecords[index]['price'],
          date: listOfRecords[index]['date'],
          color: listOfRecords[index]['color'],
          phoneNumber: listOfRecords[index]['phoneNumber']);
    });
  }

  Future<int> getMaxIdOfPurchasesHistory() async {
    final result = await Singleton()
        .databaseSqlite
        .rawQuery('SELECT MAX(id) as max_id FROM purchase_history');
    if (result.isEmpty || result.first['max_id'] == null) {
      // table is empty
      return 0;
    } else {
      // there are previous records
      return result.first['max_id'] as int;
    }
  }

  Future<void> deleteAllPurchasesHistory() async {
    await Singleton()
        .databaseSqlite
        .rawDelete('delete from purchase_history');
  }
}
