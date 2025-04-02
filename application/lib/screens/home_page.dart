import 'package:flutter/material.dart';
import '../models/show.dart';
import '../services/show_service.dart';
import 'add_show_page.dart';
import 'update_show_page.dart';
import 'profile_page.dart';
import '../config/api_config.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ShowService _showService = ShowService();
  List<Show> _shows = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadShows();
  }

  Future<void> _loadShows() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final shows = await _showService.getShows();
      if (!mounted) return;

      setState(() {
        _shows = shows;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading shows: $e')),
      );
    }
  }

  Future<void> _navigateToAddShow() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddShowPage()),
    );

    if (result == true) {
      _loadShows();
    }
  }

  Future<void> _navigateToUpdateShow(Show show) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateShowPage(show: show),
      ),
    );

    if (result == true) {
      _loadShows();
    }
  }

  Future<void> _deleteShow(String id) async {
    try {
      await _showService.deleteShow(id);
      _loadShows();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Show deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting show: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showDeleteConfirmation(String id, String title) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Show'),
            content: Text('Are you sure you want to delete "$title"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                  _deleteShow(id);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _refreshShows() async {
    await _loadShows();
  }

  List<Show> _getShowsByType(String type) {
    return _shows
        .where((show) => show.type.toLowerCase() == type.toLowerCase())
        .toList();
  }

  Widget _buildShowList(String type) {
    final shows = _getShowsByType(type);

    return RefreshIndicator(
      onRefresh: _refreshShows,
      child: shows.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 100),
                Center(child: Text('No Shows Available')),
              ],
            )
          : ListView.builder(
              itemCount: shows.length,
              itemBuilder: (context, index) {
                final show = shows[index];
                return Dismissible(
                  key: Key(show.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    final result =
                        await _showDeleteConfirmation(show.id, show.title);
                    return result == null;
                  },
                  onDismissed: (direction) {
                    _deleteShow(show.id);
                  },
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: show.imageUrl.isNotEmpty
                            ? Image.network(
                                show.fullImageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading image: $error');
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      title: Text(show.title),
                      subtitle: Text(show.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _navigateToUpdateShow(show),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _showDeleteConfirmation(show.id, show.title),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add Show'),
            onTap: () {
              Navigator.pop(context);
              _navigateToAddShow();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      switch (_selectedIndex) {
        case 0:
          body = _buildShowList('movie');
          break;
        case 1:
          body = _buildShowList('anime');
          break;
        case 2:
          body = _buildShowList('serie');
          break;
        default:
          body = _buildShowList('movie');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Show App'),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: _buildDrawer(),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        items: const [
          BottomNavigationBarItem(
            icon: const Icon(Icons.movie),
            label: 'Movies',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.animation),
            label: 'Anime',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.tv),
            label: 'Series',
          ),
        ],
      ),
    );
  }
}
