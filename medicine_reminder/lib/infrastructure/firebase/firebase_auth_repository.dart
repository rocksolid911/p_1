import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import 'models/user_model.dart';

/// Firebase implementation of AuthRepository
class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<domain.User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (!doc.exists) {
      // Create user document if it doesn't exist
      final user = _createUserFromFirebaseUser(firebaseUser);
      await _saveUserToFirestore(user);
      return user;
    }

    return UserModel.fromFirestore(doc).toEntity();
  }

  @override
  Future<domain.User> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed');
      }

      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        final user = _createUserFromFirebaseUser(credential.user!);
        await _saveUserToFirestore(user);
        return user;
      }

      return UserModel.fromFirestore(doc).toEntity();
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<domain.User> signUpWithEmail(
    String email,
    String password,
    String? name,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign up failed');
      }

      final user = _createUserFromFirebaseUser(credential.user!, name: name);
      await _saveUserToFirestore(user);

      return user;
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  @override
  Future<domain.User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Google sign in failed');
      }

      final doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!doc.exists) {
        final user = _createUserFromFirebaseUser(
          userCredential.user!,
          name: googleUser.displayName,
        );
        await _saveUserToFirestore(user);
        return user;
      }

      return UserModel.fromFirestore(doc).toEntity();
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<void> updateUserProfile(domain.User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(userModel.toFirestore());
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  @override
  Stream<domain.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (!doc.exists) {
        final user = _createUserFromFirebaseUser(firebaseUser);
        await _saveUserToFirestore(user);
        return user;
      }

      return UserModel.fromFirestore(doc).toEntity();
    });
  }

  // Helper methods

  domain.User _createUserFromFirebaseUser(
    firebase_auth.User firebaseUser, {
    String? name,
  }) {
    final now = DateTime.now();
    return domain.User(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: name ?? firebaseUser.displayName,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> _saveUserToFirestore(domain.User user) async {
    final userModel = UserModel.fromEntity(user);
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toFirestore());
  }
}
