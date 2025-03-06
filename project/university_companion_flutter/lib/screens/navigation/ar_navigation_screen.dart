import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_companion/models/building.dart';
import 'package:university_companion/providers/buildings_provider.dart';

class ARNavigationScreen extends ConsumerStatefulWidget {
  final Building? building;

  const ARNavigationScreen({
    Key? key,
    this.building,
  }) : super(key: key);

  @override
  ConsumerState<ARNavigationScreen> createState() => _ARNavigationScreenState();
}

class _ARNavigationScreenState extends ConsumerState<ARNavigationScreen> {
  Building? _selectedBuilding;
  bool _isLoading = false;
  String _statusMessage = 'Initializing AR...';
  bool _arInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedBuilding = widget.building;
    _initializeAR();
  }

  Future<void> _initializeAR() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Initializing AR...';
    });

    try {
      // Check if AR is available
      final arAvailabilityAsyncValue = ref.read(arAvailabilityProvider);
      final isARAvailable = await arAvailabilityAsyncValue.when(
        data: (data) => data,
        loading: () => false,
        error: (_, __) => false,
      );
      
      if (!isARAvailable) {
        setState(() {
          _statusMessage = 'AR is not available on this device';
          _isLoading = false;
        });
        return;
      }
      
      // Initialize AR
      await Future.delayed(const Duration(seconds: 2)); // Simulate initialization
      
      if (mounted) {
        setState(() {
          _arInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Failed to initialize AR: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedBuilding != null 
            ? 'AR Navigation to ${_selectedBuilding!.name}' 
            : 'AR Campus Navigation'),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_statusMessage),
                ],
              ),
            )
          : !_arInitialized
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _initializeAR,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    // AR View (Simulated)
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black,
                      child: _selectedBuilding != null
                          ? Image.network(
                              _selectedBuilding!.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Text(
                                'Point your camera at a building to identify it',
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                    ),
                    
                    // AR Overlay
                    if (_selectedBuilding != null)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Card(
                          color: Colors.black.withOpacity(0.7),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedBuilding!.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedBuilding!.description,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // TODO: Show building details
                                        },
                                        icon: const Icon(Icons.info_outline),
                                        label: const Text('Details'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // TODO: Show indoor navigation
                                        },
                                        icon: const Icon(Icons.map),
                                        label: const Text('Indoor Map'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
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
                  ],
                ),
    );
  }
}