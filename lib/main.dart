import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/sleep_provider.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/home/home_screen.dart';
import 'views/home/sleep_tracking_screen.dart';
import 'views/home/analytics_screen.dart';
import 'views/home/bedtime_stories_screen.dart';
import 'views/home/profile_screen.dart';
import 'views/home/goal_screen.dart';
import 'views/home/education_screen.dart';
import 'views/home/dashboard_screen.dart';
import 'views/home/sleep_goal_screen.dart' as sleep_goal;
import 'views/home/achievements_screen.dart';
import 'widgets/main_layout.dart';
//import 'package:sleep_kids_app/widgets/main_layout.dart';
//import 'package:sleep_kids_app/views/home/sleep_goal_screen.dart' as sleep_goal;
//import 'package:sleep_kids_app/views/home/achievements_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase differently for web and mobile
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDabNeTVkTt5tW0T8EtAB6yBAL6PJJEz7o",
        authDomain: "sleep-apps-efda6.firebaseapp.com",
        projectId: "sleep-apps-efda6",
        storageBucket: "sleep-apps-efda6.appspot.com",
        messagingSenderId: "275997062867",
        appId: "1:275997062867:web:477d257273ac42af110626",
        measurementId: "G-B354J4K5CS",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  print("✅ Firebase Initialized Successfully!");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => AuthProvider()), // ✅ Initialize AuthProvider
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => MainPage()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => SignUpScreen()),
      GoRoute(
          path: '/sleep-tracking',
          builder: (context, state) =>
              MainLayout(child: SleepTrackingScreen())),
      GoRoute(
          path: '/analytics',
          builder: (context, state) => MainLayout(child: AnalyticsScreen())),
      GoRoute(
          path: '/bedtime-stories',
          builder: (context, state) =>
              MainLayout(child: BedtimeStoriesScreen())),
      GoRoute(
          path: '/profile',
          builder: (context, state) => MainLayout(child: ProfileScreen())),
      GoRoute(
          path: '/goal',
          builder: (context, state) => MainLayout(child: GoalScreen())),
      GoRoute(
          path: '/education',
          builder: (context, state) => MainLayout(child: EducationScreen())),
      GoRoute(
          path: '/home',
          builder: (context, state) => MainLayout(child: HomeScreen())),
      GoRoute(
          path: '/dashboard', builder: (context, state) => DashboardScreen()),
      GoRoute(
          path: '/sleep-goals',
          builder: (context, state) =>
              MainLayout(child: sleep_goal.SleepGoalScreen())),
      GoRoute(
          path: '/achievement',
          builder: (context, state) => MainLayout(child: AchievementsScreen())),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => SleepProvider()),
      ],
      child: MaterialApp.router(
        title: 'Sleep Kids',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        routerConfig: _router,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String currentTime = '';
  bool showSleepKids = false;

  // Define the scaffold key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        currentTime = DateFormat('hh:mm a').format(DateTime.now());
      });
    }
    Future.delayed(Duration(seconds: 1), _updateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // use the scaffold key here
      drawer: CustomNavbar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/sleep_kids.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Text(
                'Image not found',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.menu, size: 36, color: Colors.white),
                    onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                currentTime,
                style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              if (showSleepKids)
                Text(
                  'Sleep Kids',
                  style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 20),
              Text(
                'Wake Up Easy with Sleep Kids',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Sleep Kids tracks and analyzes your sleep, waking you up at the most perfect time.',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Spacer(flex: 14),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.blue, // Blue color
                    fontWeight: FontWeight.bold, // Bold text
                    fontSize: 18, // Adjust the font size to make it larger
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomNavbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Menu',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
              ),
            ),
            ListTile(
                title: Text('About Us', style: TextStyle(color: Colors.white)),
                onTap: () => print('About Us')),
            ListTile(
                title:
                    Text('Contact Us', style: TextStyle(color: Colors.white)),
                onTap: () => print('Contact Us')),
            ListTile(
                title:
                    Text('Other Pages', style: TextStyle(color: Colors.white)),
                onTap: () => print('Other Pages')),
            ListTile(
                title: Text('Dashboard', style: TextStyle(color: Colors.white)),
                onTap: () => context.go('/dashboard')),
            ListTile(
                title: Text('Login', style: TextStyle(color: Colors.white)),
                onTap: () => context.go('/login')),
            ListTile(
                title: Text('Signup', style: TextStyle(color: Colors.white)),
                onTap: () => context.go('/signup')),
          ],
        ),
      ),
    );
  }
}
