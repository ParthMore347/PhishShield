import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'app_themes.dart';
import 'services/api_service.dart';
import 'services/device_profile.dart';
import 'widgets/terminal_diagnostics_view.dart';
import 'widgets/tactical_score_card.dart';
import 'widgets/cyber_radar_hero.dart';
import 'services/tactical_haptics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deviceProfile = await DeviceProfileProvider.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider.value(value: ScanHistoryProvider()),
        ChangeNotifierProvider.value(value: deviceProfile),
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
  final List<ScanItem> _scans = [];

  List<ScanItem> get scans => List.from(_scans.reversed);

  void replaceFromTelemetry(List<Map<String, dynamic>> events) {
    _scans
      ..clear()
      ..addAll(events.map((event) {
        final timestamp = DateTime.tryParse('${event['timestamp'] ?? ''}');
        final inputType = event['input_type']?.toString();
        final platform = event['platform']?.toString();
        return ScanItem(
          id: event['scan_id']?.toString() ?? '',
          type: platform == 'mobile_qr'
              ? 'QR Inspector'
              : inputType == 'text'
                  ? 'Smishing Detector'
                  : 'URL Guard',
          url: event['url']?.toString() ?? 'Unknown target',
          verdict: event['verdict']?.toString() ?? 'UNKNOWN',
          confidence: (event['confidence'] as num?)?.toDouble() ?? 0,
          date: timestamp == null ? 'Unknown date' : _formatDate(timestamp),
          synced: event['synced'] == true,
          details: event,
        );
      }));
    notifyListeners();
  }

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
    return _formatDate(DateTime.now());
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
  // Screens: welcome, home, url_guard, qr_inspector, smishing, history, profile, search, notifications
  String _currentScreen = 'welcome';
  final List<String> _navigationStack = ['welcome'];

  Future<void> _loadDeviceHistory() async {
    final profile = context.read<DeviceProfileProvider>();
    final telemetry =
        await ApiService().getTelemetry(deviceId: profile.deviceId);
    if (!mounted || telemetry['success'] != true) return;
    final events = telemetry['recent_events'];
    if (events is List) {
      context.read<ScanHistoryProvider>().replaceFromTelemetry(
            events.whereType<Map<String, dynamic>>().toList(),
          );
    }
  }

  void _navigateTo(String screenName) {
    if (_currentScreen == screenName) return;
    setState(() {
      _currentScreen = screenName;
      _navigationStack.add(screenName);
    });
    if (screenName == 'history') _loadDeviceHistory();
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
      case 'device_profile':
        return 'Device Profile';
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
      case 'device_profile':
        bodyWidget = const DeviceProfileScreen();
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
    final profile = context.watch<DeviceProfileProvider>();
    final avatarIcons = {
      'shield': Icons.shield_outlined,
      'radar': Icons.radar,
      'fox': Icons.pets,
      'owl': Icons.visibility,
    };

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drawer Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor:
                              theme.colorScheme.primary.withValues(alpha: 0.15),
                          child: Icon(
                            avatarIcons[profile.avatarId] ??
                                Icons.shield_outlined,
                            size: 19,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PhishShield',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                profile.nickname,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Menu Links
              buildMenuItem('Home', 'home'),
              buildMenuItem('URL Guard', 'url_guard'),
              buildMenuItem('QR Inspector', 'qr_inspector'),
              buildMenuItem('Smishing Detector', 'smishing'),
              buildMenuItem('History', 'history'),
              buildMenuItem('Device Profile', 'device_profile'),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: OutlinedButton(
                  onPressed: () => onNavigate('device_profile'),
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
                    'Edit device profile',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
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

class DeviceProfileScreen extends StatefulWidget {
  const DeviceProfileScreen({super.key});

  @override
  State<DeviceProfileScreen> createState() => _DeviceProfileScreenState();
}

class _DeviceProfileScreenState extends State<DeviceProfileScreen> {
  late final TextEditingController _nicknameController;
  late String _avatarId;

  static const avatarIcons = {
    'shield': Icons.shield_outlined,
    'radar': Icons.radar,
    'fox': Icons.pets,
    'owl': Icons.visibility,
  };

  @override
  void initState() {
    super.initState();
    final profile = context.read<DeviceProfileProvider>();
    _nicknameController = TextEditingController(text: profile.nickname);
    _avatarId = profile.avatarId;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    try {
      await context.read<DeviceProfileProvider>().update(
            nickname: _nicknameController.text,
            avatarId: _avatarId,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device profile saved on this phone.')),
      );
    } on ArgumentError catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.message?.toString() ?? 'Invalid profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<DeviceProfileProvider>();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 42,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            child: Icon(
              avatarIcons[_avatarId] ?? Icons.shield_outlined,
              size: 42,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: _nicknameController,
          maxLength: 40,
          decoration: const InputDecoration(
            labelText: 'Device nickname',
            hintText: 'e.g. Parth’s phone',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _avatarId,
          decoration: const InputDecoration(
            labelText: 'Avatar',
            border: OutlineInputBorder(),
          ),
          items: avatarIcons.entries
              .map(
                (entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(entry.value),
                      const SizedBox(width: 12),
                      Text(entry.key[0].toUpperCase() + entry.key.substring(1)),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _avatarId = value);
          },
        ),
        const SizedBox(height: 24),
        SelectableText(
          'Device ID: ${profile.deviceId}',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _saveProfile,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save device profile'),
        ),
        const SizedBox(height: 12),
        Text(
          'This profile identifies this phone only. No account or password is used. '
          'Its ID, nickname, and avatar are attached to scans saved in Atlas.',
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
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
                // Dynamic Animated Cyber Radar Dial
                const CyberRadarHero(size: 215),
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

    TacticalHaptics.triggerScan();

    if (directUrl != null) {
      _urlController.text = url;
    }

    setState(() {
      _isLoading = true;
      _lastScanDetails = null;
    });

    final history = Provider.of<ScanHistoryProvider>(context, listen: false);

    final stopwatch = Stopwatch()..start();
    final response = await _apiService.scanLink(
      url,
      deviceProfile: context.read<DeviceProfileProvider>().scanMetadata,
    );
    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 1100) {
      await Future.delayed(Duration(milliseconds: 1100 - elapsed));
    }
    if (!mounted) return;

    final verdict = response['verdict'] ?? 'ERROR';
    TacticalHaptics.triggerVerdict(verdict);

    setState(() {
      _isLoading = false;
      _lastScanDetails = response;
      history.addScan(
        type: 'URL Guard',
        url: url,
        verdict: verdict,
        confidence: (response['overall_confidence'] as num?)?.toDouble() ?? 0,
        synced: response['success'] == true,
        details: response,
      );
    });
  }

  void _showScoringStandardDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dialogBg = theme.cardTheme.color ?? theme.colorScheme.surface;
    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface;
    final subtextColor = textColor.withValues(alpha: 0.75);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? primaryColor.withValues(alpha: 0.3) : const Color(0xFFCBD5E1),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.shield_outlined, color: primaryColor, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'PhishShield Threat Scoring Standard',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Standardized deterministic 0 to 100 Multi-Vector Threat Index (PTSS):',
                style: TextStyle(fontSize: 12, color: subtextColor),
              ),
              const SizedBox(height: 14),
              // SAFE
              _buildTierItem(
                color: isDark ? Colors.greenAccent : const Color(0xFF16A34A),
                label: '0% – 20% Risk: SAFE',
                desc: 'Displayed as (100 - Risk)% Safe (e.g., 0% risk is 100% Safe, never 0%). Verified domain infrastructure, standard TLS, and clean lexical entropy.',
                subtextColor: subtextColor,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              // SUSPICIOUS
              _buildTierItem(
                color: isDark ? Colors.orangeAccent : const Color(0xFFD97706),
                label: '21% – 65% Risk: SUSPICIOUS',
                desc: 'Displayed as Risk% Threat. Flags Dynamic DNS hosts (e.g. dpdns.org), high-risk/abusive TLDs, unverified redirects, or elevated entropy (>0.78).',
                subtextColor: subtextColor,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              // MALICIOUS
              _buildTierItem(
                color: isDark ? Colors.redAccent : const Color(0xFFDC2626),
                label: '66% – 100% Risk: MALICIOUS',
                desc: 'Displayed as Risk% Threat. Direct brand typosquatting (e.g. paypa1), credential harvesting paths (/login, /verify), or raw IP hosts.',
                subtextColor: subtextColor,
                isDark: isDark,
              ),
              Divider(height: 24, color: theme.dividerColor.withValues(alpha: 0.3)),
              Text(
                'Inspected Security Modules:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 6),
              Text(
                '• Heuristics Engine (35%): Domain length, subdomain depth, IP usage, Shannon entropy, Dynamic DNS provider registry.\n• NLP Intent Engine (40%): Semantic urgency keywords, credential harvesting tokens, brand spoofing.\n• QR Vision (25%): Decodes disguised payloads and tests redirection hop chains.',
                style: TextStyle(fontSize: 11, color: subtextColor, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: isDark ? primaryColor : theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierItem({
    required Color color,
    required String label,
    required String desc,
    required Color subtextColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(color: subtextColor, fontSize: 11, height: 1.3)),
        ],
      ),
    );
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
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('ANALYZING...'),
                            ],
                          )
                        : const Text('Scan URL'),
                  ),
                ),
              ),
            ],
          ),

          // Terminal Diagnostics loading state
          if (_isLoading) ...[
            const SizedBox(height: 20),
            TerminalDiagnosticsView(
              type: DiagnosticType.url,
              target: _urlController.text.trim(),
            ),
          ],

          // Scan Result display card
          if (_lastScanDetails != null) ...[
            const SizedBox(height: 24),
            // Check for INVALID_INPUT or ERROR
            if (_lastScanDetails!['success'] == false ||
                _lastScanDetails!['verdict'] == 'INVALID_INPUT' ||
                _lastScanDetails!['verdict'] == 'ERROR') ...[
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.error_outline_rounded,
                            color: Colors.redAccent, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Invalid Input Notice',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _lastScanDetails!['error'] ??
                          _lastScanDetails!['message'] ??
                          'Please provide a valid website address.',
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Format example: https://example.com or example.org/stream',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              TacticalScoreCard(
                scanDetails: _lastScanDetails!,
                onHelpPressed: () => _showScoringStandardDialog(context),
              ),
            ],
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
    TacticalHaptics.triggerScan();
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

  Future<void> _handleDetectedCode(BarcodeCapture capture) async {
    if (_isProcessingResult) return;

    final code = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .map((value) => value.trim())
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
    if (code.isEmpty) return;

    TacticalHaptics.triggerScan();

    final history = Provider.of<ScanHistoryProvider>(context, listen: false);
    final deviceProfile = context.read<DeviceProfileProvider>().scanMetadata;
    deviceProfile['platform'] = 'mobile_qr';
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

    final stopwatch = Stopwatch()..start();
    final isUrl = Uri.tryParse(code)?.hasAuthority == true;
    final serverResponse = isUrl
        ? await _apiService.scanLink(code, deviceProfile: deviceProfile)
        : await _apiService.scanText(code, deviceProfile: deviceProfile);

    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 1100) {
      await Future.delayed(Duration(milliseconds: 1100 - elapsed));
    }
    if (!mounted) return;

    final isOnline =
        serverResponse['success'] == true && serverResponse['verdict'] != null;
    final response = serverResponse;
    final verdict = (response['verdict'] as String?) ?? 'ERROR';
    final confidence =
        (response['overall_confidence'] as num?)?.toDouble() ?? 0.0;

    TacticalHaptics.triggerVerdict(verdict);

    history.addScan(
      type: 'QR Inspector',
      url: code,
      verdict: verdict,
      confidence: confidence,
      synced: isOnline,
      details: response,
    );

    final scorePercent = (confidence * 100).round();
    Color tierColor;
    if (verdict == 'SAFE') {
      tierColor = const Color(0xFF00E676);
    } else if (verdict == 'SUSPICIOUS') {
      tierColor = const Color(0xFFFFB300);
    } else if (verdict == 'MALICIOUS') {
      tierColor = const Color(0xFFFF1744);
    } else {
      tierColor = const Color(0xFF94A3B8);
    }

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: tierColor.withValues(alpha: 0.6), width: 1.5),
          ),
          title: Row(
            children: [
              Icon(Icons.qr_code, color: tierColor),
              const SizedBox(width: 12),
              const Text(
                'QR Payload Audit',
                style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
              ),
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
              // Animated Score Dial
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: scorePercent.toDouble()),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: tierColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: tierColor.withValues(alpha: 0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: tierColor.withValues(alpha: 0.2),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              value: (val / 100.0).clamp(0.0, 1.0),
                              strokeWidth: 2.5,
                              backgroundColor: tierColor.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(tierColor),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            verdict == 'SAFE' ? '${(100 - val.round())}% Safe' : '${val.round()}% Threat',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: tierColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isOnline ? 'Verdict:' : 'Status:'),
                  Text(
                    verdict,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: tierColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isOnline
                    ? 'Threat check completed using the PhishShield engine.'
                    : (response['message'] ??
                        response['error'] ??
                        'The backend could not analyze this QR content.'),
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

    TacticalHaptics.triggerScan();

    setState(() {
      _isLoading = true;
    });

    final history = Provider.of<ScanHistoryProvider>(context, listen: false);

    final urlRegExp = RegExp(
      r'https?://[a-zA-Z0-9\-._~:/?#\[\]@!$&()*+,;=%]+',
      caseSensitive: false,
    );
    final match = urlRegExp.firstMatch(text);
    final target = match?.group(0) ?? 'SMS message';
    final stopwatch = Stopwatch()..start();
    final response = await _apiService.scanText(
      text,
      deviceProfile: context.read<DeviceProfileProvider>().scanMetadata,
    );

    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 1100) {
      await Future.delayed(Duration(milliseconds: 1100 - elapsed));
    }
    if (!mounted) return;
    final verdict = response['verdict'] ?? 'ERROR';
    final confidence =
        (response['overall_confidence'] as num?)?.toDouble() ?? 0.0;

    TacticalHaptics.triggerVerdict(verdict);

    setState(() {
      _isLoading = false;
    });

    // Save to global history
    history.addScan(
      type: 'Smishing Detector',
      url: target,
      verdict: verdict,
      confidence: confidence,
      synced: response['success'] == true,
      details: response,
    );

    // Open Custom Threat Inspector Dialog Modal
    _showThreatInspector(
      verdict,
      confidence,
      target,
      errorMessage: response['error'] ?? response['message'],
    );
  }

  void _showThreatInspector(
    String verdict,
    double confidence,
    String url, {
    String? errorMessage,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        final scorePercent = (confidence * 100).round();

        Color mainColor;
        if (verdict == 'SAFE') {
          mainColor = const Color(0xFF00E676); // Emerald
        } else if (verdict == 'SUSPICIOUS') {
          mainColor = const Color(0xFFFFB300); // Amber
        } else if (verdict == 'MALICIOUS') {
          mainColor = const Color(0xFFFF1744); // Crimson
        } else {
          mainColor = const Color(0xFF94A3B8);
        }

        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: mainColor.withValues(alpha: 0.65), width: 1.5),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: mainColor.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
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
                      Row(
                        children: [
                          Icon(Icons.shield_outlined, color: mainColor, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'THREAT INSPECTOR',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
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

                  // Animated Percentage dial
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: scorePercent.toDouble()),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CircularProgressIndicator(
                                    value: (value / 100.0).clamp(0.0, 1.0),
                                    strokeWidth: 5,
                                    backgroundColor: mainColor.withValues(alpha: 0.15),
                                    valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                                  ),
                                ),
                                Text(
                                  '${value.round()}%',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                    color: mainColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      verdict,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: mainColor,
                        fontSize: 18,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  if (verdict == 'ERROR') ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMessage ?? 'The backend could not analyze this message.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Buttons Stack
                  if (verdict != 'ERROR')
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Domain added to system blocklist.'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Block Domain'),
                      ),
                    ),
                  if (verdict != 'ERROR') const SizedBox(height: 10),
                  if (verdict != 'ERROR')
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
                  if (verdict != 'ERROR') const SizedBox(height: 10),
                  if (verdict != 'ERROR')
                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Verdict reported to MongoDB threat intelligence.'),
                            ),
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
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('ANALYZING...'),
                            ],
                          )
                        : const Text('Scan Message'),
                  ),
                ),
              ),
            ],
          ),

          // Terminal Diagnostics loading state
          if (_isLoading) ...[
            const SizedBox(height: 20),
            TerminalDiagnosticsView(
              type: DiagnosticType.sms,
              target: _msgController.text.trim().length > 40
                  ? '${_msgController.text.trim().substring(0, 40)}...'
                  : _msgController.text.trim(),
            ),
          ],
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
