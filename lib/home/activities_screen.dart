import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../profil/profil.dart';
import 'activity_model.dart';
import '../ajouter/ajout.dart';

class ActivitiesScreen extends StatefulWidget {
  final Function? onRefresh;
  const ActivitiesScreen({Key? key, this.onRefresh}) : super(key: key);

  @override
  ActivitiesScreenState createState() => ActivitiesScreenState();
}

class ActivitiesScreenState extends State<ActivitiesScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Activity>> activities;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    activities = _fetchActivities();
  }

  void _refreshData() {
    setState(() {
      activities = _fetchActivities();
    });
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
        backgroundColor: Colors.deepOrange, // Set the background color
        title: const Row(
          children: [
            Icon(
              Icons.adobe_sharp,
              color: Colors.white, // Set the icon color
              size: 42,
            ),
            SizedBox(width: 8),
            Text(
              'Activités',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20, // Set the font size
                fontWeight: FontWeight.bold, // Set the font weight
              ),
            ),
          ],
        ),
        elevation: 4, // Set the elevation/shadow
        centerTitle: false, // Align the title to the start
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            onPressed: () {
              // Add your notification action here
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              // Add your settings action here
            },
          ),
        ],
      // Add the rest of your app content here
      bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tous'),
            Tab(text: 'Football'),
            Tab(text: 'Échecs'),
            Tab(text: 'Escrime'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Set the background color
          borderRadius: BorderRadius.circular(10.0), // Add rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 3), // Change the shadow offset if needed
            ),
          ],
        ),
        child: TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(), // Optional: Add bouncing scroll effect
          dragStartBehavior: DragStartBehavior.start,
          children: [
            _buildBody(),
            _buildBody(filterCategory: 'Football'),
            _buildBody(filterCategory: 'Échecs'),
            _buildBody(filterCategory: 'Fencing'),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabTapped: (index) {
          setState(() {
            _currentIndex = index;
            if (_currentIndex == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Ajout(onRefresh: _refreshData),
                ),
              );
            }
            if (_currentIndex == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profil(onRefresh: _refreshData),
                ),
              );
            }
          });
        },
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
          return Card(
            elevation: 3, // Add a slight shadow to the cards
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: InkWell(
              onTap: () {
                _showActivityDetails(activities[index]);
              },
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: SizedBox(
                  height: 50,
                  width: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      activities[index].imageUrl.toString(),
                      width: 100.0,
                      height: 100.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  activities[index].titre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Set the title text color
                  ),
                ),
                subtitle: Text(
                  '${activities[index].lieu} - ${activities[index].prix}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey, // Set the subtitle text color
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }


  Future<List<Activity>> _fetchFilteredActivities(String? filterCategory) async {
    QuerySnapshot querySnapshot;

    if (filterCategory == null || filterCategory.isEmpty) {
      querySnapshot = await FirebaseFirestore.instance.collection('Activities').get();
    } else {
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(activity.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 18),
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

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const AppBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTabTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -1),
            blurRadius: 5,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat', // Use a custom font for selected labels
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontFamily: 'Montserrat', // Use a custom font for unselected labels
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event, size: 28), // Adjust icon size
            label: 'Activités',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, size: 28), // Adjust icon size
            label: 'Ajout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28), // Adjust icon size
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
