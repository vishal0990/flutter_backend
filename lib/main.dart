import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'database.dart';

void main() async {
  final db = AppDatabase();

  final router = Router()
    // Register endpoint
    ..post('/register', (Request request) async {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      final username = data['username'];
      final password = data['password'];

      // Check if the username is already taken
      final existingUser = await db.getUser(username);
      if (existingUser != null) {
        return Response(400, body: 'Username already taken');
      }

      // Create a new user
      await db.createUser(username, password);
      return Response.ok('User registered successfully');
    })

    // Login endpoint
    ..post('/login', (Request request) async {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      final username = data['username'];
      final password = data['password'];

      // Fetch the user by username
      final user = await db.getUser(username);
      if (user == null) {
        return Response(404, body: 'User not found');
      }

      // Check the password
      final passwordHash = db.hashPassword(password);
      if (user.passwordHash == passwordHash) {
        return Response.ok('Login successful');
      } else {
        return Response(401, body: 'Invalid password');
      }
    });

  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(router);

  // Start the server
  final server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}
