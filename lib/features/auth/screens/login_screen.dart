import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/lang_keys.dart';
import '../../../core/shared_widgets/language_switcher_widget.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // The Key and Controllers now live inside the screen's state.
  // Their lifecycle is tied to this widget.
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: "admin@admin.com");
  final _passwordController = TextEditingController(text: "admin@123");

  // We still find the AuthController to use its methods.
  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    // Properly dispose of controllers when the screen is removed.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _performLogin() {
    // Validate the form first
    if (_formKey.currentState!.validate()) {
      // Call the controller's login method with the text from our controllers
      _authController.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                    ),
                  ],
                ),
                child: Form(
                  // Use the local form key
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        LangKeys.loginTitle.tr,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        // Use the local email controller
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: LangKeys.email.tr,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || !GetUtils.isEmail(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        // Use the local password controller
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: LangKeys.password.tr,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      // Listen to the controller's loading state
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _authController.isLoggingIn.value
                                ? null
                                : _performLogin,
                            child: _authController.isLoggingIn.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(LangKeys.loginButton.tr),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            top: 16,
            right: 16,
            child: LanguageSwitcherWidget(),
          ),
        ],
      ),
    );
  }
}
