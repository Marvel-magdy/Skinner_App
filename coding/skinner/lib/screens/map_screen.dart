import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show Distance, LengthUnit;

import '../services/routing_service.dart';

class MapScreen extends StatefulWidget {
  final Map doctor;
  final VoidCallback onBack;
  final VoidCallback onBook;

  const MapScreen({
    super.key,
    required this.doctor,
    required this.onBack,
    required this.onBook,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final RoutingService _routingService = RoutingService();
  final Dio _dio = Dio();

  Position? _currentPosition;
  List<LatLng> _routePoints = [];
  List<Marker> _markers = [];
  StreamSubscription<Position>? _positionStreamSubscription;
  String _routingMethod = '';

  late LatLng _destination;
  bool _geocoded = false; // true once we have a real address coordinate

  bool _isLoading = true;
  bool _isFetchingRoute = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Start with a hash-based placeholder so the map can open immediately
    _destination = _hashCoordinates(widget.doctor);
    _initializeLocationAndRoute();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // ── Geocoding ──────────────────────────────────────────────────────────────

  /// Try to geocode [address] with Nominatim.
  /// Returns null on any failure so the caller can fall back gracefully.
  Future<LatLng?> _geocodeAddress(String address) async {
    if (address.trim().isEmpty) return null;
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': address,
          'format': 'json',
          'limit': '1',
        },
        options: Options(
          headers: {
            // Nominatim requires a real User-Agent
            'User-Agent': 'SkinnerApp/1.0 (flutter; contact@skinner.app)',
          },
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );

      final results = response.data as List<dynamic>;
      if (results.isEmpty) return null;

      final lat = double.tryParse(results[0]['lat'].toString());
      final lon = double.tryParse(results[0]['lon'].toString());
      if (lat == null || lon == null) return null;

      debugPrint('✅ Geocoded "$address" → ($lat, $lon)');
      return LatLng(lat, lon);
    } catch (e) {
      debugPrint('⚠️ Geocoding failed for "$address": $e');
      return null;
    }
  }

  /// Stable hash-based fallback coordinate so the map always shows something.
  LatLng _hashCoordinates(Map doctor) {
    final String key =
        doctor['medical_syndicate_id_card']?.toString() ??
        doctor['name']?.toString() ??
        '1';
    final int h = key.hashCode;
    final double dLat = ((h % 100) - 50) / 3333.0;
    final double dLng = (((h >> 2) % 100) - 50) / 3333.0;
    return LatLng(30.0444 + dLat, 31.2357 + dLng);
  }

  Future<void> _initializeLocationAndRoute() async {
    try {
      // 1. Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // 2. Check/request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied. Please enable them in Settings.');
      }

      // 3. Get user's position and geocode the clinic address in parallel
      final results = await Future.wait([
        Geolocator.getCurrentPosition(),
        _geocodeAddress(
            (widget.doctor['clinic_address'] ?? '').toString()),
      ]);

      final position = results[0] as Position;
      final geocoded = results[1] as LatLng?;

      if (mounted) {
        setState(() {
          _currentPosition = position;
          if (geocoded != null) {
            _destination = geocoded;
            _geocoded = true;
          }
          // If geocoding failed, _destination keeps the hash-based fallback
          _isLoading = false;
        });
      }

      _updateMarkers();
      await _fetchRoute();
      _fitBounds();

      // 4. Listen to live location updates
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      _positionStreamSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position newPosition) {
        if (mounted) {
          setState(() {
            _currentPosition = newPosition;
            _updateMarkers();
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _updateMarkers() {
    if (_currentPosition == null) return;

    _markers = [
      // My location indicator
      Marker(
        width: 44.0,
        height: 44.0,
        point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      // Doctor's location pin
      Marker(
        width: 56.0,
        height: 56.0,
        point: _destination,
        child: Tooltip(
          message: _geocoded
              ? widget.doctor['clinic_address'] ?? 'Clinic'
              : 'Approximate location',
          child: Container(
            decoration: BoxDecoration(
              color: _geocoded ? const Color(0xFF2563EB) : Colors.orange,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              color: Colors.white,
              size: 26.0,
            ),
          ),
        ),
      ),
    ];
  }

  Future<void> _fetchRoute() async {
    if (_currentPosition == null) return;

    setState(() => _isFetchingRoute = true);

    try {
      final start =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      final route = await _routingService.getRoute(start, _destination);

      if (mounted) {
        setState(() {
          _routePoints = route;
          _isFetchingRoute = false;
          // Determine which method was used
          if (route.length > 100) {
            _routingMethod = 'Real road routing';
          } else if (route.length == 51) {
            _routingMethod = 'Straight line (fallback)';
          } else {
            _routingMethod = 'Route loaded';
          }
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch route: $e');
      if (mounted) {
        setState(() {
          _isFetchingRoute = false;
          _routingMethod = 'Route failed';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not fetch route: $e')),
        );
      }
    }
  }

  void _fitBounds() {
    if (_currentPosition == null) return;

    final myLatLng =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    final bounds = LatLngBounds.fromPoints([myLatLng, _destination]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.only(top: 80, bottom: 220, left: 60, right: 60),
          ),
        );
      } catch (e) {
        debugPrint('fitCamera error: $e');
      }
    });
  }

  /// Estimate drive time in minutes from route distance (rough: avg 30 km/h in city)
  String _getEtaLabel() {
    if (_routePoints.length < 2) return '...';
    double totalMeters = 0;
    for (int i = 0; i < _routePoints.length - 1; i++) {
      const Distance d = Distance();
      totalMeters += d.as(LengthUnit.Meter, _routePoints[i], _routePoints[i + 1]);
    }
    final minutes = (totalMeters / 500).round(); // ~30 km/h avg
    if (minutes < 1) return '1 min';
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final String doctorName = widget.doctor['name'] ?? 'Specialist';
    final String specialization = widget.doctor['specialization'] ?? 'Dermatology';
    final String clinicAddress = widget.doctor['clinic_address'] ?? '';
    final String phone = widget.doctor['phone'] ?? widget.doctor['contact'] ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: widget.onBack,
        ),
        title: Text(
          doctorName,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : Column(
                  children: [
                    // ── Map (top portion) ──────────────────────────────
                    Expanded(
                      flex: 10,
                      child: Stack(
                        children: [
                          _buildFlutterMap(),

                          // Route calculating indicator
                          if (_isFetchingRoute)
                            Positioned(
                              top: 12, left: 0, right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black12, blurRadius: 6),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 14, height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Calculating route…',
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // Geocoding warning
                          if (!_isFetchingRoute && !_geocoded)
                            Positioned(
                              top: 12, left: 16, right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange.shade300),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded,
                                        size: 16, color: Colors.orange.shade700),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Showing approximate location.',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.orange.shade800),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // FABs (my-location + fit-all)
                          Positioned(
                            right: 12, bottom: 12,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _mapFab(
                                  tag: 'myLocation',
                                  icon: Icons.my_location,
                                  onTap: () {
                                    if (_currentPosition != null) {
                                      _mapController.move(
                                        LatLng(_currentPosition!.latitude,
                                            _currentPosition!.longitude),
                                        15.0,
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                                _mapFab(
                                  tag: 'fitAll',
                                  icon: Icons.zoom_out_map,
                                  onTap: _fitBounds,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── ETA bar ────────────────────────────────────────
                    Container(
                      color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).cardColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                disabledBackgroundColor: const Color(0xFF2563EB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: const Icon(Icons.directions_car_rounded,
                                  color: Colors.white, size: 20),
                              label: Text(
                                _isFetchingRoute ? 'Calculating…' : _getEtaLabel(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),

                    // ── Details panel (scrollable) ─────────────────────
                    Expanded(
                      flex: 9,
                      child: Container(
                        color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).cardColor,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 1),
                              const SizedBox(height: 16),

                              // Hours row
                              _detailLabel('Hours'),
                              const SizedBox(height: 4),
                              const Text(
                                '09:00 – 17:00',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Open',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF16A34A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 20),
                              const Text(
                                'Details',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Specialization
                              _detailLabel('Specialty'),
                              const SizedBox(height: 4),
                              Text(
                                specialization,
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFF0F172A)),
                              ),

                              if (phone.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                const Divider(height: 1),
                                const SizedBox(height: 16),
                                _detailLabel('Phone'),
                                const SizedBox(height: 4),
                                Text(
                                  phone,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],

                              if (clinicAddress.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                const Divider(height: 1),
                                const SizedBox(height: 16),
                                _detailLabel('Address'),
                                const SizedBox(height: 4),
                                Text(
                                  clinicAddress,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF0F172A),
                                    height: 1.5,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

      // ── Book Appointment — pinned at bottom ──────────────────
      bottomNavigationBar: _isLoading || _errorMessage != null
          ? null
          : Container(
              color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).cardColor,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).padding.bottom + 12,
                top: 12,
              ),
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: widget.onBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  label: const Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _detailLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
      );

  Widget _mapFab({
    required String tag,
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      FloatingActionButton(
        heroTag: tag,
        mini: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2563EB),
        elevation: 4,
        onPressed: onTap,
        child: Icon(icon),
      );

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_rounded, size: 52, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isLoading = true;
                });
                _initializeLocationAndRoute();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlutterMap() {
    if (_currentPosition == null) {
      return const Center(child: Text('Location unavailable'));
    }
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter:
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.skinner.app',
          maxZoom: 19,
          keepBuffer: 5,
          tileUpdateTransformer:
              TileUpdateTransformers.throttle(const Duration(milliseconds: 200)),
        ),
        if (_routePoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                strokeWidth: 5.0,
                color: const Color(0xFF2563EB),
              ),
            ],
          ),
        MarkerLayer(markers: _markers),
      ],
    );
  }
}
