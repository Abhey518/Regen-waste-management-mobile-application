import 'package:flutter/material.dart';

class AreaSetupScreen extends StatefulWidget {
  const AreaSetupScreen({super.key});

  @override
  State<AreaSetupScreen> createState() => _AreaSetupScreenState();
}

class _AreaSetupScreenState extends State<AreaSetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Setup'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Icon(
              Icons.location_on,
              size: 80,
              color: Color.fromARGB(255, 2, 139, 7),
            ),
            const SizedBox(height: 24),
            const Text(
              'Location Information',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 2, 139, 7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your location information from registration is used to show personalized garbage pickup schedules for your area.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Info Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info, color: Colors.blue, size: 32),
                  const SizedBox(height: 12),
                  const Text(
                    'Location-Based Schedules',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your garbage pickup schedule is automatically shown based on the Province, District, and Local Authority you provided during registration.',
                    style: TextStyle(color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Feature List
            const Column(
              children: [
                _FeatureItem(
                  icon: Icons.schedule,
                  title: 'Personalized Schedule',
                  description: 'View pickup dates for your specific location',
                ),
                SizedBox(height: 16),
                _FeatureItem(
                  icon: Icons.notifications,
                  title: 'Pickup Reminders',
                  description: 'Get notified before collection days',
                ),
                SizedBox(height: 16),
                _FeatureItem(
                  icon: Icons.recycling,
                  title: 'Waste Type Info',
                  description: 'Know what type of waste to put out',
                ),
              ],
            ),

            const Spacer(),

            // Go to Profile Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // You can navigate to profile screen here if needed
                  // Navigator.pushNamed(context, '/profile');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 139, 7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'View Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Skip Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Continue without location',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color.fromARGB(255, 2, 139, 7),
            size: 20,
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
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
