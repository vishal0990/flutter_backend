import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // For utf8 encoding
import 'dart:io';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Define the Users table
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().withLength(min: 3, max: 20)();
  TextColumn get passwordHash => text()(); // Store hashed passwords
}

@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(NativeDatabase(File(p.join(Directory.current.path, 'app.db'))));

  @override
  int get schemaVersion => 1;

  Future<int> createUser(String username, String password) {
    final passwordHash = hashPassword(password);
    return into(users).insert(UsersCompanion(
      username: Value(username),
      passwordHash: Value(passwordHash),
    ));
  }

  Future<User?> getUser(String username) {
    return (select(users)..where((u) => u.username.equals(username))).getSingleOrNull();
  }

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
