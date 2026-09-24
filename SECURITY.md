# Melai Nuts — Security setup & responsibilities

> This project uses **Firebase Auth + Cloud Firestore** (with Firestore's built-in
> offline cache). It does **not** use Supabase or a separate SQLite package.
> Firestore Security Rules (`firestore.rules`) are the equivalent of Supabase RLS.

## What is enforced where

| Concern | Enforced by | Where |
|---|---|---|
| Who you are | Firebase Auth | Firebase |
| Your role / branch / active flag | `users/{uid}` document, read **server-side** by rules | `firestore.rules` |
| Who can read/write each collection | Firestore Security Rules | `firestore.rules` (deploy it!) |
| Screens shown for a role | `RouteGuard` (UX / defence-in-depth only) | `lib/app/route_guard.dart` |
| Rate limiting / brute force | Firebase Auth server-side throttling (+ App Check) | Firebase Console |

A modified app can bypass anything in Dart. It cannot bypass Firestore rules.

## Must-do steps outside the Flutter project

1. **Deploy the rules** — `firebase deploy --only firestore:rules`. Until you do,
   whatever rules are currently live in the console apply (the repo file is not
   automatically active). Run `firestore-tests/` against the emulator first
   (`cd firestore-tests && npm install && npm test`).
2. **Restrict every Firebase API key** (Google Cloud Console → APIs & Services →
   Credentials):
   - Android key: *Android apps* restriction (package `com.example.melai_nuts` →
     use your real package name + release **and** debug SHA-1s).
   - Web key: *HTTP referrers* restriction for your web domain(s).
   - Windows desktop uses the *web* app config and cannot be app-restricted —
     give it its **own** key restricted by **API** only (Identity Toolkit,
     Token Service, Firestore).
   - On every key use *API restrictions*: only the Firebase APIs you use.
3. **Two different Android API keys are committed**: one in
   `android/app/google-services.json`, another (previously base64-encoded) in
   `lib/firebase_options.dart`. Confirm which is live, delete the other, and run
   `flutterfire configure` so both files agree.
4. **Treat all committed keys as exposed.** They are in Git history and the old
   code comment says the base64 was added to avoid public leak alerts. Client
   keys are not secrets, but if Google/GitHub flagged them, create replacement
   restricted keys, ship them, then delete the old ones. (Rewriting history does
   not un-leak a key; restriction/rotation does.)
5. **Enable Firebase App Check** (Play Integrity for Android, reCAPTCHA for web)
   and *enforce* it for Authentication and Cloud Firestore. This is the main
   defence against abuse from clones/scripts using the public API key. It needs
   the `firebase_app_check` package plus console setup — add it together.
6. **Auth settings** (Firebase Console → Authentication → Settings):
   turn on *email enumeration protection*; set a password policy at least as
   strong as the app's (8+ chars, upper, number, symbol); consider requiring
   email verification for customers. Review the authorized domains list.
7. **First Owner account**: create the Firebase Auth user, then create
   `users/{uid}` in the console with `role: "owner"`, `isActive: true`,
   `email`, `name`. Owners create all other staff/owner/delivery accounts in-app.
8. **Release signing / package id**: `android/app/build.gradle.kts` signs release
   with the *debug* key and uses `com.example.*`. Set a real applicationId and a
   release keystore (kept out of Git — `.gitignore` covers `*.jks`, `key.properties`).
   Build releases with `--obfuscate --split-debug-info=...`.

## Email verification (only real emails can register)

Registration is two steps: (1) create the Firebase account (no profile, no
access yet), (2) prove the email, then the customer profile is created.
**Enforcement is server-side:** `firestore.rules` refuses the customer profile
unless the caller's token has `email_verified == true`. A client cannot set that
flag, so a modified app cannot skip verification. Unverified accounts have no
profile and therefore no access to anything.

Two modes (`lib/core/services/email_verification_service.dart`):

| Mode | When | How |
|---|---|---|
| Link | `EMAIL_API_BASE_URL` not set (works today) | Firebase emails a verification link |
| Code | `--dart-define=EMAIL_API_BASE_URL=https://your-api/auth` | Your API emails a 6-digit code |

**Your API contract** (both calls send `Authorization: Bearer <Firebase ID token>`):

- `POST {base}/send-code`, body `{}` -> 200 sent, 429 rate-limited.
- `POST {base}/verify-code`, body `{"code":"123456"}` -> 200 correct, 400/401/403
  wrong/expired, 429 too many attempts.

**The API MUST:**
1. Verify the ID token with the Admin SDK (`verifyIdToken`) and take the **uid and
   email from the token, never from the request body** (otherwise anyone can make
   your API email arbitrary addresses).
2. On a correct code call `admin.auth().updateUser(uid, { emailVerified: true })`.
   Without this step the Firestore rule blocks every registration.
3. Store only a **hash** of the code; expire it in ~10 minutes; allow ~5 wrong
   attempts then invalidate; single use.
4. Rate-limit send-code per uid/email/IP (e.g. 1 per 60s, ~5 per hour) and
   verify-code per uid. Consider App Check on these endpoints.
5. Be HTTPS only (the app refuses non-HTTPS URLs outside debug builds).
6. Keep the Admin SDK key on the server only — never in Flutter.

**Housekeeping:** abandoned unverified accounts keep their email address tied up.
The app deletes them when the person taps "Use a different email", but run a
scheduled job that deletes Auth users with `emailVerified == false` and no
`users/{uid}` document older than ~24h. Existing customers who registered before
this change already have profiles and are unaffected.

## Known limits (cannot be fully fixed from the Flutter client)

- **Order/price integrity**: rules can require ownership and `pending` status but
  cannot recompute totals from line items. Compute prices server-side (Cloud
  Function) before orders/payments become real.
- **Account creation by Owner** still creates the Auth user client-side. Moving it
  to a Cloud Function using the Admin SDK removes the need for any client to be
  able to create privileged Auth users.
- **Remote sign-out of other devices** and true account deletion need the Admin SDK.
  "Change password" ends other sessions.
- **2FA / biometric / PIN toggles** on the security screens are UI mock-ups; real
  MFA needs Firebase MFA (Identity Platform) or a `local_auth` flow.
- The Firestore offline cache is not encrypted at rest by Firestore. It is
  size-bounded and wiped at app start when no user is signed in.
- Most business data (products, orders, inventory, deliveries, refunds, loyalty)
  is still in-memory prototype data, not Firestore; rules for those collections
  were written against the model field names and need re-checking when wired.
