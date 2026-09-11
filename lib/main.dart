import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'form_validators.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ukgrkpslqgggnuvfqzbb.supabase.co',
    publishableKey: 'sb_publishable_AxBmE12nVkp02XFZqkiRuw_KsQTnh9D',
  );
  runApp(const MyTrendingWebApp());
}

final supabase = Supabase.instance.client;

class MyTrendingWebApp extends StatelessWidget {
  const MyTrendingWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ardaita and Surrounding Charity Association',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Segoe UI',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF1B5E20),
          surface: const Color(0xFFFCF7EE),
        ),
        scaffoldBackgroundColor: const Color(0xFFFCF7EE),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 2,
          titleSpacing: 20,
          toolbarHeight: 74,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.w800,
            fontSize: 48,
            letterSpacing: -0.8,
          ),
          displayMedium: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.w800,
            fontSize: 32,
            letterSpacing: -0.6,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            height: 1.58,
            color: Color(0xFF1F2A1F),
          ),
        ),
        dividerColor: Colors.green.shade200,
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class HoverableFloatingMenu extends StatefulWidget {
  final Widget child;
  const HoverableFloatingMenu({super.key, required this.child});

  @override
  State<HoverableFloatingMenu> createState() => _HoverableFloatingMenuState();
}

class _HoverableFloatingMenuState extends State<HoverableFloatingMenu> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovering ? -2 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: _isHovering
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}

class HoverDropdownItem {
  final String label;
  final VoidCallback onPressed;

  const HoverDropdownItem({required this.label, required this.onPressed});
}

class HoverDropdownMenu extends StatefulWidget {
  final String label;
  final bool isSelected;
  final List<HoverDropdownItem> items;

  const HoverDropdownMenu({
    super.key,
    required this.label,
    required this.isSelected,
    required this.items,
  });

  @override
  State<HoverDropdownMenu> createState() => _HoverDropdownMenuState();
}

class _HoverDropdownMenuState extends State<HoverDropdownMenu> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  Timer? _closeTimer;

  void _cancelClose() {
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  void _scheduleClose() {
    _cancelClose();
    _closeTimer = Timer(const Duration(milliseconds: 120), () {
      if (mounted) {
        _close();
      }
    });
  }

  void _close() {
    _cancelClose();
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() => _isOpen = false);
    }
  }

  void _open() {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 220,
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: const Offset(0, 42),
            child: MouseRegion(
              onEnter: (_) => _cancelClose(),
              onExit: (_) => _scheduleClose(),
              child: Material(
                elevation: 8,
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.items
                        .map(
                          (item) => InkWell(
                            onTap: () {
                              item.onPressed();
                              _close();
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Text(
                                item.label,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  @override
  Widget build(BuildContext context) {
    final trigger = HoverableFloatingMenu(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? Colors.white.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                color: widget.isSelected ? Colors.white : Colors.green.shade100,
                fontWeight: widget.isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: widget.isSelected ? Colors.white : Colors.green.shade100,
              size: 20,
            ),
          ],
        ),
      ),
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) {
          _cancelClose();
          if (!_isOpen) _open();
        },
        onExit: (_) => _scheduleClose(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: InkWell(
            onTap: () {
              if (_isOpen) {
                _close();
              } else {
                _open();
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: trigger,
          ),
        ),
      ),
    );
  }
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  int? _aboutUsSubTab;
  int? _resourcesSubTab;
  int? _volunteerSubTab;

  List<Widget> get _pages => [
    HomePage(
      onNavigate: (index, [subTab]) {
        setState(() {
          _selectedIndex = index;
          if (index == 1) _aboutUsSubTab = subTab;
          if (index == 2) _resourcesSubTab = subTab;
          if (index == 3) _volunteerSubTab = subTab;
        });
      },
    ),
    AboutUsPage(initialSubTab: _aboutUsSubTab),
    ResourcesWrapper(initialSubTab: _resourcesSubTab),
    VolunteerWrapper(initialSubTab: _volunteerSubTab),
    const ContactUsPage(),
    const DonatePage(),
  ];

  List<Widget> _buildDesktopActions() => [
    _buildTopMenuItem(0, 'Home'),
    _buildAboutUsMenu(),
    _buildResourcesMenu(),
    _buildVolunteerMenu(),
    _buildTopMenuItem(4, 'Contact Us'),
    _buildTopMenuItem(5, 'Donate'),
    const SizedBox(width: 20),
  ];

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 980;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isCompact ? 42 : 50,
              height: isCompact ? 42 : 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/New_Logo.jpg',
                  width: isCompact ? 42 : 50,
                  height: isCompact ? 42 : 50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (!isCompact) ...[
              const SizedBox(width: 12),
              const Text(
                'Ardaita and Surrounding Charity Association',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
        automaticallyImplyLeading: false,
        actions: isCompact
            ? [
                IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  tooltip: 'Open navigation menu',
                ),
                const SizedBox(width: 8),
              ]
            : _buildDesktopActions(),
      ),
      drawer: isCompact
          ? Drawer(
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    _buildDrawerItem('Home', 0),
                    _buildDrawerItem('About Us', 1, subTab: 0),
                    _buildDrawerItem('Resources', 2, subTab: 0),
                    _buildDrawerItem('Volunteer', 3, subTab: 0),
                    _buildDrawerItem('Contact Us', 4),
                    _buildDrawerItem('Donate', 5),
                  ],
                ),
              ),
            )
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _pages[_selectedIndex],
      ),
    );
  }

  Widget _buildDrawerItem(String label, int index, {int? subTab}) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
        ),
      ),
      selected: isSelected,
      onTap: () {
        setState(() {
          _selectedIndex = index;
          if (index == 1) _aboutUsSubTab = subTab ?? 0;
          if (index == 2) _resourcesSubTab = subTab ?? 0;
          if (index == 3) _volunteerSubTab = subTab ?? 0;
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildTopMenuItem(int index, String label) {
    bool isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: HoverableFloatingMenu(
        child: TextButton(
          onPressed: () => setState(() => _selectedIndex = index),
          style: TextButton.styleFrom(
            foregroundColor: isSelected ? Colors.white : Colors.green.shade100,
            backgroundColor: isSelected
                ? Colors.white.withOpacity(0.12)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            minimumSize: const Size(0, 42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
              letterSpacing: 0.12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutUsMenu() {
    final isSelected = _selectedIndex == 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: HoverDropdownMenu(
        label: 'About Us',
        isSelected: isSelected,
        items: [
          HoverDropdownItem(
            label: 'Who We Are',
            onPressed: () {
              setState(() {
                _selectedIndex = 1;
                _aboutUsSubTab = 0;
              });
            },
          ),
          HoverDropdownItem(
            label: 'What We Do',
            onPressed: () {
              setState(() {
                _selectedIndex = 1;
                _aboutUsSubTab = 1;
              });
            },
          ),
          HoverDropdownItem(
            label: 'Initiatives',
            onPressed: () {
              setState(() {
                _selectedIndex = 1;
                _aboutUsSubTab = 2;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesMenu() {
    final isSelected = _selectedIndex == 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: HoverDropdownMenu(
        label: 'Resources',
        isSelected: isSelected,
        items: [
          HoverDropdownItem(
            label: 'Documents',
            onPressed: () {
              setState(() {
                _selectedIndex = 2;
                _resourcesSubTab = 0;
              });
            },
          ),
          HoverDropdownItem(
            label: 'Gallery',
            onPressed: () {
              setState(() {
                _selectedIndex = 2;
                _resourcesSubTab = 1;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerMenu() {
    final isSelected = _selectedIndex == 3;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: HoverDropdownMenu(
        label: 'Volunteer',
        isSelected: isSelected,
        items: [
          HoverDropdownItem(
            label: 'Become a Volunteer',
            onPressed: () {
              setState(() {
                _selectedIndex = 3;
                _volunteerSubTab = 0;
              });
            },
          ),
        ],
      ),
    );
  }
}

class ResourcesWrapper extends StatefulWidget {
  final int? initialSubTab;
  const ResourcesWrapper({super.key, this.initialSubTab});

  @override
  State<ResourcesWrapper> createState() => _ResourcesWrapperState();
}

class _ResourcesWrapperState extends State<ResourcesWrapper> {
  int? selectedSubTab;

  @override
  void initState() {
    super.initState();
    selectedSubTab = widget.initialSubTab;
  }

  @override
  void didUpdateWidget(ResourcesWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSubTab != oldWidget.initialSubTab) {
      selectedSubTab = widget.initialSubTab;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/Home_page.jpg', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.35),
                ],
              ),
            ),
          ),
        ),
        Column(
          children: [
            Expanded(
              child: selectedSubTab == null
                  ? const Center(
                      child: Text(
                        'Select a resource section to view details',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.93),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: selectedSubTab == 0
                            ? const ResourcesPage()
                            : const GalleryPage(),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class VolunteerWrapper extends StatefulWidget {
  final int? initialSubTab;
  const VolunteerWrapper({super.key, this.initialSubTab});

  @override
  State<VolunteerWrapper> createState() => _VolunteerWrapperState();
}

class _VolunteerWrapperState extends State<VolunteerWrapper> {
  int? selectedSubTab;

  @override
  void initState() {
    super.initState();
    selectedSubTab = widget.initialSubTab;
  }

  @override
  void didUpdateWidget(VolunteerWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSubTab != oldWidget.initialSubTab) {
      selectedSubTab = widget.initialSubTab;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/Home_Page.jpg', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.35),
                ],
              ),
            ),
          ),
        ),
        Column(
          children: [
            Expanded(
              child: selectedSubTab == null
                  ? const Center(
                      child: Text(
                        'Select a section to start volunteering',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.93),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: BecomeVolunteerPage(),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  final Function(int, [int?]) onNavigate;
  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section
          Stack(
            children: [
              SizedBox(
                height: 520,
                width: double.infinity,
                child: Image.asset(
                  'assets/Home_page.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.72),
                        Colors.black.withOpacity(0.24),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.45, 1.0],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        const Text(
                          'Empowering Ardaita Together',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 54,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.1,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Unity, Development, and Sustainable Growth for our Community',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.05,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          alignment: WrapAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: () => onNavigate(
                                1,
                                2,
                              ), // Initiatives under About Us
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 20,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Explore Initiatives'),
                            ),
                            OutlinedButton(
                              onPressed: () =>
                                  onNavigate(3, 0), // Become a Volunteer
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 20,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Become a Volunteer'),
                            ),
                            OutlinedButton(
                              onPressed: () => onNavigate(5), // Donate
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 20,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Support Ardaita'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Features/Stats Summary
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 40),
            child: Wrap(
              spacing: 32,
              runSpacing: 32,
              alignment: WrapAlignment.center,
              children: [
                _buildStatItem(
                  context,
                  Icons.people,
                  '1000+',
                  'Lives Impacted',
                ),
                _buildStatItem(
                  context,
                  Icons.school,
                  '20+',
                  'Education Programs',
                ),
                _buildStatItem(context, Icons.eco, '100+', 'Green Initiatives'),
                _buildStatItem(
                  context,
                  Icons.trending_up,
                  '24/7',
                  'Community Support',
                ),
              ],
            ),
          ),

          // Short About Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
            color: Colors.white,
            child: Column(
              children: [
                Text(
                  'Who We Are',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 24),
                const MaxWidthContainer(
                  child: Text(
                    'Ardaita and Surrounding Charity Association is a community-driven organization dedicated to fostering sustainable progress, equitable education, and accessible healthcare in the Ardaita region.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, height: 1.6),
                  ),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => onNavigate(1, 0),
                  child: const Text(
                    'Read our full story →',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Call to Action Bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
            decoration: BoxDecoration(color: Colors.green.shade50),
            child: Column(
              children: [
                const Text(
                  'Join us in making a difference',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => onNavigate(4), // Contact
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                  ),
                  child: const Text(
                    'Get Involved Today',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            color: Colors.green.shade900,
            width: double.infinity,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.green.shade900,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/New_Logo.jpg',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ardaita and Surrounding Charity Association',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Empowering Communities Together',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  '© 2026 Ardaita and Surrounding Charity Association. All rights reserved.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ardaita, Ethiopia | info@ardaita-asca.org',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, size: 48, color: Colors.green.shade700),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}

class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth = 800,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class AboutUsPage extends StatefulWidget {
  final int? initialSubTab;

  const AboutUsPage({super.key, this.initialSubTab});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  int? selectedSubTab; // null = nothing selected initially

  @override
  void initState() {
    super.initState();
    selectedSubTab = widget.initialSubTab;
  }

  @override
  void didUpdateWidget(covariant AboutUsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSubTab != widget.initialSubTab) {
      selectedSubTab = widget.initialSubTab;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/Home_Page.jpg', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.35),
                ],
              ),
            ),
          ),
        ),
        Column(
          children: [
            // Content area
            Expanded(
              child: selectedSubTab == null
                  ? const Center(
                      child: Text(
                        'Select a section to view details',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.93),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: selectedSubTab == 0
                            ? const WhoWeAreTab()
                            : selectedSubTab == 1
                            ? const WhatWeDoTab()
                            : const InitiativesTab(),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class WhoWeAreTab extends StatelessWidget {
  const WhoWeAreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo at the top
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/New_Logo.jpg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Why the Association Was Established',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 12),
          const Text(
            'The association brings people connected to Ardaita together around a shared commitment to unity, opportunity, and lasting community wellbeing.',
            style: TextStyle(fontSize: 18, height: 1.6, color: Colors.black87),
          ),
          const SizedBox(height: 28),
          _buildRationaleCard(
            context,
            number: '01',
            title: 'To Preserve Unity and Strengthen Lifelong Relationships',
            english:
                'The Association is established to preserve and strengthen the bonds of unity, brotherhood, and sisterhood among individuals connected to Ardaita.',
            amharic:
                'አንድነትን ለማስጠበቅ እና የረጅም ጊዜ ግንኙነቶችን ለማጠናከር (ማህበሩ ከአርዳይታ ጋር የተያያዙ ግለሰቦች መካከል ያለውን የአንድነት፣ የወንድማማችነት እና የእህትማማችነት ትስስር ለማስጠበቅ እና ለማጠናከር ይመሰረታል።)',
            oromo:
                'Sababoota Maaliif Waldaan Hundeeffamaa? a. Tokkummaa Eeguufi Hariiroo Yeroo Dheeraa Cimsuuf (Waldaan kun namoota Ardaita waliin walqabatan gidduutti tokkummaa, obbolummaa fi obboleettiummaa jabeessuufi eeguuf hundeeffameera.)',
          ),
          _buildRationaleCard(
            context,
            number: '02',
            title: 'To Provide Organized and Transparent Community Support',
            english:
                'The Association is established to create a transparent and organized system through which members can collectively support education, health, vulnerable groups, and other social priorities in a fair and accountable manner.',
            amharic:
                'የተደራጀ እና ግልፅ የማህበረሰብ ድጋፍ ለማቅረብ (ማህበሩ አባላት በተባበሩ መንገድ ትምህርት፣ ጤና፣ ለተጋለጡ ቡድኖች እና ሌሎች ማህበራዊ ቅድሚያዎች ድጋፍ እንዲያደርጉ ፍትሃዊ እና ተጠያቂ የሆነ ግልፅ እና የተደራጀ ስርዓት ለመፍጠር ይመሰረታል።)',
            oromo:
                'Deeggarsa Hawaasaa Qindaa’aa fi Iftoomina Qabu Kennuuf (Waldaan kun sirna iftoominaa fi qindoomina qabu ijaaruuf hundeeffameera; kanaan miseensonni haala haqaa fi itti gaafatamummaa qabuun barnoota, fayyaa, gareewwan miidhamoo fi dhimma hawaasummaa biroo irratti waloon deeggarsa kennu danda’u.)',
          ),
          _buildRationaleCard(
            context,
            number: '03',
            title: 'To Promote Sustainable Social and Economic Development',
            english:
                'The Association is established to mobilize resources, knowledge, and networks to promote education, health, environmental protection, livelihood improvement, and social care in a coordinated way.',
            amharic:
                'ዘላቂ ማህበራዊ እና ኢኮኖሚያዊ ልማት ለማበረታታት (ማህበሩ ትምህርት፣ ጤና፣ አካባቢ ጥበቃ፣ የኑሮ ማሻሻያ እና ማህበራዊ እንክብካቤ በተቀናጀ መንገድ እንዲጎለብቱ ሀብት፣ እውቀት እና አውታረ መረቦችን ለማቅረብ ይመሰረታል።)',
            oromo:
                'Misooma Hawaasummaa fi Dinagdee Itti Fufiinsa Qabu Jajjabeessuuf (Waldaan kun qabeenya, beekumsa fi walitti hidhamiinsa namootaa kakaasuudhaan barnoota, fayyaa, eegumsa naannoo, fooyya’iinsa jireenyaa fi tajaajila hawaasummaa haala qindaa’een guddisuuf hundeeffameera.)',
          ),
          _buildRationaleCard(
            context,
            number: '04',
            title:
                'To Ensure Inclusiveness Across Location, Income, and Background',
            english:
                'The Association is established to provide an inclusive platform where all eligible members, regardless of location or economic capacity, can participate meaningfully and contribute according to their ability.',
            amharic:
                'በአካባቢ፣ በገቢ እና በመሠረታዊ አይነቶች ሁሉ ላይ አካታችነትን ለማረጋገጥ (ማህበሩ ሁሉም ብቁ አባላት ከየትኛውም አካባቢ ወይም የኢኮኖሚ አቅም ምንም ሆነ ተሳትፎ እንዲያደርጉ እና በአቅማቸው መሰረት እንዲያበረክቱ የሚያስችል አካታች መድረክ ለመፍጠር ይመሰረታል።)',
            oromo:
                'Hirmaachisummaa Hunda Hammataa Mirkaneessuuf (Waldaan kun miseensonni ulaagaa guutan hundi, bakka jireenyaa ykn haala dinagdee isaanii osoo hin ilaalin, hiika qabuun akka hirmaatanii fi dandeettii isaanii irratti hundaa’uun akka gumaachan waltajjii hunda hammataa ta’e uumuuf hundeeffameera.)',
          ),
          _buildRationaleCard(
            context,
            number: '05',
            title: 'To Build a Foundation for Future Generations',
            english:
                'The Association is established not only for present needs but also to create a lasting institutional foundation that promotes intergenerational solidarity and long-term community resilience.',
            amharic:
                'ለወደፊት ትውልዶች መሠረት ለመገንባት (ማህበሩ የዛሬን ፍላጎቶች ብቻ ሳይሆን ትውልድ ተሻጋሪ አንድነትን እና የረጅም ጊዜ የማህበረሰብ ብርታትን የሚያበረታታ ዘላቂ የተቋማዊ መሠረት ለመፍጠር ይመሰረታል።)',
            oromo:
                'Bu’uura Dhaloota Itti Aanuu Ijaaruuuf (Waldaan kun fedhii yeroo ammaa qofaaf osoo hin taane, tokkummaa dhaloota gidduutti jiru cimsuufi jabina hawaasaa yeroo dheeraa tiksu bu’uura dhaabbataa fi waaraa uumuuf hundeeffameera.)',
          ),
          const SizedBox(height: 48),
          Text(
            'Organizational Structure',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 48),

          // Tree Structure
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  _buildTreeLevel(
                    'Chairperson',
                    'Dejen Kuma(PhD)',
                    Icons.person_rounded,
                    isRoot: false,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 1032,
                    height: 250,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 264,
                          top: 44,
                          child: _buildTreeLevel(
                            'Vice Chairperson',
                            'Yasin Tufa',
                            Icons.person_outline_rounded,
                            width: 230,
                          ),
                        ),
                        Positioned(
                          left: 516,
                          top: 0,
                          child: _buildVerticalLine(height: 230),
                        ),
                        Positioned(
                          left: 494,
                          top: 134,
                          child: Container(
                            width: 22,
                            height: 2,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        Positioned(
                          left: 120,
                          top: 230,
                          child: Container(
                            width: 792,
                            height: 2,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        Positioned(
                          left: 120,
                          top: 230,
                          child: _buildVerticalLine(height: 20),
                        ),
                        Positioned(
                          left: 384,
                          top: 230,
                          child: _buildVerticalLine(height: 20),
                        ),
                        Positioned(
                          left: 648,
                          top: 230,
                          child: _buildVerticalLine(height: 20),
                        ),
                        Positioned(
                          left: 912,
                          top: 230,
                          child: _buildVerticalLine(height: 20),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTreeBranchWithRightChild(
                        title: 'Operational and Admin Lead',
                        subtitle: 'Dr.Tefaye Megersa',
                        icon: Icons.admin_panel_settings_rounded,
                        childTitle: 'Operational Support',
                        childSubtitle: '',
                        childIcon: Icons.support_agent_rounded,
                        showChildDivider: false,
                        customChildContent: _buildIndividualBulletList([
                          'Bizuayehu Chala',
                          'Cheru Fano',
                        ]),
                      ),
                      const SizedBox(width: 24),
                      _buildTreeBranchWithRightChild(
                        title: 'Treasurer',
                        subtitle: 'Dereje Tilahun',
                        icon: Icons.account_balance_wallet_rounded,
                        childTitle: 'Treasurer Support',
                        childSubtitle: 'Faruk Teshale',
                        childIcon: Icons.payments_rounded,
                      ),
                      const SizedBox(width: 24),
                      _buildTreeBranchWithRightChild(
                        title: 'Secretary and PR lead',
                        subtitle: 'Abdulkadir Kaltiso',
                        icon: Icons.edit_note_rounded,
                        childTitle: 'Secretary and PR support',
                        childSubtitle: 'Beshir Edao',
                        childIcon: Icons.support_agent_rounded,
                      ),
                      const SizedBox(width: 24),
                      _buildTreeBranchWithRightChild(
                        title: 'Legal Lead',
                        subtitle: 'Habib Amano',
                        icon: Icons.gavel_rounded,
                        childTitle: 'Legal subcommittee',
                        childSubtitle: '',
                        childIcon: Icons.balance_rounded,
                        showChildDivider: false,
                        customChildContent: _buildIndividualBulletList([
                          'Asrat Abdo',
                          'Fitsum Husen',
                          'Mohammed Hayato',
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 64),
          Text(
            'Authority & Governance',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 24),
          const Text(
            'The NGO Establishment Committee (NEsCo) serves as a temporary, mandate-driven body entrusted by the General Assembly to lead and coordinate the establishment of the Association. Its primary role is to facilitate all preparatory processes required for legal registration and initial operational readiness, including drafting foundational documents, guiding consultative discussions, mobilizing membership, and ensuring compliance with applicable legal requirements. NEsCo exercises delegated authority to make timely decisions necessary for these purposes, within the scope defined by the General Assembly, and operates in a transparent and accountable manner. Its mandate concludes upon the formal establishment of the Association and the transition to the duly constituted governing body.',
            style: TextStyle(fontSize: 18, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualBulletList(List<String> names) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: names
          .map(
            (name) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTreeBranchWithRightChild({
    required String title,
    String subtitle = '',
    required IconData icon,
    required String childTitle,
    String childSubtitle = '',
    required IconData childIcon,
    bool showChildDivider = true,
    Widget? customChildContent,
  }) {
    return SizedBox(
      width: 240,
      child: Column(
        children: [
          _buildTreeLevel(title, subtitle, icon, width: 230),
          SizedBox(
            width: 240,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(child: _buildVerticalLine(height: 50)),
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 5, right: 5),
                  child: _buildTreeLevel(
                    childTitle,
                    childSubtitle,
                    childIcon,
                    width: 230,
                    height: null,
                    showCustomDivider: showChildDivider,
                    customContent: customChildContent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeLevel(
    String title,
    String subtitle,
    IconData icon, {
    bool isRoot = false,
    double width = 230,
    double? height = 180,
    String? imagePath,
    bool showCustomDivider = true,
    Widget? customContent,
  }) {
    return Container(
      width: width,
      height: height,
      constraints: height == null ? const BoxConstraints(minHeight: 180) : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isRoot ? const Color(0xFF2E7D32) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E7D32), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          imagePath != null
              ? CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage(imagePath),
                  onBackgroundImageError: (exception, stackTrace) =>
                      const Icon(Icons.person_rounded, size: 32),
                )
              : Icon(
                  icon,
                  color: isRoot ? Colors.white : const Color(0xFF2E7D32),
                  size: 32,
                ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isRoot ? Colors.white : Colors.black87,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isRoot ? Colors.white70 : Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (customContent != null) ...[
            const SizedBox(height: 12),
            if (showCustomDivider)
              const Divider(height: 1, color: Colors.green),
            const SizedBox(height: 8),
            customContent,
          ],
        ],
      ),
    );
  }

  Widget _buildVerticalLine({double height = 40}) {
    return Container(height: height, width: 2, color: const Color(0xFF2E7D32));
  }

  Widget _buildRationaleCard(
    BuildContext context, {
    required String number,
    required String title,
    required String english,
    required String amharic,
    required String oromo,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.green.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(english, style: const TextStyle(fontSize: 16, height: 1.55)),
            const SizedBox(height: 14),
            Text(amharic, style: const TextStyle(fontSize: 16, height: 1.7)),
            const SizedBox(height: 14),
            Text(
              oromo,
              style: const TextStyle(
                fontSize: 16,
                height: 1.65,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WhatWeDoTab extends StatelessWidget {
  const WhatWeDoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vision', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 16),
          const Text(
            'To build a healthy, educated, environmentally sustainable, and economically empowered community where every individual has the opportunity to thrive with dignity and unity.',
            style: TextStyle(fontSize: 18, height: 1.6),
          ),
          const SizedBox(height: 40),
          Text('Mission', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 16),
          const Text(
            'Ardaita and Surrounding Charity Association is a charitable organization committed to improving the quality of life in our community by:',
            style: TextStyle(fontSize: 18, height: 1.6),
          ),
          const SizedBox(height: 24),
          _buildListItem(
            'Promoting accessible and sustainable public health initiatives.',
            Icons.health_and_safety_outlined,
          ),
          _buildListItem(
            'Expanding equitable access to quality education and lifelong learning opportunities.',
            Icons.school_outlined,
          ),
          _buildListItem(
            'Protecting and restoring the environment through community-led conservation efforts.',
            Icons.eco_outlined,
          ),
          _buildListItem(
            'Supporting small-scale economic activities and entrepreneurship to enhance household income and self-reliance.',
            Icons.trending_up_outlined,
          ),
          const SizedBox(height: 40),
          Text('Core Values', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 16),
          _buildCoreValue(
            '1. Unity',
            'We believe collective effort and community collaboration are the foundation of sustainable development.',
          ),
          _buildCoreValue(
            '2. Integrity',
            'We operate with transparency, accountability, and ethical responsibility in all our actions.',
          ),
          _buildCoreValue(
            '3. Compassion',
            'We serve with empathy, prioritizing the needs of vulnerable and underserved populations.',
          ),
          _buildCoreValue(
            '4. Empowerment',
            'We strengthen individuals and families by building skills, knowledge, and economic opportunities.',
          ),
          _buildCoreValue(
            '5. Sustainability',
            'We promote environmentally responsible and long-term solutions that benefit future generations.',
          ),
          _buildCoreValue(
            '6. Equity and Inclusion',
            'We ensure equal opportunities regardless of gender, age, background, or economic status.',
          ),
          _buildCoreValue(
            '7. Innovation',
            'We embrace creative, practical, and locally driven approaches to solving community challenges.',
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 18, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreValue(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 18, height: 1.6)),
        ],
      ),
    );
  }
}

class InitiativesTab extends StatelessWidget {
  const InitiativesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> initiatives = [
      {
        'title': 'Environment protection',
        'subtitle': 'Sustainability & Conservation',
        'icon': Icons.eco_rounded,
        'activities': [
          'Community reforestation projects',
          'Sustainable water resource management',
          'Environment awareness workshops',
          'Waste reduction initiatives',
        ],
      },
      {
        'title': 'Education',
        'subtitle': 'Learning & Development',
        'icon': Icons.school_rounded,
        'activities': [
          'Primary school support programs',
          'Vocational training for youth',
          'Digital literacy classes',
          'Educational resource distribution',
        ],
      },
      {
        'title': 'Health',
        'subtitle': 'Public Wellness & Safety',
        'icon': Icons.health_and_safety_rounded,
        'activities': [
          'Public health awareness campaigns',
          'Mental wellness support sessions',
          'Preventive care education',
          'Medical resource facilitation',
        ],
      },
      {
        'title': 'Economic activities',
        'subtitle': 'Growth & Empowerment',
        'icon': Icons.trending_up_rounded,
        'activities': [
          'Micro-finance group support',
          'Small business mentorship',
          'Entrepreneurship training',
          'Agricultural development support',
        ],
      },
      {
        'title': 'Social Care',
        'subtitle': 'Care for Vulnerable children & elderly',
        'icon': Icons.volunteer_activism_rounded,
        'activities': [
          'Protect Children & Elderly',
          'Support At-Risk Children',
          'Assist Vulnerable Elderly',
        ],
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo at the top
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/New_Logo.jpg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Our Initiatives',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500,
              mainAxisExtent: 320,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: initiatives.length,
            itemBuilder: (context, index) {
              final item = initiatives[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.green.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item['icon'],
                              color: Colors.green,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item['subtitle'],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Core Activities:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (item['activities'] as List).length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item['activities'][i],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> initiatives = [
      {
        'title': 'Environment protection',
        'subtitle': 'Sustainability & Conservation',
        'icon': Icons.eco_rounded,
        'activities': [
          'Community reforestation projects',
          'Sustainable water resource management',
          'Environment awareness workshops',
          'Waste reduction initiatives',
        ],
      },
      {
        'title': 'Education',
        'subtitle': 'Learning & Development',
        'icon': Icons.school_rounded,
        'activities': [
          'Primary school support programs',
          'Vocational training for youth',
          'Digital literacy classes',
          'Educational resource distribution',
        ],
      },
      {
        'title': 'Health',
        'subtitle': 'Public Wellness & Safety',
        'icon': Icons.health_and_safety_rounded,
        'activities': [
          'Public health awareness campaigns',
          'Mental wellness support sessions',
          'Preventive care education',
          'Medical resource facilitation',
        ],
      },
      {
        'title': 'Economic activities',
        'subtitle': 'Growth & Empowerment',
        'icon': Icons.trending_up_rounded,
        'activities': [
          'Micro-finance group support',
          'Small business mentorship',
          'Entrepreneurship training',
          'Agricultural development support',
        ],
      },
      {
        'title': 'Social Care',
        'subtitle': 'Care for Vulnerable children & elderly',
        'icon': Icons.volunteer_activism_rounded,
        'activities': [
          'Protect Children & Elderly',
          'Support At-Risk Children',
          'Assist Vulnerable Elderly',
        ],
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending Initiatives',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500,
              mainAxisExtent: 320,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: initiatives.length,
            itemBuilder: (context, index) {
              final item = initiatives[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.green.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item['icon'],
                              color: Colors.green,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item['subtitle'],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Core Activities:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (item['activities'] as List).length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item['activities'][i],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  static const List<Map<String, String>> _resources = [
    {
      'name': 'Ardaita_English Vesrion.docx',
      'assetPath': 'assets/Ardaita_English Vesrion.docx',
      'description': 'Community development document in English',
    },
    {
      'name': '1.doc',
      'assetPath': 'assets/1.doc',
      'description': 'Board establishement document in Amharic',
    },
    {
      'name': '2.docx',
      'assetPath': 'assets/2.docx',
      'description': 'Board establishement document in Amharic',
    },
    {
      'name': '3.docx',
      'assetPath': 'assets/3.docx',
      'description': 'Board establishement document in Amharic',
    },
    {
      'name': 'Members_Mapping_ and_Registration_Form_04Feb26.xlsx',
      'assetPath': 'assets/Members_Mapping_ and_Registration_Form_04Feb26.xlsx',
      'description': 'Member mapping and registration spreadsheet',
    },
  ];

  static Uri buildDownloadUri(String assetPath) {
    final fileName = assetPath.replaceFirst('assets/', '');
    final encodedFileName = Uri.encodeComponent(fileName);
    return Uri.parse(
      'https://chalekuma-rgb.github.io/ardaita_website/assets/$encodedFileName',
    );
  }

  static Uri buildViewerUri(String assetPath) {
    final rawUri = buildDownloadUri(assetPath);
    final fileName = rawUri.pathSegments.last.toLowerCase();

    if (fileName.endsWith('.pdf')) {
      return Uri.parse(
        'https://docs.google.com/viewer?embedded=true&url=${Uri.encodeComponent(rawUri.toString())}',
      );
    }

    if (fileName.endsWith('.doc') ||
        fileName.endsWith('.docx') ||
        fileName.endsWith('.xls') ||
        fileName.endsWith('.xlsx')) {
      return Uri.parse(
        'https://view.officeapps.live.com/op/embed.aspx?src=${Uri.encodeComponent(rawUri.toString())}',
      );
    }

    return rawUri;
  }

  Future<void> _openResource(BuildContext context, String assetPath) async {
    final resourceUri = buildViewerUri(assetPath);
    final opened = await launchUrl(resourceUri, webOnlyWindowName: '_blank');

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the selected resource.')),
      );
    }
  }

  Future<void> _downloadResource(BuildContext context, String assetPath) async {
    final downloadUri = buildDownloadUri(assetPath);
    final fileName = assetPath.replaceFirst('assets/', '');

    if (kIsWeb) {
      final anchor = html.AnchorElement(href: downloadUri.toString())
        ..target = '_blank'
        ..rel = 'noopener'
        ..setAttribute('download', fileName);
      html.document.body?.children.add(anchor);
      anchor.click();
      anchor.remove();
      return;
    }

    final opened = await launchUrl(downloadUri, webOnlyWindowName: '_blank');

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to download the selected resource.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 10),
            child: Text(
              'Documents',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              itemCount: _resources.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final resource = _resources[index];
                final fileName = resource['name']!;
                final assetPath = resource['assetPath']!;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF2E7D32),
                    child: Icon(Icons.description, color: Colors.white),
                  ),
                  title: Text(
                    fileName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(resource['description']!),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Open document',
                        icon: const Icon(
                          Icons.open_in_new_rounded,
                          color: Colors.green,
                        ),
                        onPressed: () => _openResource(context, assetPath),
                      ),
                      IconButton(
                        tooltip: 'Download document',
                        icon: const Icon(
                          Icons.download_rounded,
                          color: Colors.green,
                        ),
                        onPressed: () => _downloadResource(context, assetPath),
                      ),
                    ],
                  ),
                  onTap: () => _openResource(context, assetPath),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  void _openImageViewer(
    BuildContext context,
    String imagePath,
    String imageName,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: Colors.black87,
          child: SizedBox(
            width: screenWidth * 0.9,
            height: screenHeight * 0.82,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Center(
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.white70,
                                    size: 48,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Text(
                    imageName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
    final List<Map<String, String>> images = [
      {'path': 'assets/Home_page.jpg', 'name': 'Home_page'},
      {
        'path': 'assets/The Chair and his Vice.jpg',
        'name': 'The Chair and his Vice.jpg',
      },
      {'path': 'assets/Ardaita.jpg', 'name': 'Ardaita'},
      {'path': 'assets/New_Logo.jpg', 'name': 'New logo'},
      {'path': 'assets/Finance Team.jpg', 'name': 'Finance Team'},
      {'path': 'assets/Legal Team.jpg', 'name': 'Legal Team'},
      {'path': 'assets/Operational Team.jpg', 'name': 'Operational Team'},
      {
        'path': 'assets/Public relations team.jpg',
        'name': 'Public relations team',
      },
      {'path': 'assets/Team Adama.jpg', 'name': 'Team Adama'},
      {
        'path': 'assets/Team Addis Ababa (2).jpg',
        'name': 'Team Addis Ababa (2)',
      },
      {'path': 'assets/Team Addis Ababa.jpg', 'name': 'Team Addis Ababa'},
      {'path': 'assets/Team Adraita.jpg', 'name': 'Team Adraita'},
      {'path': 'assets/Team Ardaita (2).jpg', 'name': 'Team Ardaita (2)'},
      {'path': 'assets/Team Ardaita.jpg', 'name': 'Team Ardaita'},
      {'path': 'assets/Team Assela.jpg', 'name': 'Team Assela'},
      {'path': 'assets/Team Hawasa.jpg', 'name': 'Team Hawasa'},
    ];

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Visuals',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.5,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final imagePath = images[index]['path']!;
                final imageName = images[index]['name']!;

                return InkWell(
                  onTap: () => _openImageViewer(context, imagePath, imageName),
                  borderRadius: BorderRadius.circular(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: Colors.green.shade50,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 40,
                                  color: Colors.green.shade200,
                                ),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                imageName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;
  String? _feedbackMessage;
  bool _submissionSucceeded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _feedbackMessage = null;
    });

    try {
      await supabase.from('contact_messages').insert({
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'message': _messageController.text.trim(),
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _submissionSucceeded = true;
        _feedbackMessage = 'Your message has been sent successfully.';
      });

      _formKey.currentState?.reset();
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _submissionSucceeded = false;
        _feedbackMessage = _formatError(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Us', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContactMethod(
                      Icons.location_on_rounded,
                      'Our Head Office',
                      'Addis Ababa, Ethiopia',
                    ),
                    const SizedBox(height: 24),
                    _buildContactMethod(
                      Icons.email_rounded,
                      'Email Us',
                      'info@ardaita-asca.org',
                    ),
                    const SizedBox(height: 24),
                    _buildContactMethod(
                      Icons.phone_rounded,
                      'Call Us',
                      '+251 911 000 000',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_feedbackMessage != null) ...[
                        _buildFeedbackBanner(
                          _feedbackMessage!,
                          success: _submissionSucceeded,
                        ),
                        const SizedBox(height: 24),
                      ],
                      const Text(
                        'Send us a message',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => FormValidators.minLength(
                                value,
                                'Full name',
                                2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                border: OutlineInputBorder(),
                              ),
                              validator: FormValidators.email,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _messageController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                labelText: 'Message',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => FormValidators.minLength(
                                value,
                                'Message',
                                10,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                _isSubmitting
                                    ? 'Submitting...'
                                    : 'Submit Message',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBanner(String message, {required bool success}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: success ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: success ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: success ? Colors.green.shade900 : Colors.orange.shade900,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatError(Object error) {
    final message = error.toString();
    return message.startsWith('Bad state: ')
        ? message.substring('Bad state: '.length)
        : message;
  }

  Widget _buildContactMethod(IconData icon, String title, String detail) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 28),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              detail,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }
}

class DonatePage extends StatelessWidget {
  const DonatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Support Our Cause',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 24),
          const Text(
            'Until the website integration is complete, please make your donation to the following account:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Column(
              children: [
                Text(
                  'Account Name: Ardaita and Surrounding Charity Association',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'CBE: 1000758051367',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Your generous donation helps us continue our mission to empower the Ardaita community through education, health, and sustainable development.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(
    BuildContext context,
    String amount,
    String description,
  ) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            amount,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class BecomeVolunteerPage extends StatefulWidget {
  const BecomeVolunteerPage({super.key});

  @override
  State<BecomeVolunteerPage> createState() => _BecomeVolunteerPageState();
}

class _BecomeVolunteerPageState extends State<BecomeVolunteerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _motivationController = TextEditingController();
  String? selectedInitiative;
  bool _isSubmitting = false;
  String? _feedbackMessage;
  bool _submissionSucceeded = false;
  final List<String> initiatives = [
    'Environment protection',
    'Education',
    'Health',
    'Economic activities',
    'Social Care',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    if (selectedInitiative == null || selectedInitiative!.trim().isEmpty) {
      setState(() {
        _submissionSucceeded = false;
        _feedbackMessage = 'Please choose an initiative before submitting.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _feedbackMessage = null;
    });

    try {
      await supabase.from('volunteer_applications').insert({
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'initiative': selectedInitiative!.trim(),
        'motivation': _motivationController.text.trim(),
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _submissionSucceeded = true;
        _feedbackMessage =
            'Your volunteer application has been submitted successfully.';
        selectedInitiative = null;
      });

      _formKey.currentState?.reset();
      _nameController.clear();
      _emailController.clear();
      _motivationController.clear();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _submissionSucceeded = false;
        _feedbackMessage = _formatError(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Become a Volunteer',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_feedbackMessage != null) ...[
                  _buildFeedbackBanner(
                    _feedbackMessage!,
                    success: _submissionSucceeded,
                  ),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'Join our community of change-makers',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            FormValidators.minLength(value, 'Full name', 2),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                        ),
                        validator: FormValidators.email,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Choose Initiative',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: selectedInitiative,
                        items: initiatives.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        validator: (value) =>
                            FormValidators.requiredField(value, 'Initiative'),
                        onChanged: (newValue) {
                          setState(() {
                            selectedInitiative = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _motivationController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Tell us what inspired you to volunteer',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            FormValidators.minLength(value, 'Motivation', 10),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: Text(
                          _isSubmitting
                              ? 'Submitting...'
                              : 'Submit Application',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBanner(String message, {required bool success}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: success ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: success ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: success ? Colors.green.shade900 : Colors.orange.shade900,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatError(Object error) {
    final message = error.toString();
    return message.startsWith('Bad state: ')
        ? message.substring('Bad state: '.length)
        : message;
  }
}
