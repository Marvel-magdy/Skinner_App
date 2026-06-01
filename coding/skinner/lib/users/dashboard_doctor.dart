import 'package:flutter/material.dart';

import 'package:skinner/authuntication/signin.dart';
import 'package:skinner/screens/chat_screens.dart';

import 'package:skinner/screens/doctor/pending_screen.dart';
import 'package:skinner/screens/doctor/finished_screen.dart';
import 'package:skinner/screens/doctor/schedule_screen.dart';

class DoctorPortalScreen extends StatefulWidget {
  const DoctorPortalScreen({super.key});

  @override
  State<DoctorPortalScreen> createState() =>
      _DoctorPortalScreenState();
}

class _DoctorPortalScreenState
    extends State<DoctorPortalScreen> {

  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF6F7FB),

      /// AppBar
      appBar: _buildAppBar(context),

      /// Chat Button
      floatingActionButton:
          FloatingActionButton(

        backgroundColor:
            const Color(0xFF2C67FF),

        child: const Icon(
          Icons.smart_toy,
          color: Colors.white,
        ),

        onPressed: () {

          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) =>
                  const ChatScreen(),
            ),
          );
        },
      ),

      /// Responsive Body
      body: LayoutBuilder(

        builder: (context, constraints) {

          double width =
              constraints.maxWidth;

          bool isSmall =
              width < 360;

          return Column(

            children: [

              SizedBox(
                height:
                    isSmall ? 8 : 12,
              ),

              /// Tabs
              Padding(
                padding:
                    EdgeInsets.symmetric(
                  horizontal:
                      width * 0.04,
                ),

                child: _buildTabs(),
              ),

              SizedBox(
                height:
                    isSmall ? 8 : 12,
              ),

              /// Content
              Expanded(
                child: _buildBody(),
              ),
            ],
          );
        },
      ),
    );
  }

  /// AppBar
  PreferredSizeWidget
      _buildAppBar(BuildContext context) {

    return AppBar(

      backgroundColor:
          Colors.transparent,

      elevation: 0,

      title: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            "Skinner",
            style: TextStyle(
              color: Colors.black,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          Text(
            "Doctor Portal",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),

      actions: [

        Padding(
          padding:
              const EdgeInsets.only(
                  right: 12),

          child: OutlinedButton.icon(

            onPressed: () {

              Navigator.pushAndRemoveUntil(
                context,

                MaterialPageRoute(
                  builder: (_) =>
                      const SignIn(),
                ),

                (route) => false,
              );
            },

            icon:
                const Icon(Icons.logout,
                    size: 18),

            label:
                const Text("Logout"),
          ),
        )
      ],
    );
  }

  /// Tabs
  Widget _buildTabs() {

    return SingleChildScrollView(

      scrollDirection:
          Axis.horizontal,

      child: Row(

        children: [

          _tabItem(
              "Pending Cases ",0),

          const SizedBox(width: 8),

          _tabItem(
              "Finished Cases", 1),

          const SizedBox(width: 8),

          _tabItem("Schedule", 2),
        ],
      ),
    );
  }

  /// Tab Item
  Widget _tabItem(
      String title,
      int index) {

    bool isActive =
        _activeTabIndex == index;

    return GestureDetector(

      onTap: () {

        setState(() {
          _activeTabIndex = index;
        });
      },

      child: Container(

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        decoration: BoxDecoration(

          color: isActive
              ? Colors.black
              : Colors.white,

          borderRadius:
              BorderRadius.circular(
                  20),

          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),

        child: Text(

          title,

          style: TextStyle(

            color: isActive
                ? Colors.white
                : Colors.black,

            fontWeight:
                FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Body
  Widget _buildBody() {

    if (_activeTabIndex == 0) {

      return const PendingScreen();
    }

    else if (_activeTabIndex == 1) {

      return const FinishedScreen();
    }

    else {

      return const ScheduleScreen();
    }
  }
}