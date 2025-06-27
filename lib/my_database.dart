import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _users = FirebaseFirestore.instance.collection('Users');

  // Add User
  Future<void> insertUser(Map<String, dynamic> user) async {
    await _users.doc(user['email']).set(user);
  }

  // Check if email exists
  Future<bool> checkEmailExists(String email) async {
    final doc = await _users.doc(email).get();
    return doc.exists;
  }

  // Check VIN
  Future<bool> checkVinExists(String vin) async {
    final query = await _users.where('vin', isEqualTo: vin).limit(1).get();
    return query.docs.isNotEmpty;
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<Map<String, dynamic>?> verifyUserCredentials(String email, String vin) async {
  try {
  // Try to find user by VIN
  final vinQuery = await _db
      .collection('users')
      .where('vin', isEqualTo: vin)
      .limit(1)
      .get();

  if (vinQuery.docs.isNotEmpty) {
  return vinQuery.docs.first.data();
  }

  // If not found, try by email
  final emailQuery = await _db
      .collection('users')
      .where('email', isEqualTo: email)
      .limit(1)
      .get();

  if (emailQuery.docs.isNotEmpty) {
  return emailQuery.docs.first.data();
  }

  // User not found
  return null;
  } catch (e) {
  print('Error fetching user: $e');
  return null;
  }
  }


  // Update password
  Future<void> updateUserPassword(String email, String vin,
      String currentPassword, String newPassword) async {
    final user = await verifyUserCredentials(email, vin);
    if (user == null) throw Exception('User not found');
    if (user['password'] != currentPassword) {
      throw Exception('Current password is incorrect');
    }
    await _users.doc(email).update({'password': newPassword});
  }

  // Reset password (no current password needed)
  Future<void> resetUserPassword(
      String email, String vin, String newPassword) async {
    final user = await verifyUserCredentials(email, vin);
    if (user == null) throw Exception('User not found');
    await _users.doc(email).update({'password': newPassword});
  }

  // Cache user's name
  String _cachedUserName = 'Unknown User';

  Future<void> cacheCurrentUserName(String email) async {
    final doc = await _users.doc(email).get();
    if (doc.exists) {
      _cachedUserName = doc.data()?['fullName'] ?? 'Unknown User';
    }
  }

  String get senderName => _cachedUserName;
}
