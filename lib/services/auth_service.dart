import 'package:flutter/foundation.dart'; // 🚀 FIXED: Added to resolve the debugPrint compilation error!
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client; //

  // --- GOOGLE OAUTH SIGN IN ---
  Future<bool> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: null, // Bypasses the Windows desktop crash
      );
      return true;
    } catch (e) {
      print("Google Sign-in Error Trace: $e");
      return false;
    }
  }

  // --- PASSWORD RESET (SUPABASE) ---
  Future<bool> sendPasswordReset({required String email}) async {
    try {
      // 🚀 OPTIMIZED: Cleaned up to natively leverage your local '_supabase' client pointer
      await _supabase.auth.resetPasswordForEmail(
        email,
        // redirectTo handles opening your app back up when they click the email link
        redirectTo: 'io.supabase.trialproject://login-callback/',
      );
      return true;
    } catch (e) {
      debugPrint("Supabase Reset Error: $e"); // Now resolves perfectly
      return false;
    }
  }

  // --- EMAIL & PASSWORD LOGIN ---
  Future<bool> signInWithEmail({required String email, required String password}) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      print("Login Error Trace: $e");
      return false;
    }
  }

  // --- EMAIL & PASSWORD REGISTRATION ---
  Future<bool> registerWithEmail({required String email, required String password}) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      print("Registration Error Trace: $e");
      return false;
    }
  }

  User? get currentUser => _supabase.auth.currentUser; //

  Future<void> signOut() async {
    await _supabase.auth.signOut(); //
  }
}