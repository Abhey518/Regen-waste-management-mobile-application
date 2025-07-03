import 'package:flutter/material.dart';

class MenuWindow extends StatelessWidget {
  const MenuWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Disposal Guide', textAlign: TextAlign.center),
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 2, 139, 7),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWasteCategory(
            icon: Icons.local_drink,
            title: 'Plastic Waste',
            items: [
              _buildWasteItem(
                  'PET Bottles',
                  'Rinse and flatten bottles. Remove caps (recycle separately).',
                  '♻️ Recyclable'),
              _buildWasteItem(
                  'Plastic Bags',
                  'Return to grocery stores or special collection points.',
                  '⚠️ Special Recycling'),
              _buildWasteItem(
                  'Food Containers',
                  'Clean thoroughly. Check local guidelines for numbered plastics.',
                  '♻️ Conditionally Recyclable'),
            ],
          ),
          const SizedBox(height: 24),
          _buildWasteCategory(
            icon: Icons.description,
            title: 'Paper & Cardboard',
            items: [
              _buildWasteItem(
                  'Newspapers/Magazines',
                  'Keep dry and clean. Bundle with string or place in paper bags.',
                  '♻️ Highly Recyclable'),
              _buildWasteItem(
                  'Cardboard Boxes',
                  'Flatten boxes. Remove tape and plastic liners.',
                  '♻️ Recyclable'),
              _buildWasteItem(
                  'Waxed Cartons',
                  'Check local facilities - some accept milk/juice cartons.',
                  '📍 Location Dependent'),
            ],
          ),
          const SizedBox(height: 24),
          _buildWasteCategory(
            icon: Icons.kitchen,
            title: 'Organic Waste',
            items: [
              _buildWasteItem(
                  'Food Scraps',
                  'Compost at home or use municipal composting.',
                  '🌱 Compostable'),
              _buildWasteItem(
                  'Yard Waste',
                  'Separate leaves, grass clippings for composting.',
                  '🌱 Compostable'),
              _buildWasteItem(
                  'Biodegradable Plastics',
                  'Only compost in industrial facilities, not home compost.',
                  '⚠️ Check Labels'),
            ],
          ),
          const SizedBox(height: 24),
          _buildWasteCategory(
            icon: Icons.computer,
            title: 'E-Waste',
            items: [
              _buildWasteItem(
                  'Batteries',
                  'Never throw in trash. Use special collection points.',
                  '☢️ Hazardous'),
              _buildWasteItem(
                  'Old Electronics',
                  'Donate if working. Otherwise use e-waste recyclers.',
                  '🔌 Special Handling'),
              _buildWasteItem(
                  'Light Bulbs',
                  'CFLs go to hazardous waste. LEDs can sometimes be recycled.',
                  '💡 Type Matters'),
            ],
          ),
          const SizedBox(height: 24),
          _buildWasteCategory(
            icon: Icons.construction,
            title: 'Hazardous Waste',
            items: [
              _buildWasteItem(
                  'Paint & Chemicals',
                  'Never pour down drains. Use hazardous waste collection.',
                  '☢️ Dangerous'),
              _buildWasteItem(
                  'Medical Waste',
                  'Needles/meds require special disposal programs.',
                  '⚕️ Special Handling'),
              _buildWasteItem(
                  'Automotive Fluids',
                  'Take to auto shops or hazardous waste facilities.',
                  '🚗 Special Collection'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWasteCategory({
    required IconData icon,
    required String title,
    required List<Widget> items,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    color: const Color.fromARGB(255, 2, 139, 7), size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 2, 139, 7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildWasteItem(String title, String description, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status.contains('♻️')
                      ? Colors.green[50]
                      : status.contains('⚠️')
                          ? Colors.orange[50]
                          : Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: status.contains('♻️')
                        ? Colors.green
                        : status.contains('⚠️')
                            ? Colors.orange
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const Divider(height: 24, thickness: 1),
        ],
      ),
    );
  }
}
