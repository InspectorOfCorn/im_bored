import 'dart:developer';
import 'package:im_bored/dbHelper/const.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDB {
  static var db, userCollection;
  static connect() async {
    db = await Db.create(MONGO_CONN_URL);
    await db.open();
    inspect(db);
    userCollection = db.collection(USER_COLLECTION);
  }
}