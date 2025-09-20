import 'package:flutter/material.dart';
import '../services/route_search_history.dart';

class RecentRoutesScreen extends StatefulWidget {
  const RecentRoutesScreen({super.key});

  @override
  State<RecentRoutesScreen> createState() => _RecentRoutesScreenState();
}

class _RecentRoutesScreenState extends State<RecentRoutesScreen> {
  List<RouteSearchItem> _recentRoutes = [];

  @override
  void initState() {
    super.initState();
    _loadRecentRoutes();
  }

  Future<void> _loadRecentRoutes() async {
    final routes = await RouteSearchHistory.getRecentRouteSearches();
    setState(() {
      _recentRoutes = routes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Route Searches'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_recentRoutes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () async {
                await RouteSearchHistory.clearAll();
                await _loadRecentRoutes();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All route searches cleared'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _recentRoutes.isEmpty
            ? _buildEmptyState()
            : _buildRoutesList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route_outlined,
            size: 64,
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Recent Route Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for routes on the home page to see your history here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutesList() {
    return ListView.builder(
      itemCount: _recentRoutes.length,
      itemBuilder: (context, index) {
        final routeItem = _recentRoutes[index];
        return _buildRouteItem(routeItem);
      },
    );
  }

  Widget _buildRouteItem(RouteSearchItem routeItem) {
    return Dismissible(
      key: Key('${routeItem.from}_${routeItem.to}_${routeItem.timestamp.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        await RouteSearchHistory.removeRouteSearch(routeItem);
        await _loadRecentRoutes();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Removed "${routeItem.displayText}" from history'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () async {
                  await RouteSearchHistory.addRouteSearch(routeItem.from, routeItem.to);
                  await _loadRecentRoutes();
                },
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.route,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            routeItem.displayText,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.my_location,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'From: ${routeItem.from}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'To: ${routeItem.to}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                Icons.history,
                size: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
              const SizedBox(height: 2),
              Text(
                routeItem.timeAgo,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
              ),
            ],
          ),
          onTap: () {
            // Navigate back to home and populate the search fields
            Navigator.pop(context, routeItem);
          },
        ),
      ),
    );
  }
}