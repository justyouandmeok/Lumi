import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

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
    final users = FakeFirestore.instance._cols['users'] ?? {};
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
  CollectionRef(this._db, this.name);
  final FakeFirestore _db;
  final String name;

  DocumentRef doc([String? id]) =>
      DocumentRef(_db, name, id ?? DateTime.now().millisecondsSinceEpoch.toString());

  QueryRef where(String field, {dynamic isEqualTo, dynamic isGreaterThanOrEqualTo}) {
    return QueryRef(_db, name, field, isEqualTo, isGreaterThanOrEqualTo);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> snapshots() async* {
    yield _snap();
    yield* _db._changes.map((_) => _snap());
  }

  Future<QuerySnapshot<Map<String, dynamic>>> get() async => _snap();

  QuerySnapshot<Map<String, dynamic>> _snap() {
    final col = _db._cols[name] ?? {};
    final docs = col.entries
        .map((e) => QueryDocumentSnapshot(e.key, Map<String, dynamic>.from(e.value)))
        .toList();
    docs.sort((a, b) {
      final da = a.data()?['datePublished'];
      final db = b.data()?['datePublished'];
      if (da is DateTime && db is DateTime) return db.compareTo(da);
      return 0;
    });
    return QuerySnapshot(docs);
  }
}

class QueryRef {
  QueryRef(this._db, this.name, this.field, this.isEqualTo, this.gte);
  final FakeFirestore _db;
  final String name;
  final String field;
  final dynamic isEqualTo;
  final dynamic gte;

  Future<QuerySnapshot<Map<String, dynamic>>> get() async {
    final col = _db._cols[name] ?? {};
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
  DocumentRef(this._db, this.col, this.id);
  final FakeFirestore _db;
  final String col;
  final String id;

  CollectionRef collection(String sub) => CollectionRef(_db, '$col/$id/$sub');

  Future<void> set(Map<String, dynamic> data) async {
    _db._cols.putIfAbsent(col, () => {});
    _db._cols[col]![id] = Map<String, dynamic>.from(data);
    await _db._save();
    _db._changes.add(null);
  }

  Future<void> update(Map<String, dynamic> patch) async {
    _db._cols.putIfAbsent(col, () => {});
    final cur = Map<String, dynamic>.from(_db._cols[col]![id] ?? {});
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
    _db._cols[col]![id] = cur;
    await _db._save();
    _db._changes.add(null);
  }

  Future<DocumentSnapshot> get() async {
    final data = _db._cols[col]?[id];
    return DocumentSnapshot(
      id,
      data == null ? null : Map<String, dynamic>.from(data),
    );
  }

  Future<void> delete() async {
    _db._cols[col]?.remove(id);
    await _db._save();
    _db._changes.add(null);
  }
}

class FakeFirestore {
  FakeFirestore._();
  static final instance = FakeFirestore._();
  final Map<String, Map<String, Map<String, dynamic>>> _cols = {};
  final _changes = StreamController<void>.broadcast();

  CollectionRef collection(String name) => CollectionRef(this, name);

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('ff.db');
    if (raw == null) return;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    decoded.forEach((col, docs) {
      _cols[col] = {};
      (docs as Map<String, dynamic>).forEach((id, data) {
        final map = Map<String, dynamic>.from(data as Map);
        if (map['datePublished'] is String) {
          map['datePublished'] = DateTime.tryParse(map['datePublished']);
        }
        _cols[col]![id] = map;
      });
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    final out = <String, dynamic>{};
    _cols.forEach((col, docs) {
      out[col] = {};
      docs.forEach((id, data) {
        final copy = Map<String, dynamic>.from(data);
        if (copy['datePublished'] is DateTime) {
          copy['datePublished'] = (copy['datePublished'] as DateTime).toIso8601String();
        }
        out[col][id] = copy;
      });
    });
    await p.setString('ff.db', jsonEncode(out));
  }
}

class FirebaseFirestore {
  static FakeFirestore get instance => FakeFirestore.instance;
}

class Reference {
  Reference(this.path);
  final String path;
  Reference child(String c) => Reference('$path/$c');
  UploadTask putData(Uint8List file) => UploadTask(path, file);
}

class UploadTask {
  UploadTask(this.path, this.bytes);
  final String path;
  final Uint8List bytes;
}

class TaskSnapshot {
  TaskSnapshot(this.ref);
  final _SnapRef ref;
}

class _SnapRef {
  _SnapRef(this.url);
  final String url;
  Future<String> getDownloadURL() async => url;
}

class FirebaseStorage {
  FirebaseStorage._();
  static final instance = FirebaseStorage._();
  Reference ref() => Reference('local');
}

extension UploadTaskAwait on UploadTask {
  Future<TaskSnapshot> get completed async {
    final dir = Directory.systemTemp.createTempSync('lumi');
    final f = File('${dir.path}/${path.replaceAll('/', '_')}.jpg');
    await f.writeAsBytes(bytes);
    return TaskSnapshot(_SnapRef('file://${f.path}'));
  }
}

Future<TaskSnapshot> waitUpload(UploadTask t) => t.completed;

class Firebase {
  static Future<void> initializeApp({dynamic options}) async {}
}
