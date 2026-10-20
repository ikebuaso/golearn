# Go Learn

Go Learn is a Flutter learning platform for Android and desktop web.

## Run the app

The landing page and sign-up preview work without external credentials. To
enable Clerk sign-in and sign-up, run with your Clerk **publishable** key:

```sh
flutter run --dart-define=CLERK_PUBLISHABLE_KEY=pk_test_your_key
```

The Clerk Flutter SDK is community-maintained. Configure the sign-in and
sign-up methods in the Clerk Dashboard before testing the flow.

## Provision user profiles

New public sign-ups are assigned the `student` role and `approved: false`.
Clerk webhooks securely provision `/users/{clerkUserId}` in Firestore and
initialize the same values in Clerk public metadata. User updates sync name,
email, role, and approval status without overwriting administrator changes.
Only the trusted Cloud Function writes Firestore user profiles; the included
Firestore rules deny direct client access until an authenticated data-access
flow is configured.

1. Create a Firebase project and select it with `firebase use --add`.
2. Set the two server-side secrets (do not put these in Flutter or commit them):

   ```sh
   firebase functions:secrets:set CLERK_WEBHOOK_SECRET
   firebase functions:secrets:set CLERK_SECRET_KEY
   ```

3. Install and build the function, then deploy it and the initial rules:

   ```sh
   npm --prefix functions install
   npm --prefix functions run build
   firebase deploy --only functions,firestore:rules
   ```

4. Add the deployed function URL as a Clerk webhook endpoint and subscribe to
   `user.created`, `user.updated`, and `user.deleted`.

The endpoint verifies Clerk's Svix signature before processing an event.
