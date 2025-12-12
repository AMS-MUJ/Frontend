import 'package:ams_try2/features/auth/components/auth_field.dart';
import 'package:ams_try2/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const LoginPage());
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Optionally attempt to restore cached auth on page load
    // ref.read(authNotifierProvider.notifier).loadCachedAuth();
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    // Listen for auth changes: success -> navigate; failure -> show SnackBar
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.failure != null && next.failure != previous?.failure) {
        // show failure message
        _showError(next.failure!.message);
      }

      // If newly signed in (auth becomes non-null), navigate based on role
      if (next.auth != null && previous?.auth == null) {
        final role = next.auth!.user.role.toLowerCase();
        // Adjust routes '/teacher' and '/student' to your actual pages
        if (role == 'teacher') {
          Navigator.pushReplacementNamed(context, '/teacher');
        } else {
          Navigator.pushReplacementNamed(context, '/student');
        }
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Container(
        width: double.infinity,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 80),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // White bottom container
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // Email TextField
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE6E6E6),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: AuthField(
                            hintText: "Email",
                            controller: emailController,
                          ),
                        ),

                        const SizedBox(height: 17),

                        // Password TextField
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE6E6E6),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: AuthField(
                            hintText: "Password",
                            controller: passController,
                            isObscureText: true,
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to forgot password page
                            print("Forgot Password pressed");
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 0),
                          ),
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: authState.loading
                                ? null
                                : () {
                                    if (formKey.currentState?.validate() ??
                                        false) {
                                      final email = emailController.text.trim();
                                      final password = passController.text
                                          .trim();
                                      // call notifier to login
                                      ref
                                          .read(authNotifierProvider.notifier)
                                          .login(email, password);
                                    } else {
                                      // Basic validation: show error
                                      _showError(
                                        'Please enter email and password',
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                            child: authState.loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
