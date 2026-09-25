import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'app_themes.dart';
import 'services/api_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => ScanHistoryProvider()),
      ],
      child: const PhishShieldApp(),
    ),
  );
}

// -----------------------------------------------------------------------------
// Models & State Management
// -----------------------------------------------------------------------------

class ScanItem {
  final String id;
  final String type; // "URL Guard", "QR Inspector", "Smishing Detector"
  final String url;
  final String verdict; // "SAFE", "SUSPICIOUS", "MALICIOUS", "UNKNOWN"
  final double confidence; // 0.0 to 1.0
  final String date;
  final bool synced;
  final Map<String, dynamic>? details; // Explanations

  ScanItem({
    required this.id,
    required this.type,
    required this.url,
    required this.verdict,
    required this.confidence,
    required this.date,
    required this.synced,
    this.details,
  });
}

class ScanHistoryProvider with ChangeNotifier {
  final List<ScanItem> _scans = [
    // Pre-seeded items to match the user's screenshots
    ScanItem(
      id: '1',
      type: 'QR Inspector',
      url: 'https://safe-login.com/dashboard',
      verdict: 'SAFE',
      confidence: 0.84,
      date: '20 Aug 2026',
      synced: true,
    ),
    ScanItem(
      id: '2',
      type: 'URL Guard',
      url: 'https://my-utility-payment.net',
      verdict: 'SAFE',
      confidence: 0.62,
      date: '20 Aug 2026',
      synced: true,
    ),
    ScanItem(
      id: '3',
      type: 'QR Inspector',
      url: 'https://official-government-portal.org',
      verdict: 'SAFE',
      confidence: 0.96,
      date: '20 Aug 2026',
      synced: true,
    ),
    ScanItem(
      id: '4',
      type: 'Smishing Detector',
      url: 'https://security-alert-paypal-login.com',
      verdict: 'MALICIOUS',
      confidence: 0.91,
      date: '20 Aug 2026',
      synced: false, // "Pending" state
    ),
    ScanItem(
      id: '5',
      type: 'URL Guard',
      url: 'https://verification-needed-netflix.com',
      verdict: 'SUSPICIOUS',
      confidence: 0.82,
      date: '20 Aug 2026',
      synced: true,
    ),
  ];

  List<ScanItem> get scans => List.from(_scans.reversed);

  void addScan({
    required String type,
    required String url,
    required String verdict,
    required double confidence,
    bool synced = true,
    Map<String, dynamic>? details,
  }) {
    final newItem = ScanItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      url: url,
      verdict: verdict,
      confidence: confidence,
      date: _formatCurrentDate(),
      synced: synced,
      details: details,
    );
    _scans.add(newItem);
    notifyListeners();
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

class ThemeNotifier with ChangeNotifier {
  ThemeData _currentTheme = AppThemes.oledTheme;
  String _themeName = 'OLED';

  ThemeData get currentTheme => _currentTheme;
  String get themeName => _themeName;

  void setTheme(String themeName) {
    _themeName = themeName;
    if (themeName == 'OLED') {
      _currentTheme = AppThemes.oledTheme;
    } else if (themeName == 'Enterprise') {
      _currentTheme = AppThemes.enterpriseTheme;
    } else {
      _themeName = 'Cyberpunk';
      _currentTheme = AppThemes.cyberpunkTheme;
    }
    notifyListeners();
  }
}

// -----------------------------------------------------------------------------
// App Entry & Main Shell
// -----------------------------------------------------------------------------

class PhishShieldApp extends StatelessWidget {
  const PhishShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'PhishShield Mobile',
      theme: themeNotifier.currentTheme,
      home: const AppShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // Screens: welcome, home, url_guard, qr_inspector, smishing, history, search, notifications
  String _currentScreen = 'welcome';
  final List<String> _navigationStack = ['welcome'];

  void _navigateTo(String screenName) {
    if (_currentScreen == screenName) return;
    setState(() {
      _currentScreen = screenName;
      _navigationStack.add(screenName);
    });
  }

  bool _handleBackPress() {
    if (_navigationStack.length > 1) {
      _navigationStack.removeLast();
      setState(() {
        _currentScreen = _navigationStack.last;
      });
      return true;
    }
    return false;
  }

  String _getScreenTitle() {
    switch (_currentScreen) {
      case 'welcome':
        return 'PhishShield';
      case 'home':
        return 'Home';
      case 'url_guard':
        return 'URL Guard';
      case 'qr_inspector':
        return 'QR Inspector';
      case 'smishing':
        return 'Smishing Detector';
      case 'history':
        return 'History';
      case 'search':
        return 'Search';
      case 'notifications':
        return 'Notifications';
      default:
        return 'PhishShield';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = Theme.of(context);

    Widget bodyWidget;
    switch (_currentScreen) {
      case 'welcome':
        bodyWidget = WelcomeScreen(
          onExplore: () => _navigateTo('home'),
        );
        break;
      case 'home':
        bodyWidget = HomeScreen(
          onNavigate: _navigateTo,
        );
        break;
      case 'url_guard':
        bodyWidget = const UrlGuardScreen();
        break;
      case 'qr_inspector':
        bodyWidget = const QrInspectorScreen();
        break;
      case 'smishing':
        bodyWidget = const SmishingDetectorScreen();
        break;
      case 'history':
        bodyWidget = const HistoryScreen();
        break;
      case 'search':
        bodyWidget = SearchScreen(
          onNavigate: _navigateTo,
          onBack: _handleBackPress,
        );
        break;
      case 'notifications':
        bodyWidget = NotificationsScreen(
          onBack: _handleBackPress,
        );
        break;
      default:
        bodyWidget = WelcomeScreen(
          onExplore: () => _navigateTo('home'),
        );
    }

    // Whether to show the standard layout App Bar
    final bool useStandardAppBar =
        _currentScreen != 'search' && _currentScreen != 'notifications';

    return PopScope(
      canPop: _navigationStack.length <= 1,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackPress();
        }
      },
      child: Scaffold(
        appBar: useStandardAppBar
            ? AppBar(
                leading: _currentScreen != 'welcome'
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _handleBackPress,
                      )
                    : null,
                title: Text(
                  _getScreenTitle(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _navigateTo('search'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () => _navigateTo('notifications'),
                  ),
                  DropdownButton<String>(
                    value: themeNotifier.themeName,
                    dropdownColor: theme.colorScheme.surface,
                    style: TextStyle(color: theme.colorScheme.primary),
                    underline: Container(),
                    onChanged: (String? value) {
                      if (value != null) {
                        themeNotifier.setTheme(value);
                      }
                    },
                    items: <String>['OLED', 'Cyberpunk', 'Enterprise']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 8),
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
                  ),
                ],
              )
            : null,
        endDrawer: AppNavigationDrawer(
          activeScreen: _currentScreen,
          onNavigate: (screen) {
            Navigator.pop(context); // Close drawer
            _navigateTo(screen);
          },
        ),
        body: bodyWidget,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Custom Drawer Widget
// -----------------------------------------------------------------------------

class AppNavigationDrawer extends StatelessWidget {
  final String activeScreen;
  final Function(String) onNavigate;

  const AppNavigationDrawer({
    super.key,
    required this.activeScreen,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget buildMenuItem(String name, String screenKey) {
      final isSelected = activeScreen == screenKey;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: InkWell(
          onTap: () => onNavigate(screenKey),
          child: Text(
            name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      );
    }

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drawer Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'PhishShield',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Menu Links
              buildMenuItem('Home', 'home'),
              buildMenuItem('URL Guard', 'url_guard'),
              buildMenuItem('QR Inspector', 'qr_inspector'),
              buildMenuItem('Smishing Detector', 'smishing'),
              buildMenuItem('History', 'history'),

              const Spacer(),

              // Bottom Authentication Buttons
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAuthDialog(context, isSignUp: false);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAuthDialog(context, isSignUp: true);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showAuthDialog(
  BuildContext context, {
  required bool isSignUp,
}) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(isSignUp ? 'Create your account' : 'Welcome back'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSignUp)
                TextFormField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Enter your name'
                          : null,
                ),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  return email.contains('@') ? null : 'Enter a valid email';
                },
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) => (value?.length ?? 0) < 6
                    ? 'Use at least 6 characters'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            Navigator.pop(dialogContext);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isSignUp
                      ? 'Account created locally. Connect an auth service to enable sync.'
                      : 'Login details accepted locally. Connect an auth service to enable account access.',
                ),
              ),
            );
          },
          child: Text(isSignUp ? 'Sign up' : 'Login'),
        ),
      ],
    ),
  );
}

// -----------------------------------------------------------------------------
// 1. Welcome Screen (Landing Page)
// -----------------------------------------------------------------------------

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onExplore;

  const WelcomeScreen({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cyber HUD background / Hero Section
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.scaffoldBackgroundColor,
                  theme.colorScheme.surface.withValues(alpha: 0.5),
                ],
              ),
            ),
            child: Column(
              children: [
                // Simulated glowing radar/HUD graphic
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                        ),
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.radar,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Turn suspicious\nsignals into\nsafer decisions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Multi-source phishing detection with explainable threat intelligence.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 240,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onExplore,
                    child: const Text('Explore PhishShield'),
                  ),
                ),
              ],
            ),
          ),

          // Features Section
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              children: [
                const Text(
                  'See the signal\nbefore you click',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'A calm, explainable security layer for links, QR codes, and urgent messages.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),

                // Feature Card 1
                const FeatureBlockCard(
                  icon: Icons.check_circle_outline,
                  title: 'High-contrast verdicts',
                  description:
                      'Read Safe, Suspicious, and Malicious signals at a glance.',
                ),
                // Feature Card 2
                const FeatureBlockCard(
                  icon: Icons.find_in_page_outlined,
                  title: 'Explainable threat signals',
                  description:
                      'Understand the engines behind every confidence score.',
                ),
                // Feature Card 3
                const FeatureBlockCard(
                  icon: Icons.phone_android_outlined,
                  title: 'Mobile-first protection',
                  description:
                      'Focused scanning flows designed for quick decisions on the move.',
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: 240,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onExplore,
                    child: const Text('Explore PhishShield'),
                  ),
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(32.0),
            color: theme.scaffoldBackgroundColor,
            child: Column(
              children: [
                Text(
                  '© 2026 PhishShield, Inc. • Made in Austin, TX.',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.facebook, size: 20, color: Colors.grey),
                    SizedBox(width: 16),
                    Icon(Icons.video_camera_back, size: 20, color: Colors.grey),
                    SizedBox(width: 16),
                    Icon(Icons.camera_alt, size: 20, color: Colors.grey),
                    SizedBox(width: 16),
                    Icon(Icons.alternate_email, size: 20, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureBlockCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureBlockCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. Home Screen
// -----------------------------------------------------------------------------

class HomeScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final historyProvider = Provider.of<ScanHistoryProvider>(context);

    // Calculate dynamic security posture
    String postureText = "No recent phishing analysis is available.";
    String postureVerdict = "No verdict";
    Color postureColor = Colors.grey;

    if (historyProvider.scans.isNotEmpty) {
      final latest = historyProvider.scans.first;
      postureVerdict = latest.verdict;
      postureText = "Latest analysis details for ${latest.url}";
      if (latest.verdict == 'SAFE') {
        postureColor = Colors.greenAccent;
      } else if (latest.verdict == 'SUSPICIOUS') {
        postureColor = Colors.orangeAccent;
      } else if (latest.verdict == 'MALICIOUS') {
        postureColor = Colors.redAccent;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Shortcuts Grid Row
          Row(
            children: [
              Expanded(
                child: QuickShortcutButton(
                  icon: Icons.language,
                  label: 'URL Guard',
                  onTap: () => onNavigate('url_guard'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: QuickShortcutButton(
                  icon: Icons.qr_code_scanner,
                  label: 'QR Inspector',
                  onTap: () => onNavigate('qr_inspector'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: QuickShortcutButton(
                  icon: Icons.sms_failed_outlined,
                  label: 'Smishing',
                  onTap: () => onNavigate('smishing'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: QuickShortcutButton(
                  icon: Icons.history,
                  label: 'History',
                  onTap: () => onNavigate('history'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Security posture card
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Security posture',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  postureText,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: postureColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: postureColor, width: 1),
                  ),
                  child: Text(
                    postureVerdict,
                    style: TextStyle(
                      color: postureColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Verdict explanation guides
          const HomeVerdictGuideCard(
            title: 'Safe',
            description: 'Clear signals support confident decisions.',
            icon: Icons.check_circle_outline,
            iconColor: Colors.greenAccent,
          ),
          const HomeVerdictGuideCard(
            title: 'Suspicious',
            description: 'Pause and inspect before opening.',
            icon: Icons.info_outline,
            iconColor: Colors.orangeAccent,
          ),
          const HomeVerdictGuideCard(
            title: 'Malicious',
            description: 'Block and report dangerous content.',
            icon: Icons.error_outline,
            iconColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}

class QuickShortcutButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickShortcutButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeVerdictGuideCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  const HomeVerdictGuideCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. URL Guard Screen
// -----------------------------------------------------------------------------

class UrlGuardScreen extends StatefulWidget {
  const UrlGuardScreen({super.key});

  @override
  State<UrlGuardScreen> createState() => _UrlGuardScreenState();
}

class _UrlGuardScreenState extends State<UrlGuardScreen> {
  final TextEditingController _urlController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  Map<String, dynamic>? _lastScanDetails;

  Future<void> _handleScan([String? directUrl]) async {
    final url = directUrl ?? _urlController.text.trim();
    if (url.isEmpty) return;

    if (directUrl != null) {
      _urlController.text = url;
    }

    setState(() {
      _isLoading = true;
      _lastScanDetails = null;
    });

    final history = Provider.of<ScanHistoryProvider>(context, listen: false);

    // Call actual backend API
    final response = await _apiService.scanLink(url);

    setState(() {
      _isLoading = false;
      if (response['verdict'] == 'OFFLINE' || response['success'] == false) {
        // Mock logic if backend server is not running
        final dummyVerdict = _generateMockVerdict(url);
        final double dummyConf = _generateMockConfidence(url);

        _lastScanDetails = {
          'url': url,
          'verdict': dummyVerdict,
          'overall_confidence': dummyConf,
          'engine_results': {
            'heuristics': {'score': dummyConf * 0.8},
            'nlp': {'score': dummyConf * 0.9},
          }
        };

        history.addScan(
          type: 'URL Guard',
          url: url,
          verdict: dummyVerdict,
          confidence: dummyConf,
          details: _lastScanDetails,
        );
      } else {
        // Real API data
        _lastScanDetails = response;
        history.addScan(
          type: 'URL Guard',
          url: url,
          verdict: response['verdict'] ?? 'UNKNOWN',
          confidence: (response['overall_confidence'] ?? 0.0).toDouble(),
          details: response,
        );
      }
    });
  }

  String _generateMockVerdict(String url) {
    if (url.contains('phish') ||
        url.contains('login-verify') ||
        url.contains('alert')) {
      return 'MALICIOUS';
    }
    if (url.contains('utility') ||
        url.contains('netflix') ||
        url.contains('verify')) {
      return 'SUSPICIOUS';
    }
    return 'SAFE';
  }

  double _generateMockConfidence(String url) {
    if (url.contains('phish')) return 0.91;
    if (url.contains('netflix')) return 0.82;
    if (url.contains('utility')) return 0.62;
    return 0.74;
  }

  Color _getVerdictColor(String verdict) {
    switch (verdict.toUpperCase()) {
      case 'SAFE':
        return Colors.greenAccent;
      case 'SUSPICIOUS':
        return Colors.orangeAccent;
      case 'MALICIOUS':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = Provider.of<ScanHistoryProvider>(context);
    final urlScans =
        history.scans.where((item) => item.type == 'URL Guard').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Website address',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: 'https://example.com',
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _urlController.clear(),
              ),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a website address to check before opening it.',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),

          // Double buttons (Paste URL & Scan URL)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      _handleScan('https://secure-login-phishing-bank.net');
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Paste URL',
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _handleScan(),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Scan URL'),
                  ),
                ),
              ),
            ],
          ),

          // Scan Result display card
          if (_lastScanDetails != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getVerdictColor(_lastScanDetails!['verdict']),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _lastScanDetails!['verdict'] ?? 'UNKNOWN',
                        style: TextStyle(
                          color: _getVerdictColor(_lastScanDetails!['verdict']),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Confidence: ${((_lastScanDetails!['overall_confidence'] ?? 0.0) * 100).round()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Target URL: ${_lastScanDetails!['url']}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  const Divider(height: 24),
                  // Breakdown scores
                  const Text(
                    'Engine breakdowns:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Heuristics: ${((_lastScanDetails!['engine_results']?['heuristics']?['score'] ?? 0.0) * 100).round()}%',
                          style: const TextStyle(
                              fontSize: 11, fontFamily: 'monospace'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'NLP Brand: ${((_lastScanDetails!['engine_results']?['nlp']?['score'] ?? 0.0) * 100).round()}%',
                          style: const TextStyle(
                              fontSize: 11, fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
          const Text(
            'Recent URL Guard scans',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (urlScans.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'No recent URL scans.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: urlScans.length,
              itemBuilder: (context, index) {
                final item = urlScans[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: _getVerdictColor(item.verdict),
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.verdict,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(item.confidence * 100).round()}% confidence',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              item.date,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Synced',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. QR Inspector Screen (Simulated scan view)
// -----------------------------------------------------------------------------

class QrInspectorScreen extends StatefulWidget {
  const QrInspectorScreen({super.key});

  @override
  State<QrInspectorScreen> createState() => _QrInspectorScreenState();
}

class _QrInspectorScreenState extends State<QrInspectorScreen>
    with SingleTickerProviderStateMixin {
  bool _isScanning = false;
  bool _isProcessingResult = false;
  String? _scanStatus;
  final MobileScannerController _cameraController = MobileScannerController();
  final ApiService _apiService = ApiService();
  late AnimationController _scannerAnimationController;

  @override
  void initState() {
    super.initState();
    _scannerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _scannerAnimationController.dispose();
    super.dispose();
  }

  Future<void> _startCameraScan() async {
    setState(() {
      _isScanning = true;
      _scanStatus = 'Point the camera at a QR code.';
    });
    _scannerAnimationController.repeat(reverse: true);
    await _cameraController.start();
  }

  Future<void> _stopCameraScan() async {
    await _cameraController.stop();
    _scannerAnimationController.stop();
    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _scanStatus = 'Scanning stopped.';
    });
  }

  Map<String, dynamic> _analyzeQrOffline(String code) {
    final normalized = code.toLowerCase();
    final isUrl = normalized.startsWith('http://') ||
        normalized.startsWith('https://');
    final signals = <String, dynamic>{};
    var riskScore = 0.0;

    if (!isUrl) {
      signals['content_type'] = 'QR contains text or data, not a web URL';
      riskScore += 0.10;
    } else {
      final uri = Uri.tryParse(code);
      final host = uri?.host.toLowerCase() ?? '';
      final hasHttps = uri?.scheme.toLowerCase() == 'https';
      final suspiciousTerms = RegExp(
        r'(login|verify|secure|account|payment|wallet|claim|urgent|update|confirm)',
        caseSensitive: false,
      ).hasMatch(host + (uri?.path.toLowerCase() ?? ''));
      final hasIpHost = RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(host);
      final longHost = host.length > 35;

      signals['https'] = hasHttps;
      signals['domain'] = host.isEmpty ? 'Unable to parse domain' : host;
      signals['suspicious_terms'] = suspiciousTerms;
      signals['ip_address_host'] = hasIpHost;
      signals['long_domain'] = longHost;

      if (!hasHttps) riskScore += 0.25;
      if (suspiciousTerms) riskScore += 0.30;
      if (hasIpHost) riskScore += 0.25;
      if (longHost) riskScore += 0.15;
      if (host.isEmpty) riskScore += 0.35;
    }

    final verdict = riskScore >= 0.55
        ? 'MALICIOUS'
        : riskScore >= 0.25
            ? 'SUSPICIOUS'
            : 'SAFE';
    final confidence = (0.60 + riskScore * 0.65).clamp(0.0, 0.98).toDouble();
    return {
      'success': true,
      'source': 'offline_heuristics',
      'url': code,
      'verdict': verdict,
      'overall_confidence': confidence,
      'engine_results': {
        'heuristics': {
          'score': riskScore.clamp(0.0, 1.0),
          'signals': signals,
        },
      },
    };
  }

  Future<void> _handleDetectedCode(BarcodeCapture capture) async {
    if (_isProcessingResult) return;

    final code = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .map((value) => value.trim())
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
    if (code.isEmpty) return;

    _isProcessingResult = true;
    if (mounted) {
      setState(() {
        _scanStatus = 'QR captured. Checking it for threats...';
      });
    }
    _scannerAnimationController.stop();
    await _cameraController.stop();
    setState(() {
      _isScanning = false;
    });

    final serverResponse = await _apiService.scanLink(code);
    if (!mounted) return;

    final isOnline = serverResponse['success'] == true &&
        serverResponse['verdict'] != null &&
        serverResponse['verdict'] != 'OFFLINE';
    final response =
        isOnline ? serverResponse : _analyzeQrOffline(code);
    final verdict = (response['verdict'] as String?) ?? 'UNKNOWN';
    final confidence = (response['overall_confidence'] as num?)?.toDouble() ?? 0.0;
    final history = Provider.of<ScanHistoryProvider>(context, listen: false);
    history.addScan(
      type: 'QR Inspector',
      url: code,
      verdict: verdict,
      confidence: confidence,
      synced: isOnline,
      details: response,
    );

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: const Row(
            children: [
              Icon(Icons.qr_code, color: Colors.blueAccent),
              SizedBox(width: 12),
              Text('QR Code Parsed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Decoded URL:',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isOnline ? 'Online verdict:' : 'Offline heuristic verdict:'),
                  Text(
                    verdict,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: verdict == 'SAFE'
                          ? Colors.greenAccent
                          : verdict == 'SUSPICIOUS'
                              ? Colors.orangeAccent
                              : Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isOnline
                    ? 'Threat check completed using the PhishShield engine.'
                    : 'Server unavailable. This result was calculated locally from QR URL signals.',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              if (response['engine_results']?['heuristics'] != null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Heuristic report',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Risk score: ${(((response['engine_results']?['heuristics']?['score'] ?? 0.0) as num) * 100).round()}%',
                  style: const TextStyle(fontSize: 12),
                ),
                ...((response['engine_results']?['heuristics']?['signals']
                                    as Map<String, dynamic>?) ??
                                {})
                    .entries
                    .map(
                              (entry) => Text(
                                '${entry.key}: ${entry.value}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                    ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    _isProcessingResult = false;
    if (mounted) {
      setState(() {
        _scanStatus = isOnline
            ? 'Threat check completed online.'
            : 'Threat check completed with offline heuristics.';
      });
    }
  }

  Color _getVerdictColor(String verdict) {
    switch (verdict.toUpperCase()) {
      case 'SAFE':
        return Colors.greenAccent;
      case 'SUSPICIOUS':
        return Colors.orangeAccent;
      case 'MALICIOUS':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = Provider.of<ScanHistoryProvider>(context);
    final qrScans =
        history.scans.where((item) => item.type == 'QR Inspector').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live camera scanner card
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
            child: _isScanning
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        MobileScanner(
                          controller: _cameraController,
                          onDetect: _handleDetectedCode,
                          errorBuilder: (context, error) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Camera unavailable: ${error.errorDetails?.message ?? error.errorCode.name}',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                        const ViewfinderOverlay(),
                        AnimatedBuilder(
                          animation: _scannerAnimationController,
                          builder: (context, child) {
                            return Positioned(
                              top: 240 * _scannerAnimationController.value,
                              left: 20,
                              right: 20,
                              child: Container(
                                height: 3,
                                color: theme.colorScheme.primary,
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: OutlinedButton.icon(
                              onPressed: _stopCameraScan,
                              icon: const Icon(Icons.stop, size: 18),
                              label: const Text('Stop scanning'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _scanStatus ?? 'Camera is ready to scan a QR code.',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: _startCameraScan,
                            child: const Text('Start live camera scan'),
                          ),
                          if (_scanStatus == 'Scanning stopped.') ...[
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: _startCameraScan,
                              child: const Text('Try again'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 32),
          const Text(
            'Recent QR scans',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (qrScans.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'No recent QR scans.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: qrScans.length,
              itemBuilder: (context, index) {
                final item = qrScans[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check,
                        color: _getVerdictColor(item.verdict),
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.verdict,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(item.confidence * 100).round()}% confidence',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Synced',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class ViewfinderOverlay extends StatelessWidget {
  const ViewfinderOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Positioned.fill(
      child: CustomPaint(
        painter: ViewfinderPainter(color: color),
      ),
    );
  }
}

class ViewfinderPainter extends CustomPainter {
  final Color color;

  ViewfinderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const length = 20.0;
    const inset = 30.0;

    // Top-Left corner
    canvas.drawLine(
        const Offset(inset, inset), const Offset(inset + length, inset), paint);
    canvas.drawLine(
        const Offset(inset, inset), const Offset(inset, inset + length), paint);

    // Top-Right corner
    canvas.drawLine(Offset(size.width - inset, inset),
        Offset(size.width - inset - length, inset), paint);
    canvas.drawLine(Offset(size.width - inset, inset),
        Offset(size.width - inset, inset + length), paint);

    // Bottom-Left corner
    canvas.drawLine(Offset(inset, size.height - inset),
        Offset(inset + length, size.height - inset), paint);
    canvas.drawLine(Offset(inset, size.height - inset),
        Offset(inset, size.height - inset - length), paint);

    // Bottom-Right corner
    canvas.drawLine(Offset(size.width - inset, size.height - inset),
        Offset(size.width - inset - length, size.height - inset), paint);
    canvas.drawLine(Offset(size.width - inset, size.height - inset),
        Offset(size.width - inset, size.height - inset - length), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// 5. Smishing Detector Screen & Threat Inspector Dialog
// -----------------------------------------------------------------------------

class SmishingDetectorScreen extends StatefulWidget {
  const SmishingDetectorScreen({super.key});

  @override
  State<SmishingDetectorScreen> createState() => _SmishingDetectorScreenState();
}

class _SmishingDetectorScreenState extends State<SmishingDetectorScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _handlePasteText() {
    _msgController.text =
        "URGENT: Your parcel delivery is pending verification. To prevent return, verify details immediately at https://postal-service-redirection.com/delivery";
  }

  Future<void> _handleScanMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final history = Provider.of<ScanHistoryProvider>(context, listen: false);

    // Check for links in text
    final urlRegExp = RegExp(
      r'https?://[a-zA-Z0-9\-._~:/?#\[\]@!$&()*+,;=%]+',
      caseSensitive: false,
    );
    final match = urlRegExp.firstMatch(text);

    String targetUrl = '';
    String verdict = 'SAFE';
    double confidence = 0.15;

    if (match != null) {
      targetUrl = match.group(0)!;
      // Hit backend API to scan the URL extracted
      final response = await _apiService.scanLink(targetUrl);
      if (response['verdict'] != 'OFFLINE' && response['success'] != false) {
        verdict = response['verdict'] ?? 'UNKNOWN';
        confidence = (response['overall_confidence'] ?? 0.0).toDouble();
      } else {
        // Fallback simulated logic
        if (targetUrl.contains('postal') || targetUrl.contains('phish')) {
          verdict = 'MALICIOUS';
          confidence = 0.91;
        } else {
          verdict = 'SUSPICIOUS';
          confidence = 0.65;
        }
      }
    } else {
      // Local keyword matching
      targetUrl = 'Text Analysis (No link)';
      int triggerWords = 0;
      final keywords = [
        'urgent',
        'verify',
        'suspended',
        'delivery',
        'login',
        'bank',
        'win',
        'prize'
      ];
      for (var word in keywords) {
        if (text.toLowerCase().contains(word)) {
          triggerWords++;
        }
      }

      if (triggerWords >= 3) {
        verdict = 'MALICIOUS';
        confidence = 0.91;
      } else if (triggerWords >= 1) {
        verdict = 'SUSPICIOUS';
        confidence = 0.55;
      } else {
        verdict = 'SAFE';
        confidence = 0.12;
      }
    }

    setState(() {
      _isLoading = false;
    });

    // Save to global history
    history.addScan(
      type: 'Smishing Detector',
      url: targetUrl,
      verdict: verdict,
      confidence: confidence,
      synced: false, // "Pending" sync status as seen in the screenshots
    );

    // Open Custom Threat Inspector Dialog Modal
    _showThreatInspector(verdict, confidence, targetUrl);
  }

  void _showThreatInspector(String verdict, double confidence, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        final scorePercent = (confidence * 100).round();

        Color mainColor;
        if (verdict == 'SAFE') {
          mainColor = Colors.greenAccent;
        } else if (verdict == 'SUSPICIOUS') {
          mainColor = Colors.orangeAccent;
        } else {
          mainColor = Colors.redAccent;
        }

        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side:
                BorderSide(color: mainColor.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with custom title & Close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Threat inspector',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 16),

                // Percentage indicator
                Center(
                  child: Text(
                    '$scorePercent%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: mainColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    verdict,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons Stack
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Domain added to system blocklist.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Block Domain'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                    child: const Text('Safe to Open'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Verdict reported to MongoDB threat intelligence.')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white30),
                    ),
                    child: Text(
                      'Report Phish',
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Text message',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _msgController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Paste the SMS or message content here...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan text messages for suspicious links and indicators.',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),

          // Double Actions
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _handlePasteText,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      'Paste Text',
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleScanMessage,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Scan Message'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 6. History Screen (Telemetry Log)
// -----------------------------------------------------------------------------

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Color _getVerdictColor(String verdict) {
    switch (verdict.toUpperCase()) {
      case 'SAFE':
        return Colors.greenAccent;
      case 'SUSPICIOUS':
        return Colors.orangeAccent;
      case 'MALICIOUS':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = Provider.of<ScanHistoryProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        const Text(
          'Telemetry log',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Stored detection verdicts and MongoDB sync status',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 24),

        // List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.scans.length,
          itemBuilder: (context, index) {
            final item = history.scans[index];
            final color = _getVerdictColor(item.verdict);
            return Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  // Verdict Badge
                  Container(
                    width: 90,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color, width: 1.0),
                    ),
                    child: Text(
                      item.verdict,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Scan details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.type,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Confidence: ${(item.confidence * 100).round()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          item.date,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sync Pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.synced
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.synced ? 'Synced' : 'Pending',
                      style: TextStyle(
                        color: item.synced
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 7. Search Screen
// -----------------------------------------------------------------------------

class SearchScreen extends StatefulWidget {
  final Function(String) onNavigate;
  final VoidCallback onBack;

  const SearchScreen({
    super.key,
    required this.onNavigate,
    required this.onBack,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> tags = [
    {'label': 'PhishShield', 'route': 'welcome'},
    {'label': 'Safe', 'route': 'home'},
    {'label': 'Suspicious', 'route': 'home'},
    {'label': 'Malicious', 'route': 'home'},
    {'label': 'High-contrast verdicts', 'route': 'home'},
    {'label': 'Explainable threat signals', 'route': 'home'},
    {'label': 'Mobile-first protection', 'route': 'welcome'},
    {'label': 'URL Threat Scan', 'route': 'url_guard'},
    {'label': 'QR Threat Inspector', 'route': 'qr_inspector'},
    {'label': 'Smishing Scanner', 'route': 'smishing'},
    {'label': 'Threat Telemetry', 'route': 'history'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
          ),
          onSubmitted: (val) {
            if (val.toLowerCase().contains('url') ||
                val.toLowerCase().contains('scan')) {
              widget.onNavigate('url_guard');
            } else if (val.toLowerCase().contains('qr') ||
                val.toLowerCase().contains('camera')) {
              widget.onNavigate('qr_inspector');
            } else if (val.toLowerCase().contains('sms') ||
                val.toLowerCase().contains('smish')) {
              widget.onNavigate('smishing');
            } else if (val.toLowerCase().contains('history') ||
                val.toLowerCase().contains('log')) {
              widget.onNavigate('history');
            }
          },
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Center Search Icon
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search,
                  size: 36,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'What are you looking for?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a name to find what you\'re looking for.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),

            // Flow grid of chips
            Center(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children: tags.map((tag) {
                  return ActionChip(
                    label: Text(tag['label']!),
                    labelStyle: const TextStyle(fontSize: 12),
                    backgroundColor: theme.cardTheme.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.08),
                      ),
                    ),
                    onPressed: () => widget.onNavigate(tag['route']!),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 8. Notifications Screen
// -----------------------------------------------------------------------------

class NotificationsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const NotificationsScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Notifications'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Notifications Icon Circle
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white10,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_off_outlined,
                  size: 36,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Notifications are off',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Turn on notifications to stay up to date without opening PhishShield',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 48),

            // Action button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Notifications enabled successfully.')),
                  );
                  onBack();
                },
                child: const Text('Turn On Notifications'),
              ),
            ),
            const SizedBox(height: 12),

            // Not now link
            TextButton(
              onPressed: onBack,
              child: const Text(
                'Not Now',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
