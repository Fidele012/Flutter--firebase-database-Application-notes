import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NotesRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'notes';

  NotesRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Fetch all notes for a user
  Future<List<Note>> fetchNotes(String userId) async {
    try {
      if (userId.isEmpty) throw Exception('User ID cannot be empty');

      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Additional security check (though Firebase rules will handle this)
        if (data['userId'] != userId) {
          throw Exception('Permission denied: Note does not belong to user');
        }
        return Note.fromMap(data, doc.id);
      }).toList();
    } on FirebaseException catch (e) {
      // Handle specific Firebase errors
      if (e.code == 'permission-denied') {
        throw Exception(
          'Permission denied: Please check your authentication and try again',
        );
      }
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  // Add a new note and return its ID
  Future<String> addNote(String text, String userId) async {
    try {
      if (userId.isEmpty) throw Exception('User ID cannot be empty');
      if (text.trim().isEmpty) throw Exception('Note text cannot be empty');

      final docRef = await _firestore.collection(_collection).add({
        'text': text.trim(),
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception(
          'Permission denied: Unable to create note. Please check your authentication.',
        );
      }
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add note: $e');
    }
  }

  // Update an existing note
  Future<void> updateNote(String noteId, String text, String userId) async {
    try {
      if (userId.isEmpty) throw Exception('User ID cannot be empty');
      if (text.trim().isEmpty) throw Exception('Note text cannot be empty');
      if (noteId.isEmpty) throw Exception('Note ID cannot be empty');

      // First, verify the note exists and belongs to the user
      final doc = await _firestore.collection(_collection).doc(noteId).get();
      if (!doc.exists) {
        throw Exception('Note not found');
      }
      if (doc.data()?['userId'] != userId) {
        throw Exception('Permission denied: Note does not belong to user');
      }

      await _firestore.collection(_collection).doc(noteId).update({
        'text': text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
        // Don't update userId - it should remain the same
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception(
          'Permission denied: Unable to update note. You can only update your own notes.',
        );
      }
      if (e.code == 'not-found') {
        throw Exception('Note not found or has been deleted');
      }
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  // Delete a note
  Future<void> deleteNote(String noteId, String userId) async {
    try {
      if (userId.isEmpty) throw Exception('User ID cannot be empty');
      if (noteId.isEmpty) throw Exception('Note ID cannot be empty');

      // Verify note belongs to user before deletion
      final doc = await _firestore.collection(_collection).doc(noteId).get();
      if (!doc.exists) {
        throw Exception('Note not found');
      }
      if (doc.data()?['userId'] != userId) {
        throw Exception('Permission denied: Note does not belong to user');
      }

      await _firestore.collection(_collection).doc(noteId).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception(
          'Permission denied: Unable to delete note. You can only delete your own notes.',
        );
      }
      if (e.code == 'not-found') {
        throw Exception('Note not found or has been deleted');
      }
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  // Get real-time notes stream with ownership verification
  Stream<List<Note>> getNotesStream(String userId) {
    if (userId.isEmpty) {
      return Stream.error(Exception('User ID cannot be empty'));
    }

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Note.fromMap(doc.data(), doc.id))
              .toList(),
        )
        .handleError((error) {
          if (error is FirebaseException) {
            if (error.code == 'permission-denied') {
              throw Exception(
                'Permission denied: Unable to access notes. Please check your authentication.',
              );
            }
            throw Exception('Firestore stream error: ${error.message}');
          }
          throw Exception('Stream error: $error');
        });
  }

  // Helper method to check if a note belongs to a user
  Future<bool> noteExists(String noteId, String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(noteId).get();
      return doc.exists && doc.data()?['userId'] == userId;
    } catch (e) {
      return false;
    }
  }
}
