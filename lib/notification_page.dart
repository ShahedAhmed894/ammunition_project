import 'package:flutter/material.dart';
import 'NotificationService/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _selectedSeconds = 10;
  bool _isRecurringEnabled = true;
  bool _isAdminAuthenticated = false;
  bool _obscurePassword = true;

  static const String _adminPassword = "@admin";

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Color(0xFFE74C3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _verifyAdminPassword() {
    if (_passwordController.text == _adminPassword) {
      setState(() {
        _isAdminAuthenticated = true;
      });
      _passwordController.clear();
      _showSuccessSnackBar('Admin access granted!');
    } else {
      _showErrorSnackBar('Incorrect password. Please try again.');
      _passwordController.clear();
    }
  }

  void _showAdminLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Color(0xFFE74C3C)),
            SizedBox(width: 12),
            Text(
              'Admin Login',
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter admin password to access schedule notification',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Color(0xFF2C3E50)),
                prefixIcon: Icon(Icons.lock, color: Color(0xFFE74C3C)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE74C3C), width: 2),
                ),
              ),
              onSubmitted: (_) {
                _verifyAdminPassword();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _passwordController.clear();
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _verifyAdminPassword();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE74C3C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Verify',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Color(0xFF2C3E50),
        elevation: 4,
        centerTitle: true,
        title: const Text(
          "NOTIFICATIONS",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isAdminAuthenticated)
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout Admin',
              onPressed: () {
                setState(() {
                  _isAdminAuthenticated = false;
                });
                _showSuccessSnackBar('Admin logged out');
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE74C3C),
                    Color(0xFFC0392B),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFE74C3C).withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Notification Center",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _isAdminAuthenticated
                              ? "Admin Mode Active"
                              : "Manage your notifications",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Quick Actions Section
            Text(
              "QUICK ACTIONS",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 16),

            _buildNotificationCard(
              icon: Icons.waving_hand,
              title: "Welcome Notification",
              subtitle: "Send a welcome message",
              color: Color(0xFF3498DB),
              onTap: () async {
                await NotificationService.showWelcomeNotification();
                _showSuccessSnackBar('Welcome notification sent!');
              },
            ),

            _buildNotificationCard(
              icon: Icons.new_releases,
              title: "New Product Alert",
              subtitle: "Notify about new products",
              color: Color(0xFF9B59B6),
              onTap: () async {
                await NotificationService.showNewProductNotification("M4A1 Rifle");
                _showSuccessSnackBar('New product notification sent!');
              },
            ),

            _buildNotificationCard(
              icon: Icons.local_fire_department,
              title: "Promotional Offer",
              subtitle: "Send special offers",
              color: Color(0xFF2ECC71),
              onTap: () async {
                await NotificationService.showPromoNotification();
                _showSuccessSnackBar('Promotional notification sent!');
              },
            ),

            _buildNotificationCard(
              icon: Icons.warning_amber,
              title: "Stock Alert",
              subtitle: "Low stock warning",
              color: Color(0xFFF39C12),
              onTap: () async {
                await NotificationService.showStockAlertNotification("9mm Ammo", 15);
                _showSuccessSnackBar('Stock alert notification sent!');
              },
            ),

            SizedBox(height: 24),

            // Schedule Notification Section (Admin Only)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "SCHEDULE NOTIFICATION",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                    letterSpacing: 1,
                  ),
                ),
                if (!_isAdminAuthenticated)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFE74C3C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color(0xFFE74C3C)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.admin_panel_settings, color: Color(0xFFE74C3C), size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Admin Only',
                          style: TextStyle(
                            color: Color(0xFFE74C3C),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),

            if (!_isAdminAuthenticated)
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: Color(0xFFE74C3C),
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Admin Access Required',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please login with admin credentials to schedule notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showAdminLoginDialog,
                        icon: Icon(Icons.admin_panel_settings, color: Colors.white),
                        label: Text(
                          'Admin Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE74C3C),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Notification Title',
                        labelStyle: TextStyle(color: Color(0xFF2C3E50)),
                        prefixIcon: Icon(Icons.title, color: Color(0xFFE74C3C)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFFE74C3C), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _bodyController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notification Message',
                        labelStyle: TextStyle(color: Color(0xFF2C3E50)),
                        prefixIcon: Icon(Icons.message, color: Color(0xFFE74C3C)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFFE74C3C), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Schedule After:",
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [10, 30, 60, 120, 300].map((seconds) {
                        bool isSelected = _selectedSeconds == seconds;
                        return ChoiceChip(
                          label: Text(
                            seconds < 60 ? '$seconds sec' : '${seconds ~/ 60} min',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Color(0xFF2C3E50),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Color(0xFFE74C3C),
                          backgroundColor: Colors.grey[200],
                          onSelected: (selected) {
                            setState(() {
                              _selectedSeconds = seconds;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
                            _showErrorSnackBar('Please fill in all fields');
                            return;
                          }

                          await NotificationService.scheduleNotification(
                            title: _titleController.text,
                            body: _bodyController.text,
                            seconds: _selectedSeconds,
                          );

                          _showSuccessSnackBar(
                            'Notification scheduled for $_selectedSeconds seconds from now',
                          );

                          _titleController.clear();
                          _bodyController.clear();
                        },
                        icon: Icon(Icons.schedule, color: Colors.white),
                        label: Text(
                          "Schedule Notification",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2C3E50),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 24),

            // Cancel All Section
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await NotificationService.cancelAllNotifications();
                  _showSuccessSnackBar('All notifications cancelled');
                },
                icon: Icon(Icons.cancel, color: Colors.white),
                label: Text(
                  "Cancel All Notifications",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE74C3C),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_forward,
            color: color,
            size: 20,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}