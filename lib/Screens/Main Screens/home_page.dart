import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../sub Screens/bin_status_window.dart';
import '../sub Screens/notifications_window.dart';
import '../sub Screens/profile_window.dart';
import '../sub Screens/report_dumping_window.dart';
import '../sub Screens/truck_location_map.dart';
import '../Main Screens/Navigation Bar/menu_window.dart';
import '../Main Screens/Navigation Bar/articles_window.dart';
import '../Main Screens/Navigation Bar/kids_window.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REGEN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 7, 168, 12),
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color.fromARGB(255, 2, 139, 7),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int totalPoints = 750;
  int maxPoints = 1000;

  @override
  Widget build(BuildContext context) {
    double progress = totalPoints / maxPoints;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'REGEN',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, size: 32),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationsWindow()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, size: 32),
            onPressed: () {
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel:
                    MaterialLocalizations.of(context).modalBarrierDismissLabel,
                barrierColor: Colors.black54,
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    )),
                    child: const ProfileWindow(),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildGarbagePickupSection(),
            const SizedBox(
                height: 20), // Added this SizedBox for consistent spacing
            _buildPointsSystem(progress),
            const SizedBox(height: 16), // This spacing matches the one above
            _buildFeatureGrid(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MenuWindow()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ArticlesWindow()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KidsWindow()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu, size: 28),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article, size: 28),
            label: 'Articles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face, size: 28),
            label: 'Kids',
          ),
        ],
      ),
    );
  }

  Widget _buildGarbagePickupSection() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextPickupDay = DateTime(now.year, now.month, now.day + 2);
    final isPickupToday = now.weekday == DateTime.wednesday;
    final garbageType = isPickupToday ? "Plastic/Polythene" : "Organic Waste";
    final nextGarbageType = "Organic Waste";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 229, 250, 229),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping,
                  size: 28, color: Color.fromARGB(255, 2, 139, 7)),
              const SizedBox(width: 8),
              const Text(
                'GARBAGE PICKUP SCHEDULE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 2, 139, 7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Today: ${DateFormat('MMMM d, y').format(today)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isPickupToday
                          ? const Color.fromARGB(255, 220, 255, 220)
                          : const Color.fromARGB(255, 255, 230, 230),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPickupToday
                            ? const Color.fromARGB(255, 100, 200, 100)
                            : const Color.fromARGB(255, 200, 100, 100),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPickupToday ? Icons.recycling : Icons.block,
                          size: 20,
                          color: isPickupToday
                              ? const Color.fromARGB(255, 0, 128, 0)
                              : const Color.fromARGB(255, 200, 0, 0),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isPickupToday ? garbageType : 'No Collection',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isPickupToday
                                ? const Color.fromARGB(255, 0, 128, 0)
                                : const Color.fromARGB(255, 200, 0, 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Next pickup: ${DateFormat('MMMM d').format(nextPickupDay)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 220, 240, 255),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color.fromARGB(255, 100, 150, 200),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.delete,
                          size: 20,
                          color: Color.fromARGB(255, 0, 100, 200),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          nextGarbageType,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 100, 200),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showCalendarDialog(context);
                      },
                      icon: const Icon(Icons.calendar_month,
                          size: 20, color: Color.fromARGB(255, 2, 139, 7)),
                      label: const Text(
                        'View Schedule',
                        style: TextStyle(
                          color: Color.fromARGB(255, 2, 139, 7),
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                              color: Color.fromARGB(255, 2, 139, 7)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TruckLocationMap(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.location_on,
                          size: 20, color: Color.fromARGB(255, 2, 139, 7)),
                      label: const Text(
                        'Truck Location',
                        style: TextStyle(
                          color: Color.fromARGB(255, 2, 139, 7),
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                              color: Color.fromARGB(255, 2, 139, 7)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCalendarDialog(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final firstDay = DateTime(year, month, 1);
    final firstWeekday = firstDay.weekday;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    List<Widget> calendarItems = [];

    // Add weekday headers
    calendarItems.addAll([
      const Center(
          child: Text('MON', style: TextStyle(fontWeight: FontWeight.bold))),
      const Center(
          child: Text('TUE', style: TextStyle(fontWeight: FontWeight.bold))),
      const Center(
          child: Text('WED', style: TextStyle(fontWeight: FontWeight.bold))),
      const Center(
          child: Text('THU', style: TextStyle(fontWeight: FontWeight.bold))),
      const Center(
          child: Text('FRI', style: TextStyle(fontWeight: FontWeight.bold))),
      const Center(
          child: Text('SAT', style: TextStyle(fontWeight: FontWeight.bold))),
      const Center(
          child: Text('SUN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(200, 224, 5, 5),
              ))),
    ]);

    // Add blank spaces for days before the 1st of the month
    for (int i = 1; i < firstWeekday; i++) {
      calendarItems.add(const SizedBox());
    }

    // Add the days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final isPickupDay =
          DateTime(year, month, day).weekday == DateTime.wednesday;
      calendarItems.add(
        Center(
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isPickupDay ? Colors.green.withValues(alpha: 0.2) : null,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$day',
              style: TextStyle(
                color: isPickupDay
                    ? Colors.green
                    : const Color.fromARGB(255, 29, 39, 25),
                fontWeight: isPickupDay ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Collection Calendar'),
            Text(
              DateFormat('MMMM y').format(DateTime(year, month)),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: calendarItems,
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.info, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Green days are collection days'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsSystem(double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'POINTS SYSTEM',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color.fromARGB(255, 2, 139, 7),
                ),
              ),
              Text(
                'Level 2',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalPoints PTS',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 2, 139, 7),
                ),
              ),
              Text(
                '${maxPoints - totalPoints} to next level',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: const Color.fromARGB(255, 2, 139, 7),
            minHeight: 12,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPointsButton('Point History', Icons.history),
              _buildPointsButton('Redeem', Icons.card_giftcard),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsButton(String text, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 20, color: const Color.fromARGB(255, 2, 139, 7)),
      label: Text(
        text,
        style: const TextStyle(color: Color.fromARGB(255, 2, 139, 7)),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color.fromARGB(255, 2, 139, 7)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 1.2,
      children: [
        _buildFeatureItem('Bin Status', Icons.delete_outline, ''),
        _buildFeatureItem('Report Illegal Dumping ', Icons.report_problem, ''),
      ],
    );
  }

  Widget _buildFeatureItem(String title, IconData icon, String details) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          if (title == 'Bin Status') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BinStatusWindow()),
            );
          } else if (title == 'Report Illegal Dumping ') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ReportDumpingWindow()),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: Colors.green),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (details.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  details,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
