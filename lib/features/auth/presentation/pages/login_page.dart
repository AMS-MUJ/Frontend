import 'package:ams_try2/core/navigation/slide_page_route.dart';
import 'package:ams_try2/features/auth/components/auth_field.dart';
import 'package:ams_try2/features/auth/presentation/providers/auth_provider.dart';
import 'package:ams_try2/features/student/presentation/pages/student_home_page.dart';
import 'package:ams_try2/features/teacher/presentation/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  static Route<void> route() =>
      SlidePageRoute(child: const LoginPage(), direction: AxisDirection.left);

  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  late final ProviderSubscription<AuthState> _authListener;

  @override
  void initState() {
    super.initState();

    _authListener = ref.listenManual<AuthState>(authNotifierProvider, (
      previous,
      next,
    ) {
      // Show backend error only once
      if (next.failure != null && next.failure != previous?.failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.failure!.message)));
      }

      // Navigate on successful login
      if (next.auth != null && previous?.auth == null) {
        final role = next.auth!.user.role.toLowerCase();
        if (role == 'teacher') {
          Navigator.pushReplacement(
            context,
            SlidePageRoute(
              child: const Thomepage(),
              direction: AxisDirection.right,
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            SlidePageRoute(child: const StudentHomePage()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _authListener.close();
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // App title
                  const Center(
                    child: Text(
                      "AMS",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),

                  // Page title
                  const Center(
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Form container
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Email"),

                        const SizedBox(height: 6),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1,
                            ),
                          ),
                          child: AuthField(
                            controller: emailController,
                            isEmail: true,
                            errorText: "Enter registered email!",
                          ),
                        ),

                        const SizedBox(height: 17),

                        const Text("Password"),

                        const SizedBox(height: 6),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1,
                            ),
                          ),
                          child: AuthField(
                            controller: passController,
                            hintText: "Password",
                            isObscureText: true,
                            errorText: "Enter password",
                          ),
                        ),

                        const SizedBox(height: 15),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Forgot password
                            },
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
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
                                    // Required field validation
                                    if (!(formKey.currentState?.validate() ??
                                        false)) {
                                      return;
                                    }

                                    final email = emailController.text
                                        .trim()
                                        .toLowerCase();
                                    final password = passController.text.trim();

                                    // Domain validation → SnackBar
                                    final emailRegex = RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@(muj|jaipur)\.manipal\.edu$',
                                    );

                                    if (!emailRegex.hasMatch(email)) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Use your Manipal email (muj / jaipur)',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    // Call API
                                    ref
                                        .read(authNotifierProvider.notifier)
                                        .login(email, password);
                                  },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  8,
                                ), // 👈 here
                              ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
