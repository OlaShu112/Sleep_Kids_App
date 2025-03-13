import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';  // CORS support

// Define the database connection
var connection = PostgreSQLConnection(
  'localhost', // host
  5432,        // port
  'database',  // database name
  username: 'your_username',
  password: 'your_password',
);


void main() async {
  // Establish connection to the database
  await connection.open();
  print('Database connection established');

  final app = Router();

  // Enable CORS (important for frontend communication)
  var handler = Pipeline()
      .addMiddleware(logRequests()) // Logs incoming requests for debugging
      .addMiddleware(corsHeaders()) // Enable CORS headers
      .addHandler(app.call);

  // Define API routes
  app.get('/', (Request request) {
    return Response.ok('Sleep Kids Backend is Running!');
  });

  // Hardcoded menu items for now
  app.get('/menu', (Request request) {
    final menuItems = [
      {'id': 1, 'name': 'About Us'},
      {'id': 2, 'name': 'Contact Us'},
      {'id': 3, 'name': 'Other Pages'},
      {'id': 4, 'name': 'Dashboard'},
    ];
    // Return menu items as JSON response
    return Response.ok(
        menuItems.toString(),
        headers: {'Content-Type': 'application/json'}
    );
  });

  // Example route to query users from the database
  app.get('/users', (Request request) async {
    try {
      List<List<dynamic>> results = await connection.query('SELECT * FROM users');
      // Transforming the result into a more readable format before returning
      final users = results.map((row) => {
        'id': row[0],
        'name': row[1],
        'email': row[2]
      }).toList();
      return Response.ok(
          users.toString(),
          headers: {'Content-Type': 'application/json'}
      );
    } catch (e) {
      return Response.internalServerError(
          body: 'Error fetching users: $e',
          headers: {'Content-Type': 'text/plain'}
      );
    }
  });

  // Start the server on port 8080
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('✅ Sleep Kids Backend running on http://${server.address.host}:${server.port}');
}
