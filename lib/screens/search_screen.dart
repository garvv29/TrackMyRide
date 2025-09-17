import 'package:flutter/material.dart';
import '../services/search_history.dart';

class SearchScreen extends StatefulWidget {
  final String? initialSearchType;
  
  const SearchScreen({super.key, this.initialSearchType});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  late String _searchType;
  List<SearchItem> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _searchType = widget.initialSearchType ?? 'route';
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final searches = await SearchHistory.getRecentSearches();
    setState(() {
      _recentSearches = searches;
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
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3748),
        foregroundColor: Colors.white,
        title: const Text(
          'Search',
          style: TextStyle(
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
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
                                ? const Color(0xFF2D3748)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Search by Route',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _searchType == 'route'
                                  ? Colors.white
                                  : const Color(0xFF718096),
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
                                ? const Color(0xFF2D3748)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Search by Number',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _searchType == 'number'
                                  ? Colors.white
                                  : const Color(0xFF718096),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  color: Color(0xFF2D3748),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: _searchType == 'route'
                      ? 'Enter bus stop or area name'
                      : 'Enter bus number',
                  hintStyle: const TextStyle(
                    color: Color(0xFF718096),
                  ),
                  prefixIcon: Icon(
                    _searchType == 'route'
                        ? Icons.location_on
                        : Icons.directions_bus,
                    color: const Color(0xFF38B2AC),
                  ),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38B2AC),
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
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                if (_recentSearches.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      await SearchHistory.clearAll();
                      await _loadRecentSearches();
                    },
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _recentSearches.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_outlined,
                            size: 64,
                            color: Color(0xFFE2E8F0),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No recent searches',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF718096),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start searching to see your history here',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFA0AEC0),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _recentSearches.length,
                      itemBuilder: (context, index) {
                        final searchItem = _recentSearches[index];
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
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
    if (_searchController.text.isNotEmpty) {
      // Save to search history
      await SearchHistory.addSearch(_searchController.text.trim(), _searchType);
      
      // Reload recent searches
      await _loadRecentSearches();
      
      // TODO: Implement actual search functionality and navigation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Searching for: ${_searchController.text}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}