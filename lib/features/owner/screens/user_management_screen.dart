import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/dummy_data/dummy_accounts.dart';
import '../../../data/models/user_role.dart';

/// Owner-only screen to manage staff and system user accounts.
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final List<DemoAccount> _users = List.from(kDemoAccounts);
  String _searchQuery = '';

  void _addUser() {
    // Simulated add
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add User functionality coming soon (Demo)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _users.where((u) => 
      u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      u.role.label.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Manage User Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: _addUser,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'Search users by name or role...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: filteredUsers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final user = filteredUsers[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: user.role.color.withValues(alpha: 0.15),
                        child: Icon(user.role.icon, color: user.role.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: AppTextStyles.labelLg),
                            Text(user.role.label, style: AppTextStyles.bodySm),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Active', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(user.email, style: AppTextStyles.bodySm),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.more_vert_rounded, size: 18),
                        onPressed: () {},
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
