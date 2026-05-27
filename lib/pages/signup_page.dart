import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/big_text.dart';
import 'package:trial_project/pet/pet_store_controller.dart';
import 'package:provider/provider.dart';
import '../responsive/responsive_layout.dart';
import '../responsive/mobile_body.dart';
import '../responsive/desktop_body.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    setState(() => _isLoading = true);

    final success = await AuthService().registerWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        if (mounted) {
          Provider.of<PetStoreController>(context, listen: false).setAdminMode(false);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account Created Successfully!"), backgroundColor: Color(0xFF4DB6AC)),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResponsiveLayout(
              mobileBody: const MyMobileBody(),
              desktopBody: MyDesktopBody(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration failed. Email might already be in use."), backgroundColor: Colors.orange),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color deepPurpleGlow = Colors.deepPurple[700]!;
    const Color tealIndicator = Color(0xFF4DB6AC);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/petslider/sing_up_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🌟 CONSISTENT LOGO BLOCK: Matches LoginPage for brand identity
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple[50],
                                shape: BoxShape.circle,
                              ),
                            ),
                            Image.asset(
                              'assets/images/petslider/logo.png',
                              height: 160,
                              width: 160,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Center(child: BigText(text: "Create Account", size: 24)),
                      const Center(child: Text("Join our premium petcare community", style: TextStyle(color: Colors.black38, fontSize: 13))),
                      const SizedBox(height: 32),

                      const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isLoading,
                        validator: (v) => (v == null || !v.contains('@')) ? "Enter a valid email address" : null,
                        decoration: _buildInputDecoration("name@example.com", Icons.mail_outline_rounded),
                      ),
                      const SizedBox(height: 18),

                      const Text("Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        enabled: !_isLoading,
                        validator: (v) => (v == null || v.trim().length < 6) ? "Password must be at least 6 characters" : null,
                        decoration: _buildInputDecoration("••••••••", Icons.lock_outline_rounded).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: Colors.grey[400]),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      const Text("Confirm Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        enabled: !_isLoading,
                        validator: (v) {
                          if (v != _passwordController.text) return "Passwords do not match";
                          return null;
                        },
                        decoration: _buildInputDecoration("••••••••", Icons.lock_reset_rounded).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: Colors.grey[400]),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      GestureDetector(
                        onTap: _isLoading ? null : () {
                          if (_formKey.currentState!.validate()) {
                            _handleRegistration();
                          }
                        },
                        child: Container(
                          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(color: _isLoading ? Colors.grey[300] : deepPurpleGlow, borderRadius: BorderRadius.circular(14)),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text("SIGN UP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? ", style: TextStyle(color: Colors.black38, fontSize: 13)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text("Sign in", style: TextStyle(color: tealIndicator, fontWeight: FontWeight.bold, fontSize: 13)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
      prefixIcon: Icon(icon, size: 18, color: Colors.grey[400]),
      filled: true,
      fillColor: const Color(0xFFF5F5F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    );
  }
}
