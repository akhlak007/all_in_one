import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:university_companion/models/event.dart';
import 'package:university_companion/providers/events_provider.dart';
import 'package:university_companion/widgets/error_view.dart';
import 'package:university_companion/widgets/loading_view.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    final categories = ref.watch(eventCategoriesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events & Activities'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Events'),
            Tab(text: 'Clubs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Events Tab
          Column(
            children: [
              // Category Filter
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip('All'),
                    ...categories.map((category) => _buildCategoryChip(category)),
                  ],
                ),
              ),
              
              // Events List
              Expanded(
                child: eventsAsync.when(
                  data: (events) {
                    // Filter events by category
                    final filteredEvents = _selectedCategory == 'All'
                        ? events
                        : events.where((event) => event.category == _selectedCategory).toList();
                    
                    if (filteredEvents.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No events found for this category',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    // Sort events by date
                    filteredEvents.sort((a, b) => a.date.compareTo(b.date));
                    
                    // Separate upcoming and past events
                    final now = DateTime.now();
                    final upcomingEvents = filteredEvents.where((event) => event.date.isAfter(now)).toList();
                    final pastEvents = filteredEvents.where((event) => event.date.isBefore(now)).toList();
                    
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (upcomingEvents.isNotEmpty) ...[
                          Text(
                            'Upcoming Events',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ...upcomingEvents.map((event) => _buildEventCard(event, true)),
                        ],
                        
                        if (pastEvents.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Past Events',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ...pastEvents.map((event) => _buildEventCard(event, false)),
                        ],
                      ],
                    );
                  },
                  loading: () => const LoadingView(),
                  error: (error, stackTrace) => ErrorView(
                    message: 'Failed to load events',
                    onRetry: () => ref.refresh(eventsProvider),
                  ),
                ),
              ),
            ],
          ),
          
          // Clubs Tab
          const Center(
            child: Text('Clubs tab content will go here'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new event
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? _getCategoryColor(category)
              : _getCategoryColor(category).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getCategoryColor(category),
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : _getCategoryColor(category),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildEventCard(Event event, bool isUpcoming) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              event.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 48),
                  ),
                );
              },
            ),
          ),
          
          // Event Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(event.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _getCategoryColor(event.category),
                        ),
                      ),
                      child: Text(
                        event.category,
                        style: TextStyle(
                          color: _getCategoryColor(event.category),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!isUpcoming)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Past Event',
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(event.date),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('h:mm a').format(event.date),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Add to calendar
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Add to Calendar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isUpcoming ? () {
                          // TODO: RSVP to event
                        } : null,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('RSVP'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    // Generate a color based on the category
    final colorMap = {
      'Academic': Colors.blue,
      'Social': Colors.purple,
      'Sports': Colors.green,
      'Career': Colors.orange,
      'Workshop': Colors.teal,
      'Conference': Colors.indigo,
      'All': Colors.blue,
    };
    
    return colorMap[category] ?? Colors.blue;
  }
}