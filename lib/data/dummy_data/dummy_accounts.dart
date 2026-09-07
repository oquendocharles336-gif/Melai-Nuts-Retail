import '../models/user_role.dart';

/// Dummy demo accounts used by the "Quick Demo Role Switcher" on the login
/// screen. No real authentication is performed — this only pre-fills the
/// form fields so reviewers can preview each portal quickly.
///
/// All demo accounts share the same password so it's easy to remember
/// while testing: [kDemoPassword].
const String kDemoPassword = 'melainuts123';

class DemoAccount {
  final UserRole role;
  final String name;
  final String subtitle;
  final String email;
  final String password;

  const DemoAccount({
    required this.role,
    required this.name,
    required this.subtitle,
    required this.email,
    this.password = kDemoPassword,
  });
}

const List<DemoAccount> kDemoAccounts = [
  DemoAccount(
    role: UserRole.owner,
    name: 'Maria Melai',
    subtitle: 'HQ Oversight',
    email: 'owner@melainuts.com',
  ),
  DemoAccount(
    role: UserRole.staff,
    name: 'Calamba Br.',
    subtitle: 'Register / POS',
    email: 'staff@melainuts.com',
  ),
  DemoAccount(
    role: UserRole.delivery,
    name: 'Juan Rider',
    subtitle: 'Logistics Mobile',
    email: 'delivery@melainuts.com',
  ),
  DemoAccount(
    role: UserRole.customer,
    name: 'Elena',
    subtitle: 'Golden Kernel',
    email: 'customer@melainuts.com',
  ),
];

/// Looks up a demo account by email (case-insensitive), if any. Used to
/// simulate "logging in" as a specific role when someone types one of the
/// documented dummy credentials instead of tapping a role badge.
DemoAccount? findDemoAccountByEmail(String email) {
  final normalized = email.trim().toLowerCase();
  for (final acc in kDemoAccounts) {
    if (acc.email.toLowerCase() == normalized) return acc;
  }
  return null;
}
