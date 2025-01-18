import 'package:boxing_timer_v1/screens/setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: screenSize.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [

              SizedBox(height: MediaQuery.of(context).size.height * getResponsiveValueGeneral(context: context, mobileDevices: 0.01, tablets: 0.04, laptops: 0.7, desktops: 0.7, tv: 0.7)),

              // Top navigation with back button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                child: Row(
                  children: [
                    IconButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.black.withOpacity(0.08)),
                      ),
                      padding: EdgeInsets.all(2),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.keyboard_arrow_left, size: getResponsiveValueGeneral(context: context, mobileDevices: 50.0, tablets: 60.0, laptops: 25.0, desktops: 25.0, tv: 25.0), color: Colors.black38),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              // Title and Logo
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: screenSize.width * 0.15,
                      backgroundImage: AssetImage('assets/publisher_logo.png'), // Set your logo here
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Publisher Name",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Your trusted source for premium content.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Publisher Overview Section
              Text(
                "About Us",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Our mission is to provide users with high-quality content and help them achieve their goals through learning, entertainment, and innovation.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),

              SizedBox(height: 30),

              // Contact Information Section
              Text(
                "Contact Us",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.email, color: Colors.blueGrey),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      final Uri url = Uri(
                        scheme: 'mailto',
                        path: 'contact@publisher.com',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        print('Could not launch ${url.toString()}');
                      }
                    },
                    child: Text(
                      'contact@publisher.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.blueGrey),
                  SizedBox(width: 10),
                  Text(
                    "+1-800-123-4567",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blueGrey),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "1234 Publisher St, New York, NY 10001, USA",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Social Media Links
              Text(
                "Follow Us",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () async {
                      const url = 'https://facebook.com/publisher';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    icon: Icon(Icons.facebook, color: Colors.blue),
                    tooltip: "Facebook",
                  ),
                  IconButton(
                    onPressed: () async {
                      const url = 'https://twitter.com/publisher';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    icon: Icon(Icons.facebook, color: Colors.lightBlue),
                    tooltip: "Twitter",
                  ),
                  IconButton(
                    onPressed: () async {
                      const url = 'https://instagram.com/publisher';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    icon: Icon(Icons.camera_alt, color: Colors.pink),
                    tooltip: "Instagram",
                  ),
                ],
              ),

              Spacer(),

              // Footer or Copyright Notice
              Center(
                child: Text(
                  '© 2024 Publisher Name. All Rights Reserved.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
