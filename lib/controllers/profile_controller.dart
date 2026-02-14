import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skywise/services/cloudinary_service.dart';

class ProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();

  Future<Map<String, dynamic>?> fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data();
      }
    }
    return null;
  }

  Future<String?> pickAndUploadImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final url = await _cloudinaryService.uploadImage(image.path);
      if (url != null) {
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'PROFILE_IMAGE': url,
          });
          return url;
        }
      }
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<List<Map<String, dynamic>>> fetchSearchHistory() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    }
    return [];
  }

  User? get currentUser => _auth.currentUser;
}
