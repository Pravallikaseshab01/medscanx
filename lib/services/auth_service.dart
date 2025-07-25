import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../models/user_profile_model.dart';

class AuthService {
  static final _client = SupabaseConfig.client;

  // Get current user
  static User? get currentUser => _client.auth.currentUser;

  // Get current user ID
  static String? get currentUserId => _client.auth.currentUser?.id;

  // Check if user is logged in
  static bool get isLoggedIn => _client.auth.currentUser != null;

  // Sign up new user
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String role = 'patient',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
          ...?additionalData,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in user
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out user
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile
  static Future<UserProfileModel?> getUserProfile([String? userId]) async {
    try {
      final id = userId ?? currentUserId;
      if (id == null) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return UserProfileModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  static Future<UserProfileModel> updateUserProfile({
    required String userId,
    String? fullName,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    Map<String, dynamic>? emergencyContact,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (dateOfBirth != null)
        updateData['date_of_birth'] =
            dateOfBirth.toIso8601String().split('T')[0];
      if (gender != null) updateData['gender'] = gender;
      if (emergencyContact != null)
        updateData['emergency_contact'] = emergencyContact;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('user_profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UserProfileModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // Verify email
  static Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        type: OtpType.signup,
        email: email,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Check if user has specific role
  static Future<bool> hasRole(String role) async {
    try {
      final profile = await getUserProfile();
      return profile?.role == role;
    } catch (e) {
      return false;
    }
  }

  // Check if user is doctor
  static Future<bool> isDoctor() async {
    return await hasRole('doctor');
  }

  // Check if user is admin
  static Future<bool> isAdmin() async {
    return await hasRole('admin');
  }

  // Get all doctors (for admin/patient use)
  static Future<List<UserProfileModel>> getDoctors() async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('role', 'doctor')
          .order('full_name');

      return response.map((json) => UserProfileModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Update last login timestamp
  static Future<void> updateLastLogin() async {
    try {
      if (currentUserId == null) return;

      await _client
          .from('user_profiles')
          .update({'updated_at': DateTime.now().toIso8601String()}).eq(
              'id', currentUserId!);
    } catch (e) {
      // Fail silently for last login update
    }
  }
}
