// Supabase configuration for Melai Nuts.
//
// The Supabase project URL + anon (public) key are NOT stored in source
// control. They are injected at build time, exactly like env/firebase.json:
//
//   flutter run \
//     --dart-define-from-file=env/firebase.json \
//     --dart-define-from-file=env/supabase.json
//
// Copy env/supabase.example.json to env/supabase.json (git-ignored) and fill
// in the values from your Supabase project's Settings > API page.
//
// The anon/publishable key is safe to ship in a client app — it identifies
// the project, not a privileged user. Every table it can reach is still
// protected by Postgres Row Level Security (see supabase/schema.sql); this
// key alone grants no access beyond what those policies allow. Never put
// the `service_role` (or any "secret") key in this app.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static void requireConfigured() {
    if (!isConfigured) {
      throw StateError(
        'Supabase URL/anon key are missing. Run with '
            '--dart-define-from-file=env/supabase.json '
            '(copy env/supabase.example.json first, fill in your project\'s '
            'values, and run supabase/schema.sql against that project). '
            'See SECURITY.md.',
      );
    }
  }
}