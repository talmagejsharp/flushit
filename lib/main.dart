import 'package:flutter/material.dart';
import 'DioService.dart';
import 'signup_page.dart';
import 'login_page.dart';
import 'home.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flushit',
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Flushit'),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(title: 'Flushit'), // Define your main page
        '/signup': (context) => SignUp(),
        '/login': (context) => Login(),// Define the login page route
        '/home': (context) => Home(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DioService dioService = DioService();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                width: 125,
                child:
                    Image.asset('assets/FlushitIcon.png')),
            SizedBox(height: 10.0),
            Text(
              'Flushit',
              style: TextStyle(
                color: Colors.deepPurple,
                letterSpacing: 2.0,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'We Go There',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 25),
            Container(
              width: 300,
              child: Text(
                textAlign: TextAlign.center,
                'Building accountability for one of life\'s most moving experiences',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,

                ),
              ),
            ),
            SizedBox(height: 250),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                  print('SIGN UP PRESSED');
                },
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStatePropertyAll<Color>(Colors.deepPurple),
                  overlayColor: MaterialStatePropertyAll<Color>(Colors.deepPurpleAccent),

                ),

                child: Container(
                  width: 150,
                  child: Center(
                    child: Text(
                      'SIGN UP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                )
            ),
            SizedBox(height: 15),
            OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                  print('LOG IN PRESSED');
                },
                child: Container(
                  width: 150,
                  child: Center(
                    child: Text(
                      'LOG IN',
                      style: TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontSize: 15,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                )
            ),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headlineMedium,
            // ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
