
import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FieldValue {
  FieldValue._(this.op, this.values);
  final String op;
  final List values;
  static FieldValue arrayUnion(List v) => FieldValue._('union', v);
  static FieldValue arrayRemove(List v) => FieldValue._('remove', v);
}

class User {
  User({required this.uid, required this.email});
  final String uid;
  final String email;
}

class UserCredential {
  UserCredential(this.user);
  final User user;
}

class DocumentSnapshot {
  DocumentSnapshot(this.id, this._data);
  final String id;
  final Map<String, dynamic>? _data;
  Map<String, dynamic>? data() => _data;
  dynamic operator [](String key) => _data?[key];
  bool get exists => _data != null;
}

class QueryDocumentSnapshot extends DocumentSnapshot {
  QueryDocumentSnapshot(super.id, super.data);
}

class QuerySnapshot<T extends Object?> {
  QuerySnapshot(this.docs);
  final List<QueryDocumentSnapshot> docs;
}

class FirebaseAuth {
  FirebaseAuth._();
  static final FirebaseAuth instance = FirebaseAuth._();

  User? currentUser;
  final _controller = StreamController<User?>.broadcast();

  Stream<User?> authStateChanges() async* {
    yield currentUser;
    yield* _controller.stream;
  }

  Future<void> restore() async {
    final p = await SharedPreferences.getInstance();
    final uid = p.getString('ff.uid');
    final email = p.getString('ff.email');
    if (uid != null && email != null) {
      currentUser = User(uid: uid, email: email);
      _controller.add(currentUser);
    }
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    if (currentUser == null) {
      await p.remove('ff.uid');
      await p.remove('ff.email');
    } else {
      await p.setString('ff.uid', currentUser!.uid);
      await p.setString('ff.email', currentUser!.email);
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    currentUser = User(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
    );
    await _persist();
    _controller.add(currentUser);
    return UserCredential(currentUser!);
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final users = FirebaseFirestore.instance.cols['users'] ?? {};
    String? uid;
    users.forEach((id, user) {
      if (user['email'] == email) uid = id;
    });
    uid ??= DateTime.now().millisecondsSinceEpoch.toString();
    currentUser = User(uid: uid!, email: email);
    await _persist();
    _controller.add(currentUser);
    return UserCredential(currentUser!);
  }

  Future<void> signOut() async {
    currentUser = null;
    await _persist();
    _controller.add(null);
  }
}

class CollectionRef {
  CollectionRef(this.db, this.name);
  final FirebaseFirestore db;
  final String name;

  DocumentRef doc([String? id]) => DocumentRef(
        db,
        name,
        id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      );

  CollectionRef orderBy(String field, {bool descending = false}) => this;

  CollectionRef where(
    String field, {
    dynamic isEqualTo,
    dynamic isGreaterThanOrEqualTo,
  }) {
    return QueryCollectionRef(
      db,
      name,
      field,
      isEqualTo,
      isGreaterThanOrEqualTo,
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> snapshots() async* {
    yield snap();
    yield* db.changes.stream.map((_) => snap());
  }

  Future<QuerySnapshot<Map<String, dynamic>>> get() async => snap();

  QuerySnapshot<Map<String, dynamic>> snap() {
    final col = db.cols[name] ?? {};
    final docs = col.entries
        .map((e) =>
            QueryDocumentSnapshot(e.key, Map<String, dynamic>.from(e.value)))
        .toList();
    docs.sort((a, b) {
      final da = a.data()?['datePublished'];
      final dbv = b.data()?['datePublished'];
      if (da is DateTime && dbv is DateTime) return dbv.compareTo(da);
      return 0;
    });
    return QuerySnapshot(docs);
  }
}

class QueryCollectionRef extends CollectionRef {
  QueryCollectionRef(
    super.db,
    super.name,
    this.field,
    this.isEqualTo,
    this.gte,
  );
  final String field;
  final dynamic isEqualTo;
  final dynamic gte;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get() async {
    final col = db.cols[name] ?? {};
    final docs = <QueryDocumentSnapshot>[];
    col.forEach((id, data) {
      final v = data[field];
      if (isEqualTo != null && v != isEqualTo) return;
      if (gte != null && v.toString().compareTo(gte.toString()) < 0) return;
      docs.add(QueryDocumentSnapshot(id, Map<String, dynamic>.from(data)));
    });
    return QuerySnapshot(docs);
  }
}

class DocumentRef {
  DocumentRef(this.db, this.col, this.id);
  final FirebaseFirestore db;
  final String col;
  final String id;

  CollectionRef collection(String sub) => CollectionRef(db, '$col/$id/$sub');

  Future<void> set(Map<String, dynamic> data) async {
    db.cols.putIfAbsent(col, () => {});
    db.cols[col]![id] = Map<String, dynamic>.from(data);
    await db.save();
    db.changes.add(null);
  }

  Future<void> update(Map<String, dynamic> patch) async {
    db.cols.putIfAbsent(col, () => {});
    final cur = Map<String, dynamic>.from(db.cols[col]![id] ?? {});
    patch.forEach((k, v) {
      if (v is FieldValue) {
        final list = List.from(cur[k] ?? []);
        if (v.op == 'union') {
          for (final x in v.values) {
            if (!list.contains(x)) list.add(x);
          }
        } else {
          list.removeWhere((e) => v.values.contains(e));
        }
        cur[k] = list;
      } else {
        cur[k] = v;
      }
    });
    db.cols[col]![id] = cur;
    await db.save();
    db.changes.add(null);
  }

  Future<DocumentSnapshot> get() async {
    final data = db.cols[col]?[id];
    return DocumentSnapshot(
      id,
      data == null ? null : Map<String, dynamic>.from(data),
    );
  }

  Future<void> delete() async {
    db.cols[col]?.remove(id);
    await db.save();
    db.changes.add(null);
  }
}

class FirebaseFirestore {
  FirebaseFirestore._();
  static final FirebaseFirestore instance = FirebaseFirestore._();

  final Map<String, Map<String, Map<String, dynamic>>> cols = {};
  final StreamController<void> changes = StreamController<void>.broadcast();

  CollectionRef collection(String name) => CollectionRef(this, name);

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('ff.db');
    if (raw == null) return;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    decoded.forEach((col, docs) {
      cols[col] = {};
      (docs as Map<String, dynamic>).forEach((id, data) {
        final map = Map<String, dynamic>.from(data as Map);
        if (map['datePublished'] is String) {
          map['datePublished'] = DateTime.tryParse(map['datePublished']);
        }
        cols[col]![id] = map;
      });
    });
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    final out = <String, dynamic>{};
    cols.forEach((col, docs) {
      out[col] = {};
      docs.forEach((id, data) {
        final copy = Map<String, dynamic>.from(data);
        if (copy['datePublished'] is DateTime) {
          copy['datePublished'] =
              (copy['datePublished'] as DateTime).toIso8601String();
        }
        out[col][id] = copy;
      });
    });
    await p.setString('ff.db', jsonEncode(out));
  }
}

class Firebase {
  static Future<void> initializeApp({Object? options}) async {}
}
