import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert'; // Add this import


void main() async {
  // Create a router for handling routes
  final router = Router();

  // Define a basic GET route
  router.get('/', (Request request) {
    return Response.ok('Hello, from Dart Backend!');
  });

  // Another route that returns JSON data
router.get('/user/<id>', (Request request, String id) {
  final user = {
    'id': id,
    'name': 'John Doe',
    'email': 'john.doe@example.com',
  };
  // Return a JSON string
  return Response.ok(jsonEncode(user), headers: {'Content-Type': 'application/json'});
});

  // Start the server
  final server = await shelf_io.serve(
    router,
    InternetAddress.anyIPv4,
    8080,
  );

  print('Server is running on http://localhost:8080');
}
