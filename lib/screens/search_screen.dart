import 'package:flutter/material.dart';
import '../services/search_history.dart';
import '../services/bus_stops_service.dart';
import '../models/bus_stop.dart';
import '../l10n/app_localizations.dart';
import 'bus_search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialSearchType;
  
  const SearchScreen({super.key, this.initialSearchType});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  late String _searchType;
  List<SearchItem> _routeSearches = [];
  List<SearchItem> _numberSearches = [];

  @override
  void initState() {
    super.initState();
    _searchType = widget.initialSearchType ?? 'route';
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final searches = await SearchHistory.getRecentSearches();
    setState(() {
      _routeSearches = searches.where((s) => s.type == 'route').toList();
      _numberSearches = searches.where((s) => s.type == 'number').toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        title: Text(
          AppLocalizations.of(context)?.search ?? 'Search',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Type Toggle
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _searchType = 'route'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _searchType == 'route'
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.searchByRoute ?? 'Search by Route',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _searchType == 'route'
                                  ? Colors.white
                                  : Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _searchType = 'number'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _searchType == 'number'
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.searchByNumber ?? 'Search by Number',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _searchType == 'number'
                                  ? Colors.white
                                  : Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: _searchType == 'route'
                      ? AppLocalizations.of(context)?.enterBusStopOrArea ?? 'Enter bus stop or area name'
                      : AppLocalizations.of(context)?.enterBusNumberHint ?? 'Enter bus number',
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    _searchType == 'route'
                        ? Icons.location_on
                        : Icons.directions_bus,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: _performSearch,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onSubmitted: (_) => _performSearch(),
              ),
            ),
            const SizedBox(height: 20),

            // Recent Searches
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _searchType == 'route' 
                      ? AppLocalizations.of(context)?.recentRouteSearches ?? 'Recent Route Searches'
                      : AppLocalizations.of(context)?.recentBusSearches ?? 'Recent Bus Searches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                if ((_searchType == 'route' ? _routeSearches : _numberSearches).isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      if (_searchType == 'route') {
                        // Clear only route searches
                        for (final search in _routeSearches) {
                          await SearchHistory.removeSearch(search);
                        }
                      } else {
                        // Clear only number searches
                        for (final search in _numberSearches) {
                          await SearchHistory.removeSearch(search);
                        }
                      }
                      await _loadRecentSearches();
                    },
                    child: Text(
                      AppLocalizations.of(context)?.clearAll ?? 'Clear All',
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: (_searchType == 'route' ? _routeSearches : _numberSearches).isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_outlined,
                            size: 64,
                            color: Theme.of(context).dividerColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchType == 'route' 
                                ? 'No recent route searches'
                                : 'No recent bus searches',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start searching to see your history here',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: (_searchType == 'route' ? _routeSearches : _numberSearches).length,
                      itemBuilder: (context, index) {
                        final searchItem = (_searchType == 'route' ? _routeSearches : _numberSearches)[index];
                        return _buildRecentSearchItem(searchItem);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchItem(SearchItem searchItem) {
    return Dismissible(
      key: Key('${searchItem.query}_${searchItem.type}_${searchItem.timestamp.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 24,
        ),
      ),
      onDismissed: (direction) async {
        await SearchHistory.removeSearch(searchItem);
        await _loadRecentSearches();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Removed "${searchItem.displayText}" from history'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () async {
                  await SearchHistory.addSearch(searchItem.query, searchItem.type);
                  await _loadRecentSearches();
                },
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: searchItem.type == 'number' 
                  ? const Color(0xFFE53E3E).withOpacity(0.1)
                  : const Color(0xFF38B2AC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              searchItem.type == 'number' 
                  ? Icons.directions_bus_rounded
                  : Icons.location_on_rounded,
              color: searchItem.type == 'number' 
                  ? const Color(0xFFE53E3E)
                  : const Color(0xFF38B2AC),
              size: 20,
            ),
          ),
          title: Text(
            searchItem.displayText,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          subtitle: Text(
            '${searchItem.type == 'number' ? 'Bus Number' : 'Route'} • ${searchItem.timeAgo}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF718096),
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFFA0AEC0),
          ),
          onTap: () {
            _searchController.text = searchItem.query;
            setState(() {
              _searchType = searchItem.type;
            });
            _performSearch();
          },
        ),
      ),
    );
  }

  void _performSearch() async {
    if (_searchController.text.isEmpty) return;
    
    final query = _searchController.text.trim();
    
    // Save to search history
    await SearchHistory.addSearch(query, _searchType);
    
    // Reload recent searches
    await _loadRecentSearches();
    
    if (_searchType == 'route') {
      // Search for bus stops/areas
      try {
        final busStops = await BusStopsService.getAllBusStops();
        final filteredStops = busStops.where((stop) => 
          stop.stopName.toLowerCase().contains(query.toLowerCase()) ||
          stop.city.toLowerCase().contains(query.toLowerCase()) ||
          (stop.address?.toLowerCase().contains(query.toLowerCase()) ?? false)
        ).toList();
        
        if (filteredStops.isNotEmpty && mounted) {
          // Show results in a bottom sheet or navigate to results screen
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) => Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Search Results for "$query"',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${filteredStops.length} bus stops found',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filteredStops.length,
                        itemBuilder: (context, index) {
                          final stop = filteredStops[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.blue),
                            title: Text(stop.stopName),
                            subtitle: Text('${stop.city}, ${stop.state}${stop.address != null ? '\n${stop.address}' : ''}'),
                            isThreeLine: stop.address != null,
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to bus search results with this stop as destination
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BusSearchResultsScreen(
                                    from: 'Current Location',
                                    to: stop.stopName,
                                    fromId: 'current',
                                    toId: stop.id ?? 'unknown',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No bus stops found for "$query"'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Search for bus by number - TODO: Implement bus number search
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Searching for Bus Number: $query'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}