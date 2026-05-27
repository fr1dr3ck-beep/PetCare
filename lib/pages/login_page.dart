import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/big_text.dart';
import 'signup_page.dart';
import '../responsive/responsive_layout.dart';
import '../responsive/mobile_body.dart';
import '../responsive/desktop_body.dart';
import 'package:provider/provider.dart';
import 'package:trial_project/pet/pet_store_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignIn() async {
    setState(() => _isLoading = true);

    final storeController = Provider.of<PetStoreController>(context, listen: false);
    String inputUser = _emailController.text.trim();
    String inputPass = _passwordController.text.trim();

    // 🚀 INTERCEPTS SPECIALADMIN CREDENTIAL HOOKS NATIVELY
    if (inputUser == "SpecialAdmin" && (inputPass == "specialadmin1122" || inputPass == "specialadmin00")) {
      storeController.setAdminMode(true);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Welcome back, Special Admin!"), backgroundColor: Color(0xFF4DB6AC)),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileBody: MyMobileBody(),
              desktopBody: MyDesktopBody(),
            ),
          ),
        );
      }
      return;
    }

    final success = await AuthService().signInWithEmail(
      email: inputUser,
      password: inputPass,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        storeController.setAdminMode(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Welcome back!"), backgroundColor: Color(0xFF4DB6AC)),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileBody: MyMobileBody(),
              desktopBody: MyDesktopBody(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password."), backgroundColor: Colors.orange),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final success = await AuthService().signInWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        if (mounted) {
          Provider.of<PetStoreController>(context, listen: false).setAdminMode(false);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Authentication Successful!"), backgroundColor: Color(0xFF4DB6AC)),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileBody: MyMobileBody(),
              desktopBody: MyDesktopBody(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Authentication aborted."), backgroundColor: Colors.orange),
        );
      }
    }
  }

  // 🚀 SUPABASE INTERACTIVE PASSWORD RESET MODAL DIALOG
  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    bool isResetLoading = false;

    // Prefills the email automatically if they already filled it out on the main layout
    if (_emailController.text.isNotEmpty) {
      resetEmailController.text = _emailController.text.trim();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              title: const Row(
                children: [
                  Icon(Icons.lock_reset_rounded, color: Colors.deepPurple, size: 22),
                  SizedBox(width: 8),
                  Text("Reset Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter your verified account email address. Supabase will securely dispatch a magic link to reset your password.",
                    style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isResetLoading,
                    decoration: const InputDecoration(
                      hintText: "name@example.com",
                      hintStyle: TextStyle(fontSize: 12, color: Colors.black26),
                      filled: true,
                      fillColor: Color(0xFFF5F5F7),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isResetLoading ? null : () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: isResetLoading
                      ? null
                      : () async {
                    String targetEmail = resetEmailController.text.trim();
                    if (targetEmail.isEmpty || !targetEmail.contains('@')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please input a valid email address."), backgroundColor: Colors.orange),
                      );
                      return;
                    }

                    setDialogState(() => isResetLoading = true);

                    // Calls your Supabase-configured method
                    bool resetSent = await AuthService().sendPasswordReset(email: targetEmail);

                    if (context.mounted) {
                      setDialogState(() => isResetLoading = false);
                      Navigator.pop(context);

                      if (resetSent) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Supabase link dispatched! Check your mailbox instructions."),
                            backgroundColor: Color(0xFF4DB6AC),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Failed to send reset link. Verify email setup."), backgroundColor: Colors.orange),
                        );
                      }
                    }
                  },
                  child: isResetLoading
                      ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurple))
                      : const Text("Send Link", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
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
            image: AssetImage('assets/images/petslider/sing_up_bg.png'), //
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
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🌟 CONSISTENT DECOUPLED BRAND LOGO ARCHITECTURE
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 150, //
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple[50],
                                shape: BoxShape.circle,
                              ),
                            ),
                            Image.asset(
                              'assets/images/petslider/logo.png', //
                              height: 160,
                              width: 160,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Center(child: BigText(text: "Welcome Back", size: 24)),
                      const Center(child: Text("Access your premium petcare dashboard", style: TextStyle(color: Colors.black38, fontSize: 13))),
                      const SizedBox(height: 32),
                      const Text("Email Address / Username", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isLoading,
                        decoration: _buildInputDecoration("name@example.com", Icons.mail_outline_rounded),
                      ),
                      const SizedBox(height: 18),

                      // 🔒 RESTORED & OPTIMIZED PASSWORD LABEL ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                          GestureDetector(
                            onTap: _isLoading ? null : _showForgotPasswordDialog,
                            child: Text(
                              "Forgot?",
                              style: TextStyle(
                                color: _isLoading ? Colors.grey : deepPurpleGlow,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        enabled: !_isLoading,
                        decoration: _buildInputDecoration("••••••••", Icons.lock_outline_rounded).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: Colors.grey[400]),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                          if (_formKey.currentState!.validate()) {
                            _handleEmailSignIn();
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(color: _isLoading ? Colors.grey[300] : deepPurpleGlow, borderRadius: BorderRadius.circular(14)),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text("SIGN IN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[200], thickness: 1)),
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text("OR CONTINUE WITH",
                                  style: TextStyle(fontSize: 10, color: Colors.black26, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                          Expanded(child: Divider(color: Colors.grey[200], thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _isLoading ? null : _handleGoogleSignIn,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey[200]!, width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/google-icon.png', height: 18),
                              const SizedBox(width: 10),
                              const Text("Google Account", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ", style: TextStyle(color: Colors.black38, fontSize: 13)),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPage()));
                            },
                            child: const Text("Sign up", style: TextStyle(color: tealIndicator, fontWeight: FontWeight.bold, fontSize: 13)),
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