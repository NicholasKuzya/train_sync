import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../token_manager.dart';
import 'package:expandable_text/expandable_text.dart';

class AnyProfileScreen extends StatefulWidget {
  final String profileId;

  AnyProfileScreen({Key? key, required this.profileId}) : super(key: key);

  @override
  _AnyProfileScreenState createState() => _AnyProfileScreenState();
}

class _AnyProfileScreenState extends State<AnyProfileScreen> {
  late Future<Map<String, dynamic>> _profileData;
  late String _role = "";
  @override
  void initState() {
    super.initState();
    _profileData = _fetchProfileData();
  }

  Future<Map<String, dynamic>> _fetchProfileData() async {
    try {
      String? token = await TokenManager.getToken();
      String? role = await TokenManager.getRole();
      if(role == 'trainer') {
        _role = 'student';
      } else if(role== 'student') {
        _role = 'trainer';
      }
      if (token == null) {
        return {};
      }
      var url = Uri.parse('http://192.168.0.105:3000/api/$_role/get/${widget.profileId}');
      var response = await http.post(
        url,
        headers: {'authorization': '$token'},
      );
      var data = json.decode(response.body);
      print("Received profile data: $data");
      return data['$_role'];
    } catch (error) {
      print("Error fetching profile data: $error");
      return {}; // Возвращаем пустой Map в случае ошибки
    }
  }

  Widget _buildBirthDate(Map<String, dynamic> profileData) {
    if (profileData.containsKey("birthDate")) {
      DateTime birthDate = DateTime.parse(profileData["birthDate"]);
      int age = DateTime.now().year - birthDate.year;

      return Row(
        children: [
          Text(
            'Date of Birth: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '${birthDate.day}.${birthDate.month}.${birthDate.year} (Age: $age)',
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _buildProfileWidget(Map<String, dynamic> profileData) {
    if (profileData.isEmpty) {
      return Center(
        child: Text('Profile data not available'),
      );
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 60,
              child: ClipOval(
                child: profileData["avatar"] != null
                    ? Image.network(
                  profileData["avatar"]["src"],
                  fit: BoxFit.cover,
                )
                    : Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),
            Text(
              profileData["fullName"],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '${profileData["country"]}, ${profileData["city"]}${profileData["gym"] != null ? ', ' + profileData["gym"] : ''}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildBirthDate(profileData),
            SizedBox(height: 8),
            if (profileData["about"] != null && profileData["about"].isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ExpandableText(
                    profileData["about"],
                    maxLines: 3,
                    expandText: 'more',
                    collapseText: 'less',
                  ),
                ],
              ),
            ],
            SizedBox(height: 8.0),
            if (profileData["achievements"] != null &&
                profileData["achievements"].isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievements:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ExpandableText(
                    profileData["achievements"],
                    maxLines: 3,
                    expandText: 'more',
                    collapseText: 'less',
                  ),
                ],
              ),
            ],
            SizedBox(height: 8.0),
            if (profileData["specialization"] != null &&
                profileData["specialization"].isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Specialization:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ExpandableText(
                    profileData["specialization"],
                    maxLines: 3,
                    expandText: 'more',
                    collapseText: 'less',
                  ),
                ],
              ),
            ],
            SizedBox(height: 8),
            if (profileData["students"] != null) ...[
              Row(
                children: [
                  Text(
                    'Students: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${profileData["students"].isEmpty ? 0 : profileData["students"].length}',
                  ),
                ],
              ),
            ],
            if (profileData["weight"] != null) ...[
              SizedBox(height: 8),
              Text(
                'Weight: ${profileData["weight"]}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            if (profileData["height"] != null) ...[
              SizedBox(height: 8),
              Text(
                'Height: ${profileData["height"]}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            if (profileData["goal"] != null) ...[
              SizedBox(height: 8),
              Text(
                'Goal: ${profileData["goal"]}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load profile data: ${snapshot.error}'),
            );
          } else {
            Map<String, dynamic> profileData = snapshot.data!;
            return _buildProfileWidget(profileData);
          }
        },
      ),
    );
  }
}
