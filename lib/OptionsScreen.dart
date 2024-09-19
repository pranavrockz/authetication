import 'package:flutter/material.dart';

void main() {
  runApp(const OptionsScreen());
}

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileSelectionScreen(),
    );
  }
}

class ProfileSelectionScreen extends StatelessWidget {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Please select your profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ProfileOption(
              icon: Icons.local_shipping,
              title: 'Shipper',
              description: 'Lorem ipsum dolor sit amet, consectetur adipiscing.',
              onTap: () {
                // Handle shipper selection
                print('Shipper selected');
              },
            ),
            const SizedBox(height: 20),
            ProfileOption(
              icon: Icons.directions_car,
              title: 'Transporter',
              description: 'Lorem ipsum dolor sit amet, consectetur adipiscing.',
              onTap: () {
                // Handle transporter selection
                print('Transporter selected');
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Handle continue button press
                print('Continue button pressed');
              },
              child: const Text('CONTINUE'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const ProfileOption({super.key, required this.icon, required this.title, required this.description, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 40.0, color: Colors.blue),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
