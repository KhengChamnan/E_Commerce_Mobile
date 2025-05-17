import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_menu_item.dart';
import 'widgets/logout_button.dart';

class ProfileScreen extends StatelessWidget {
  final User? user;
  final Function? onLogout;
  
  const ProfileScreen({Key? key, this.user, this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
       
        
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header with user info
              ProfileHeader(
                name: user?.name ?? 'Guest User',
                email: user?.email ?? 'Not logged in',
                avatarUrl: null,
                onEditProfile: () {
                  // TODO: Navigate to edit profile screen
                },
              ),
              
              const SizedBox(height: 16),
              
              // Profile menu items
              ProfileMenuItem(
                iconPath: 'assets/profile_icons/location_icon.svg',
                title: 'Address',
                iconColor: Colors.black,
                onTap: () {
                  // TODO: Navigate to address screen
                },
              ),
              
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              
              ProfileMenuItem(
                iconPath: 'assets/profile_icons/notification_icon.svg',
                title: 'Notification',
                iconColor: Colors.black,
                onTap: () {
                  // TODO: Navigate to notifications screen
                },
              ),
              
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              
              ProfileMenuItem(
                iconPath: 'assets/profile_icons/dark_mode_icon.svg',
                title: 'Dark Mode',
                iconColor: Colors.black,
                onTap: () {
                  // TODO: Toggle dark mode
                },
              ),
              
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              
              ProfileMenuItem(
                iconPath: 'assets/profile_icons/shield_icon.svg',
                title: 'Privacy Policy',
                iconColor: Colors.black,
                onTap: () {
                  // TODO: Navigate to privacy policy screen
                },
              ),
              
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              
              ProfileMenuItem(
                iconPath: 'assets/profile_icons/document_icon.svg',
                title: 'Terms & Conditions',
                iconColor: Colors.black,
                onTap: () {
                  // TODO: Navigate to terms & conditions screen
                },
              ),
              
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              
              const SizedBox(height: 32),
              
              // Logout button
              LogoutButton(
                onLogout: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(
                        'Logout',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      content: const Text(
                        'Are you sure you want to logout?',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Close dialog
                            Navigator.pop(context);
                            // Call the logout function from parent if provided
                            if (onLogout != null) {
                              onLogout!();
                            }
                          },
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFC12530),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}