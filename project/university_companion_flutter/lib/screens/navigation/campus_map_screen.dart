import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:university_companion/models/building.dart';
import 'package:university_companion/providers/buildings_provider.dart';
import 'package:university_companion/screens/navigation/ar_navigation_screen.dart';
import 'package:university_companion/widgets/error_view.dart';
import 'package:university_companion/widgets/loading_view.dart';

class CampusMapScreen extends ConsumerStatefulWidget {
  const CampusMapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends ConsumerState<CampusMapScreen> {
  GoogleMapController? _mapController;
  Building? _selectedBuilding;
  bool _showARButton = false;
  
  @override
  void initState() {
    super.initState();
    // Check if AR is available on this device
    Future.delayed(Duration.zero, () async {
      final arAvailabilityAsyncValue = ref.read(arAvailabilityProvider);
      final isAvailable = await arAvailabilityAsyncValue.when(
        data: (data) => data,
        loading: () => false,
        error: (_, __) => false,
      );
      
      if (mounted) {
        setState(() {
          _showARButton = isAvailable;
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
    final buildingsAsync = ref.watch(buildingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map View
          buildingsAsync.when(
            data: (buildings) {
              return GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(37.422, -122.084), // Default to university location
                  zoom: 16,
                ),
                markers: _buildMarkers(buildings),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapToolbarEnabled: false,
                compassEnabled: true,
                zoomControlsEnabled: false,
                onTap: (_) {
                  setState(() {
                    _selectedBuilding = null;
                  });
                },
              );
            },
            loading: () => const LoadingView(),
            error: (error, stackTrace) => ErrorView(
              message: 'Failed to load campus map',
              onRetry: () => ref.refresh(buildingsProvider),
            ),
          ),
          
          // Building Info Card
          if (_selectedBuilding != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedBuilding!.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedBuilding!.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Hours: ${_selectedBuilding!.openingHours}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Type: ${_selectedBuilding!.type}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Get directions
                              },
                              icon: const Icon(Icons.directions),
                              label: const Text('Directions'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_showARButton)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ARNavigationScreen(
                                        building: _selectedBuilding!,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.view_in_ar),
                                label: const Text('AR View'),
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
              ),
            ),
          
          // Legend
          Positioned(
            top: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Legend',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(Colors.blue, 'Academic'),
                    _buildLegendItem(Colors.green, 'Residential'),
                    _buildLegendItem(Colors.orange, 'Dining'),
                    _buildLegendItem(Colors.purple, 'Administrative'),
                    _buildLegendItem(Colors.red, 'Sports'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _showARButton
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ARNavigationScreen(),
                  ),
                );
              },
              child: const Icon(Icons.view_in_ar),
            )
          : null,
    );
  }
  
  Set<Marker> _buildMarkers(List<Building> buildings) {
    return buildings.map((building) {
      return Marker(
        markerId: MarkerId(building.id),
        position: LatLng(building.latitude, building.longitude),
        infoWindow: InfoWindow(
          title: building.name,
          snippet: building.type,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getBuildingHue(building.type),
        ),
        onTap: () {
          setState(() {
            _selectedBuilding = building;
          });
        },
      );
    }).toSet();
  }
  
  double _getBuildingHue(String buildingType) {
    switch (buildingType) {
      case 'Academic':
        return BitmapDescriptor.hueBlue;
      case 'Residential':
        return BitmapDescriptor.hueGreen;
      case 'Dining':
        return BitmapDescriptor.hueOrange;
      case 'Administrative':
        return BitmapDescriptor.hueViolet;
      case 'Sports':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueAzure;
    }
  }
  
  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}