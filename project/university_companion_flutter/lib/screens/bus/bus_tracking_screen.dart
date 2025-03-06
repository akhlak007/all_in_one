import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:university_companion/models/bus.dart';
import 'package:university_companion/providers/bus_provider.dart';
import 'package:university_companion/widgets/error_view.dart';
import 'package:university_companion/widgets/loading_view.dart';

class BusTrackingScreen extends ConsumerStatefulWidget {
  const BusTrackingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BusTrackingScreen> createState() => _BusTrackingScreenState();
}

class _BusTrackingScreenState extends ConsumerState<BusTrackingScreen> {
  GoogleMapController? _mapController;
  String _selectedRoute = 'All Routes';
  bool _showOfflineMode = false;

  @override
  void initState() {
    super.initState();
    // Check if we're online, if not show offline mode
    Future.delayed(Duration.zero, () async {
      final connectivityAsyncValue = ref.read(connectivityProvider);
      final isOnline = await connectivityAsyncValue.when(
        data: (data) => data,
        loading: () => true,
        error: (_, __) => true,
      );
      
      if (!isOnline && mounted) {
        setState(() {
          _showOfflineMode = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busesAsync = ref.watch(busesProvider);
    final routes = ref.watch(routesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(busesProvider),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map View
          busesAsync.when(
            data: (buses) {
              // Filter buses by selected route
              final filteredBuses = _selectedRoute == 'All Routes'
                  ? buses
                  : buses.where((bus) => bus.routeName == _selectedRoute).toList();
              
              return GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(37.422, -122.084), // Default to university location
                  zoom: 14.5,
                ),
                markers: _buildMarkers(filteredBuses),
                polylines: _buildRouteLines(filteredBuses),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapToolbarEnabled: false,
                compassEnabled: true,
                zoomControlsEnabled: false,
              );
            },
            loading: () => const LoadingView(),
            error: (error, stackTrace) => ErrorView(
              message: 'Failed to load bus data',
              onRetry: () => ref.refresh(busesProvider),
            ),
          ),
          
          // Offline Mode Banner
          if (_showOfflineMode)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.amber.shade700,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Offline Mode: Showing last known bus schedule',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 16),
                      onPressed: () {
                        setState(() {
                          _showOfflineMode = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          
          // Route Selector
          Positioned(
            top: _showOfflineMode ? 56 : 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRoute,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    items: ['All Routes', ...routes].map((route) {
                      return DropdownMenuItem(
                        value: route,
                        child: Text(route),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRoute = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          
          // Bus List
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.1,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: busesAsync.when(
                  data: (buses) {
                    // Filter buses by selected route
                    final filteredBuses = _selectedRoute == 'All Routes'
                        ? buses
                        : buses.where((bus) => bus.routeName == _selectedRoute).toList();
                    
                    if (filteredBuses.isEmpty) {
                      return Center(
                        child: Text(
                          'No buses available for this route',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }
                    
                    return Column(
                      children: [
                        // Handle
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        
                        // Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Available Buses',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        
                        // Bus List
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: filteredBuses.length,
                            itemBuilder: (context, index) {
                              final bus = filteredBuses[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getRouteColor(bus.routeName),
                                  child: Text(
                                    bus.busNumber,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(bus.routeName),
                                subtitle: Text(
                                  'Next Stop: ${bus.nextStop} (${bus.estimatedArrival})',
                                ),
                                trailing: bus.isDelayed
                                    ? Chip(
                                        label: const Text('Delayed'),
                                        backgroundColor: Colors.red.shade100,
                                        labelStyle: TextStyle(color: Colors.red.shade800),
                                      )
                                    : null,
                                onTap: () {
                                  _mapController?.animateCamera(
                                    CameraUpdate.newLatLngZoom(
                                      LatLng(bus.latitude, bus.longitude),
                                      16,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text('Failed to load bus data'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Set<Marker> _buildMarkers(List<Bus> buses) {
    return buses.map((bus) {
      return Marker(
        markerId: MarkerId(bus.id),
        position: LatLng(bus.latitude, bus.longitude),
        infoWindow: InfoWindow(
          title: '${bus.routeName} - Bus ${bus.busNumber}',
          snippet: 'Next Stop: ${bus.nextStop} (${bus.estimatedArrival})',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          bus.isDelayed ? BitmapDescriptor.hueRed : BitmapDescriptor.hueAzure,
        ),
      );
    }).toSet();
  }
  
  Set<Polyline> _buildRouteLines(List<Bus> buses) {
    final Map<String, List<LatLng>> routePoints = {};
    
    // Group route points by route name
    for (final bus in buses) {
      if (!routePoints.containsKey(bus.routeName)) {
        routePoints[bus.routeName] = [];
      }
      
      // Add bus location to route points
      routePoints[bus.routeName]!.add(LatLng(bus.latitude, bus.longitude));
      
      // Add route stops to route points
      for (final stop in bus.routeStops) {
        routePoints[bus.routeName]!.add(LatLng(stop.latitude, stop.longitude));
      }
    }
    
    // Create polylines for each route
    return routePoints.entries.map((entry) {
      return Polyline(
        polylineId: PolylineId(entry.key),
        points: entry.value,
        color: _getRouteColor(entry.key),
        width: 3,
      );
    }).toSet();
  }
  
  Color _getRouteColor(String routeName) {
    // Generate a color based on the route name
    final colorMap = {
      'North Campus': Colors.blue,
      'South Campus': Colors.red,
      'East Campus': Colors.green,
      'West Campus': Colors.orange,
      'Downtown': Colors.purple,
    };
    
    return colorMap[routeName] ?? Colors.blue;
  }
}