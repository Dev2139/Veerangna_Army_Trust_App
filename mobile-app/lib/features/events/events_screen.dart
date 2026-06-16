import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/api_service.dart';
import '../../data/models/event_model.dart';
import '../../data/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<EventModel>> _eventsFuture;
  late Future<UserModel?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _eventsFuture = _apiService.getEvents();
      _profileFuture = _apiService.getUserProfile();
    });
  }

  void _showRegistrationSheet(BuildContext context, EventModel event, UserModel user) {
    final TextEditingController _nameController = TextEditingController(text: user.name);
    final TextEditingController _phoneController = TextEditingController(text: user.phone);
    final TextEditingController _attendeesController = TextEditingController(text: '1');
    bool _isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Register for \${event.title}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _attendeesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Number of Attendees', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () async {
                        setModalState(() => _isSubmitting = true);
                        final success = await _apiService.registerForEvent(
                          event.id,
                          _nameController.text,
                          _phoneController.text,
                          int.tryParse(_attendeesController.text) ?? 1,
                        );
                        
                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Successfully registered!'), backgroundColor: Colors.green),
                          );
                          _loadData(); // Reload to update button state
                        } else {
                          setModalState(() => _isSubmitting = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to register. Please try again.'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.saffron,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Confirm Registration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Container(height: 120, decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(12)))),
                ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                  title: Container(height: 16, width: double.infinity, color: Colors.white),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Container(height: 12, width: 150, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 12, width: 200, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Upcoming Events'),
        backgroundColor: AppColors.armyGreen,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: Future.wait([_eventsFuture, _profileFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeletonLoader();
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load events'));
          }

          final List<EventModel> eventsList = snapshot.data![0];
          final UserModel? user = snapshot.data![1];

          if (eventsList.isEmpty) {
            return const Center(child: Text('No upcoming events currently.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: eventsList.length,
            itemBuilder: (context, index) {
              final event = eventsList[index];
              
              // Check if user is registered by seeing if their ID is in the registrations list
              // Or if user.eventParticipation contains the event.id
              bool isRegistered = false;
              if (user != null) {
                // If the user's ID is populated directly in the registration object
                isRegistered = event.registrations.any((reg) {
                  if (reg is Map && reg['user'] != null) {
                    return reg['user'].toString() == user.id;
                  }
                  return false;
                });
                
                // Fallback check against user's participation list
                if (!isRegistered) {
                  isRegistered = user.eventParticipation.contains(event.id);
                }
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    if (event.banners.isNotEmpty)
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          image: DecorationImage(
                            image: NetworkImage(event.banners.first),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.saffron.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(DateFormat('dd').format(event.date), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.saffron)),
                            Text(DateFormat('MMM').format(event.date).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.armyGreen)),
                          ],
                        ),
                      ),
                      title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(child: Text(event.location, maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(event.description, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: isRegistered || user == null ? null : () => _showRegistrationSheet(context, event, user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRegistered ? Colors.grey : AppColors.armyGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(isRegistered ? 'Registered' : 'Register', style: TextStyle(color: isRegistered ? Colors.white70 : Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
