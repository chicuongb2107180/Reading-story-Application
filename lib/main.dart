import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/search_novel_screen.dart';
import 'screens/write_novel/writing_novel_screen.dart';
import 'screens/auth/login_screen.dart';
import 'manager/novels_manager.dart';
import 'manager/auth_manager.dart';
import 'manager/chapter_manager.dart';
import 'manager/storage_manager.dart';
import 'manager/user_manager.dart';
import 'manager/theme_manager.dart';
import 'manager/follow_manager.dart';
import 'manager/current_chapter_manager.dart';
import 'manager/comment_manager.dart';
import 'manager/reading_manager.dart';
import 'manager/category_manager.dart';
import 'manager/vote_manager.dart';
import 'manager/report_manager.dart';
import 'manager/notification_manager.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthManager(),
        ),
        ChangeNotifierProvider(
          create: (context) => NovelsManager(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserManager(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChapterManager(),
        ),
        ChangeNotifierProvider(
          create: (context) => StorageManager(),
        ),
        ChangeNotifierProvider(
          create: (context) => FontThemeManager(),
        ),
        ChangeNotifierProvider(
          create: (context) => FollowManager(),
        ),
        ChangeNotifierProvider(
          create: (context) => CurrentChapterManager(),
        ),
        ChangeNotifierProvider(
          create: (context) => CommentManager(),
        ),
        ChangeNotifierProvider(
          create: (context) => ReadingManager(),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryManager(),
        ),
        ChangeNotifierProvider(
          create: (context) => VoteManager(),
        ),
        ChangeNotifierProvider(
          create: (context) => ReportManager(),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationManager(),
        ),
      ],
      child: Consumer<AuthManager>(builder: (ctx, auth, child) {
        return MaterialApp(
            title: 'Novel Reader',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.black,
                primary: Colors.black,
                secondary: Colors.grey[700],
                surface: Colors.white,
                error: Colors.red,
                onPrimary: Colors.white,
                onSecondary: Colors.black,
              ),
              textTheme: const TextTheme(
                titleSmall: TextStyle(fontSize: 16),
                titleLarge: TextStyle(fontSize: 22),
                titleMedium: TextStyle(fontSize: 18),
                bodyLarge: TextStyle(fontSize: 16),
                bodyMedium: TextStyle(fontSize: 14),
                bodySmall: TextStyle(fontSize: 12),
              ),
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              primaryTextTheme: const TextTheme(
                titleSmall: TextStyle(fontSize: 16, color: Colors.white),
                titleLarge: TextStyle(fontSize: 22, color: Colors.white),
                titleMedium: TextStyle(fontSize: 18, color: Colors.white),
                bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
                bodyMedium: TextStyle(fontSize: 14, color: Colors.white),
                bodySmall: TextStyle(fontSize: 12, color: Colors.white),
              ),
              cardTheme: const CardTheme(
                color: Colors.white,
                elevation: 2,
                margin: EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            home: auth.isAuth
                ? const MainBottomNavigationBar()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) {
                      return authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? const CircularProgressIndicator()
                          : const LoginScreen();
                    },
                  ));
      }),
    );
  }
}

class MainBottomNavigationBar extends StatefulWidget {
  final int? index;
  const MainBottomNavigationBar({super.key, this.index});

  @override
  State<MainBottomNavigationBar> createState() =>
      _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SearchNovelScreen(),
    LibraryScreen(),
    WritingNovelScreen(),
    ProfileScreen(),
  ];
  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      _selectedIndex = widget.index!;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Tìm kiếm',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Thư viện',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Viết truyện',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Tài khoản',
            backgroundColor: Colors.black,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
