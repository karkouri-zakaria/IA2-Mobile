import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'activity_model.dart';
import 'ajout.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Activity>> activities;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    activities = _fetchActivities();
  }

  Future<List<Activity>> _fetchActivities() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('Activities').get();

    List<Activity> activityList = [];
    for (var doc in querySnapshot.docs) {
      activityList.add(Activity.fromSnapshot(doc));
    }

    return activityList;
  }

  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.adobe_sharp,
              color: Colors.orange,
              size: 42,
            ),
            SizedBox(width: 8),
            Text(
              'Activités',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ALl'),
            Tab(text: 'Sport'),
            Tab(text: 'Shopping'),
            Tab(text: 'Music'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBody(), // All
          _buildBody(filterCategory: 'Sport'),
          _buildBody(filterCategory: 'Shopping'),
          _buildBody(filterCategory: 'Music'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (_currentIndex == 1) {
              // Navigate to AjoutPage when the "Ajout" tab is tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Ajout()),
              );
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Activités',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Ajout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildBody({String? filterCategory}) {
    return FutureBuilder<List<Activity>>(
      future: _fetchFilteredActivities(filterCategory),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return _buildActivitiesList(snapshot.data);
        }
      },
    );
  }

  Widget _buildActivitiesList(List<Activity>? activities) {
    if (activities == null || activities.isEmpty) {
      return const Center(child: Text('No activities available.'));
    } else {
      return ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              _showActivityDetails(activities[index]);
            },
            leading: SizedBox(
              height: 50,
              width: 50,
              child: Image.network(
                activities[index].imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(activities[index].titre),
            subtitle: Text(
              '${activities[index].lieu} - ${activities[index].prix}',
            ),
          );
        },
      );
    }
  }

  Future<List<Activity>> _fetchFilteredActivities(String? filterCategory) async {
    QuerySnapshot querySnapshot;

    if (filterCategory == null || filterCategory.isEmpty) {
      // Fetch all activities when filterCategory is null or empty
      querySnapshot = await FirebaseFirestore.instance.collection('Activities').get();
    } else {
      // Fetch filtered activities based on the category
      querySnapshot = await FirebaseFirestore.instance
          .collection('Activities')
          .where('categorie', isEqualTo: filterCategory)
          .get();
    }

    List<Activity> activityList = [];
    for (var doc in querySnapshot.docs) {
      activityList.add(Activity.fromSnapshot(doc));
    }

    return activityList;
  }

  void _showActivityDetails(Activity activity) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            activity.titre,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Image.network(
                  activity.imageUrl,
                  height: 350, // Set your preferred height
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text('Lieu: ${activity.lieu}'),
              Text('Prix: ${activity.prix}'),
              Text('Minimum Personnes: ${activity.minPersonne}'),
              Text('Categorie: ${activity.categorie}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}