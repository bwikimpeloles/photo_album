import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  late FirebaseFirestore firestore;
  initiliase() {
    firestore = FirebaseFirestore.instance;
  }

  Future<void> create(
      String description, String location, String datentime) async {
    try {
      await firestore.collection("details").add({
        'description': description,
        'location': location,
        'datentime': datentime,
        'datetime': FieldValue.serverTimestamp(),
        'url': "",
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await firestore.collection("details").doc(id).delete();
    } catch (e) {
      print(e);
    }
  }

  Future<List> read() async {
    QuerySnapshot querySnapshot;
    List docs = [];
    try {
      querySnapshot =
          await firestore.collection('details').orderBy('datetime').get();
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          Map a = {
            "id": doc.id,
            "description": doc['description'],
            "location": doc["location"],
            "url": doc["url"],
            "datentime": doc["datentime"],
          };
          docs.add(a);
        }
        return docs;
      }
    } catch (e) {
      print(e);
    }
    return read();
  }

  Future<List> read2(String? url) async {
    QuerySnapshot querySnapshot;
    List docs = [];
    try {
      querySnapshot = await firestore
          .collection('details')
          .where("url", isEqualTo: url)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          Map a = {
            "id": doc.id,
            "description": doc['description'],
            "location": doc["location"],
            "url": doc["url"],
            "datentime": doc["datentime"],
          };
          docs.add(a);
        }
        return docs;
      }
    } catch (e) {
      print(e);
    }
    return read2(url);
  }

  Future<void> update(
      String id, String description, String location, String datentime) async {
    try {
      await firestore.collection("details").doc(id).update({
        'description': description,
        'location': location,
        'datentime': datentime
      });
    } catch (e) {
      print(e);
    }
  }
}
