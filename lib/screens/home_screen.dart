import 'package:flutter/material.dart';
import 'nearby_stops_screen.dart';
import 'search_screen.dart';
import 'bus_search_results_screen.dart';
import '../services/app_status_service.dart';
import '../services/city_service.dart';
import '../services/bus_stop_service.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  
  bool _isLoading = false;
  List<String> _fromSuggestions = [];
  List<String> _toSuggestions = [];
  bool _showFromSuggestions = false;
  bool _showToSuggestions = false;

  @override
  void initState() {
    super.initState();
    // Add listeners for autocomplete
    _fromController.addListener(_onFromTextChanged);
    _toController.addListener(_onToTextChanged);
  }

  void _onFromTextChanged() {
    final text = _fromController.text;
    if (text.isNotEmpty) {
      _loadSuggestions(text, true);
    } else {
      setState(() {
        _showFromSuggestions = false;
      });
    }
  }

  void _onToTextChanged() {
    final text = _toController.text;
    if (text.isNotEmpty) {
      _loadSuggestions(text, false);
    } else {
      setState(() {
        _showToSuggestions = false;
      });
    }
  }

  Future<void> _loadSuggestions(String query, bool isFrom) async {
    if (query.length < 2) return;
    
    try {
      print('Loading suggestions for query: $query');
      // Use search APIs instead of loading all data
      final cities = await CityService.searchCities(query);
      final busStops = await BusStopService.searchBusStops(query);
      
      print('Cities found: ${cities.length}');
      print('Bus stops found: ${busStops.length}');
      
      final suggestions = <String>{};
      
      // Add cities
      for (final city in cities) {
        suggestions.add(city.cityName);
        print('Added city: ${city.cityName}');
      }
      
      // Add bus stops
      for (final stop in busStops) {
        suggestions.add(stop.stopName);
        print('Added stop: ${stop.stopName}');
      }
      
      print('Total suggestions: ${suggestions.length}');
      
      if (mounted) {
        setState(() {
          if (isFrom) {
            _fromSuggestions = suggestions.take(5).toList();
            // Don't show suggestions if current text exactly matches one of them
            _showFromSuggestions = _fromSuggestions.isNotEmpty && 
                                   !_fromSuggestions.contains(_fromController.text);
            print('Setting FROM suggestions: $_fromSuggestions, show: $_showFromSuggestions');
          } else {
            _toSuggestions = suggestions.take(5).toList();
            // Don't show suggestions if current text exactly matches one of them
            _showToSuggestions = _toSuggestions.isNotEmpty && 
                                 !_toSuggestions.contains(_toController.text);
            print('Setting TO suggestions: $_toSuggestions, show: $_showToSuggestions');
          }
        });
      }
    } catch (e) {
      print('Error loading suggestions: $e');
      // Silently fail, suggestions are optional
    }
  }

  Future<void> _searchRoutes() async {
    final from = _fromController.text.trim();
    final to = _toController.text.trim();

    if (from.isEmpty || to.isEmpty) {
      _showError('Please enter both departure and destination');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusSearchResultsScreen(
              from: from,
              to: to,
              fromId: from, // For now using the same text, can be improved later
              toId: to,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to search routes: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _fromController.removeListener(_onFromTextChanged);
    _toController.removeListener(_onToTextChanged);
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Connection Status Indicator
            FutureBuilder<bool>(
              future: AppStatusService.checkBackendStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                
                final isConnected = snapshot.data ?? false;
                if (!isConnected) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off, color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Limited connectivity - Some features may not work',
                            style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.directions_bus_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.appTitle ?? 'Track My Ride',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Find the perfect route for your journey',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bus Route Search Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.route_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Plan Your Journey',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // From Bus Stand with Suggestions
                  Column(
                    children: [
                      _buildSearchField(
                        controller: _fromController,
                        label: AppLocalizations.of(context)?.fromBusStand ?? 'From',
                        icon: Icons.my_location_rounded,
                        hint: 'Choose departure location',
                      ),
                      if (_showFromSuggestions) _buildSuggestionsList(_fromSuggestions, true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Swap Button
                  Center(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          final temp = _fromController.text;
                          _fromController.text = _toController.text;
                          _toController.text = temp;
                        },
                        icon: Icon(
                          Icons.swap_vert_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // To Bus Stand with Suggestions
                  Column(
                    children: [
                      _buildSearchField(
                        controller: _toController,
                        label: AppLocalizations.of(context)?.toBusStand ?? 'To',
                        icon: Icons.location_on_rounded,
                        hint: 'Choose destination',
                      ),
                      if (_showToSuggestions) _buildSuggestionsList(_toSuggestions, false),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Find Bus Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _searchRoutes,
                      child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Searching...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            AppLocalizations.of(context)?.findBus ?? 'Find Buses',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    'Nearby Bus Stops',
                    Icons.location_on_rounded,
                    const Color(0xFF38B2AC),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NearbyStopsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    'Live Tracking',
                    Icons.gps_fixed_rounded,
                    const Color(0xFFE53E3E),
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(
                            initialSearchType: 'number',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF718096),
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF718096),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsList(List<String> suggestions, bool isFrom) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            dense: true,
            leading: const Icon(Icons.location_on, size: 16, color: Colors.grey),
            title: Text(
              suggestion,
              style: const TextStyle(fontSize: 14),
            ),
            onTap: () {
              if (isFrom) {
                _fromController.text = suggestion;
                setState(() {
                  _showFromSuggestions = false;
                });
              } else {
                _toController.text = suggestion;
                setState(() {
                  _showToSuggestions = false;
                });
              }
            },
          );
        },
      ),
    );
  }
}