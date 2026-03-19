import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool agreeToTerms = false;
  
  // 💜 Purple Brand Color (Matches your Login Page)
  final Color brandColor = const Color(0xFF7C3AED);

  // ================= SIGNUP LOGIC =================
  Future<void> signup() async {
    if (nameController.text.trim().isEmpty || 
        emailController.text.trim().isEmpty || 
        passwordController.text.isEmpty) {
      _showMessage("Please fill in all fields");
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showMessage("Passwords do not match");
      return;
    }
    if (!agreeToTerms) {
      _showMessage("Please agree to the terms");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      _showMessage("Account Created Successfully!");
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "Signup Failed");
    } catch (e) {
      _showMessage("An unexpected error occurred");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================= GOOGLE SIGNUP =================
  Future<void> googleSignup() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? user = await googleSignIn.signIn();
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication auth = await user.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showMessage("Google Signup Failed");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF), // 💜 Light purple background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: brandColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 10),

                // Signup Card
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5FF), // 💜 Card color
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Join our professional community and start managing your library.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 32),

                      _buildLabel("FULL NAME"),
                      _buildTextField(nameController, "John Doe", false),
                      
                      const SizedBox(height: 20),
                      
                      _buildLabel("EMAIL ADDRESS"),
                      _buildTextField(emailController, "name@company.com", false),

                      const SizedBox(height: 20),

                      _buildLabel("PASSWORD"),
                      _buildTextField(passwordController, "••••••••", true),

                      const SizedBox(height: 20),

                      _buildLabel("CONFIRM PASSWORD"),
                      _buildTextField(confirmPasswordController, "••••••••", true),

                      const SizedBox(height: 20),

                      // Terms Checkbox
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: agreeToTerms,
                              activeColor: brandColor,
                              onChanged: (v) => setState(() => agreeToTerms = v ?? false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "I agree to the Terms & Conditions",
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Signup Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Create Account", 
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text("Or continue with", style: TextStyle(color: Colors.grey.shade400)),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Google Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: googleSignup,
                          icon: Icon(Icons.g_mobiledata, size: 30, color: brandColor),
                          label: const Text(
                            "Continue with Google",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade200),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Footer (Navigate to Login)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ", style: TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Log In",
                        style: TextStyle(color: brandColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text, 
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool obscure) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFEDE9FE), // 💜 Light purple input field
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}