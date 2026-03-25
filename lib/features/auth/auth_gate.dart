import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import '../../main_screen.dart';
import 'user_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Center(
                    child: Text(
                      'AI Magic',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          );
        }

        return UserInitializationWrapper(user: snapshot.data!);
      },
    );
  }
}

class UserInitializationWrapper extends StatefulWidget {
  final User user;
  const UserInitializationWrapper({super.key, required this.user});

  @override
  State<UserInitializationWrapper> createState() =>
      _UserInitializationWrapperState();
}

class _UserInitializationWrapperState extends State<UserInitializationWrapper> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    await UserService().checkAndCreateUser(widget.user);
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    // We will later change this to return the Main/BottomNav Screen
    return const MainScreen();
  }
}
