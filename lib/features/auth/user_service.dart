import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> checkAndCreateUser(User user) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      await userDocRef.set({
        'uid': user.uid,
        'email': user.email,
        'credits': 5,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<int> getUserCredits(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return doc.data()!['credits'] as int? ?? 0;
      }
      return 0;
    });
  }

  Future<bool> deductCredit(String uid, [int amount = 1]) async {
    final userDocRef = _firestore.collection('users').doc(uid);
    return _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(userDocRef);
      if (!doc.exists) return false;

      final currentCredits = doc.data()?['credits'] as int? ?? 0;
      if (currentCredits < amount) return false;

      transaction.update(userDocRef, {'credits': currentCredits - amount});
      return true;
    });
  }
}
