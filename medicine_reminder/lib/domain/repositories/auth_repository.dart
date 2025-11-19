import '../entities/user.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Get current authenticated user
  Future<User?> getCurrentUser();

  /// Sign in with email and password
  Future<User> signInWithEmail(String email, String password);

  /// Sign up with email and password
  Future<User> signUpWithEmail(String email, String password, String? name);

  /// Sign in with Google
  Future<User> signInWithGoogle();

  /// Sign out
  Future<void> signOut();

  /// Update user profile
  Future<void> updateUserProfile(User user);

  /// Reset password
  Future<void> resetPassword(String email);

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;
}
