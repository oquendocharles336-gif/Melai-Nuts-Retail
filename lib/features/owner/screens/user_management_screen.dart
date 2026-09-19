import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/dummy_data/dummy_accounts.dart';
import '../../../data/models/user_role.dart';

void _showAddUserDemo(BuildContext context) {
  // Simulated add
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Add User functionality coming soon (Demo)')),
  );
}

/// Owner-only screen to manage staff and system user accounts. Standalone
/// page (kept so the `/owner/users` route still works); the content lives in
/// [UserManagementBody], which is also the "Users" tab in the Owner Portal.
class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Manage User Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () => _showAddUserDemo(context),
          ),
        ],
      ),
      body: const UserManagementBody(),
    );
  }
}

/// User list + search. Has no Scaffold of its own so it can be used as a tab
/// body. When [showAddButton] is true (tab mode, where there is no app-bar
/// action) an "add user" button is shown next to the search field.
class UserManagementBody extends StatefulWidget {
  final bool showAddButton;
  const UserManagementBody({super.key, this.showAddButton = false});

  @override
  State<UserManagementBody> createState() => _UserManagementBodyState();
}

class _UserManagementBodyState extends State<UserManagementBody> {
  final List<DemoAccount> _users = List.from(kDemoAccounts);
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _users.where((u) =>
    u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        u.role.label.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: const InputDecoration(
                    hintText: 'Search users by name or role...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              if (widget.showAddButton) ...[
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Add user',
                  icon: const Icon(Icons.person_add_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.roleOwner,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: () => _showAddUserDemo(context),
                ),
              ],
            ],
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
    );
  }
}