import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/reels_screen.dart';
import 'node_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Huuga App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: AuthService.isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of node names for the Comic page
  final List<String> nodes = ['node1', 'node2', 'node3'];

  // Navigate to NodePage when a node is clicked
  void _openNode(String nodeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NodePage(
          nodeId: nodeId,
        ),
      ),
    );
  }

  // Comic page widget with grid layout
  Widget _buildComicPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: nodes.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _openNode(nodes[index]),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  nodes[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildPages() {
    return <Widget>[
      _buildComicPage(),
      const Center(child: Text('Chats Page')),
      const ReelsScreen(),
      const Center(child: Text('Psychologists Page')),
      const ToolsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Huuga App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: _buildPages()[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.auto_stories),
            label: 'Comic',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library),
            label: 'Reels',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology),
            label: 'Psychologists',
          ),
          NavigationDestination(
            icon: Icon(Icons.build),
            label: 'Tools',
          ),
        ],
      ),
    );
  }
}
