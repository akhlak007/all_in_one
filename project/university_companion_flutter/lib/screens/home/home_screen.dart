import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_companion/screens/cafeteria/cafeteria_screen.dart';
import 'package:university_companion/screens/bus/bus_tracking_screen.dart';
import 'package:university_companion/screens/schedule/schedule_screen.dart';
import 'package:university_companion/screens/events/events_screen.dart';
import 'package:university_companion/screens/navigation/campus_map_screen.dart';
import 'package:university_companion/screens/chatbot/ai_assistant_screen.dart';
import 'package:university_companion/providers/auth_provider.dart';
import 'package:university_companion/screens/auth/login_screen.dart';
import 'package:university_companion/widgets/feature_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('University Companion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Card(
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              user?.displayName ?? 'User',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              // Feature Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  FeatureCard(
                    title: 'Cafeteria',
                    icon: Icons.restaurant_menu,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CafeteriaScreen(),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    title: 'Bus Tracking',
                    icon: Icons.directions_bus,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BusTrackingScreen(),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    title: 'Class Schedule',
                    icon: Icons.calendar_today,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScheduleScreen(),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    title: 'Events',
                    icon: Icons.event,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EventsScreen(),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    title: 'Campus Map',
                    icon: Icons.map,
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CampusMapScreen(),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    title: 'AI Assistant',
                    icon: Icons.smart_toy,
                    color: Colors.red,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AIAssistantScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Upcoming Classes
              Text(
                'Today\'s Classes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final classes = [
                      {
                        'name': 'Computer Science 101',
                        'time': '09:00 AM - 10:30 AM',
                        'location': 'Room 302, Building A',
                        'professor': 'Dr. Smith'
                      },
                      {
                        'name': 'Data Structures',
                        'time': '11:00 AM - 12:30 PM',
                        'location': 'Room 405, Building B',
                        'professor': 'Prof. Johnson'
                      },
                      {
                        'name': 'Artificial Intelligence',
                        'time': '02:00 PM - 03:30 PM',
                        'location': 'Lab 201, Building C',
                        'professor': 'Dr. Williams'
                      },
                    ];
                    
                    final classData = classes[index];
                    
                    return ListTile(
                      title: Text(classData['name']!),
                      subtitle: Text('${classData['time']} • ${classData['location']}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Navigate to class details
                      },
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Upcoming Events
              Text(
                'Upcoming Events',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '15\nOCT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.purple.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: const Text('Tech Hackathon 2025'),
                      subtitle: const Text('Student Center • 10:00 AM'),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('RSVP'),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '18\nOCT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: const Text('Career Fair'),
                      subtitle: const Text('Main Hall • 09:00 AM'),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('RSVP'),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Emergency SOS Button
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.emergency,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency SOS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap in case of emergency to alert campus security',
                              style: TextStyle(
                                color: Colors.red.shade800,
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AIAssistantScreen(),
            ),
          );
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}