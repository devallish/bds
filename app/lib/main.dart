import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'presentation/screens/home_screen.dart';
import 'presentation/theme/bds_theme.dart';

// Local dev Supabase instance defaults (supabase start). Not secrets — these
// are the well-known local dev anon key/URL. Should become environment
// configurable (--dart-define or similar) once a non-local environment exists.
const _supabaseUrl = 'http://127.0.0.1:54321';
const _supabasePublishableKey = 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabasePublishableKey,
  );

  runApp(const ProviderScope(child: BdsApp()));
}

class BdsApp extends StatelessWidget {
  const BdsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BDS',
      theme: buildBdsTheme(),
      home: const _SignedInHome(),
    );
  }
}

/// Signs in as one of the local seed fixtures so there's a real authenticated
/// session for RLS to scope against. Stands in for a real login screen, which
/// is AuthRepository work — not part of this scaffold.
class _SignedInHome extends StatefulWidget {
  const _SignedInHome();

  @override
  State<_SignedInHome> createState() => _SignedInHomeState();
}

class _SignedInHomeState extends State<_SignedInHome> {
  late final Future<String> _memberIdFuture = _signIn();

  Future<String> _signIn() async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: 'test-member-south-east-1@example.test',
      password: 'password123',
    );
    return response.user!.id;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _memberIdFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Sign-in failed: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return HomeScreen(memberId: snapshot.data!);
      },
    );
  }
}
