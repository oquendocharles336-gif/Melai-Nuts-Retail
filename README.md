# melai_nuts

A Prototype

## Setup: Firebase keys (required)

Firebase API keys are **not committed**. Before running:

```bash
cp env/firebase.example.json env/firebase.json          # then fill in your keys
cp android/app/google-services.json.example android/app/google-services.json  # Android only

flutter run --dart-define-from-file=env/firebase.json --dart-define-from-file=env/supabase.json
flutter build apk --dart-define-from-file=env/firebase.json --dart-define-from-file=env/supabase.json
```

`env/firebase.json` and `android/app/google-services.json` are git-ignored.
See [SECURITY.md](SECURITY.md) for key restriction and rotation.

## Setup: Supabase backend (required)

The app stores all business data (catalog, cart, orders, loyalty, payments,
refunds, notifications, addresses) in Supabase. Firebase remains the identity
provider. The app will not start without these values.

1. In the Supabase dashboard enable **Authentication > Sign In / Providers >
   Third Party Auth > Firebase** and paste your Firebase **Project ID**.
2. Run the SQL in this order (SQL Editor or `psql`):
   1. `supabase/schema.sql`
   2. `supabase/migrations/20260928000000_customer_security_hardening.sql`
   3. `supabase/migrations/20260928010000_order_integrity.sql`
   4. `supabase/migrations/20260929000000_customer_product_search.sql`
3. Copy `env/supabase.example.json` to `env/supabase.json` and fill in the
   project URL and **anon** key (never the `service_role` key).
4. Run with both files:

```bash
flutter run \
  --dart-define-from-file=env/firebase.json \
  --dart-define-from-file=env/supabase.json
```

`env/supabase.json` is git-ignored. Verify a dev/staging database with the
suites in `supabase/tests/` (dev only; each rolls back its own data).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
