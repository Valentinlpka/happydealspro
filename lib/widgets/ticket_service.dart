import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/foundation.dart';
import 'package:happy_deals_pro/classes/ticket.dart';
import 'package:happy_deals_pro/classes/user.dart';

class TicketService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth.FirebaseAuth _auth = FirebaseAuth.FirebaseAuth.instance;

  Users? _currentUser;
  List<Ticket> _tickets = [];

  Users? get currentUser => _currentUser;
  List<Ticket> get tickets => _tickets;

  TicketService() {
    _initializeUser();
    _listenToTickets();
  }

  Future<void> _initializeUser() async {
    _currentUser = await getCurrentUser();
    notifyListeners();
  }

  void _listenToTickets() {
    getUserTickets().listen((updatedTickets) {
      _tickets = updatedTickets;
      notifyListeners();
    });
  }

  Future<Users?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      return Users.fromFirestore(doc);
    }
    return null;
  }

  Future<void> createTicket(String title, String description) async {
    if (_currentUser != null) {
      await _firestore.collection('tickets').add(
            Ticket(
              id: '',
              title: title,
              description: description,
              createdAt: DateTime.now(),
              userId: _currentUser!.id,
            ).toFirestore(),
          );
      notifyListeners();
    }
  }

  Stream<List<Ticket>> getTickets() {
    return _firestore
        .collection('tickets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Ticket.fromFirestore(doc)).toList());
  }

  Stream<List<Ticket>> getUserTickets() async* {
    final user = await getCurrentUser();
    if (user != null) {
      if (user.type == UserType.admin) {
        yield* getTickets();
      } else {
        yield* _firestore
            .collection('tickets')
            .where('userId', isEqualTo: user.id)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snapshot) =>
                snapshot.docs.map((doc) => Ticket.fromFirestore(doc)).toList());
      }
    } else {
      yield [];
    }
  }

  Future<void> updateTicketStatus(
      String ticketId, TicketStatus newStatus) async {
    if (_currentUser != null && _currentUser!.type == UserType.admin) {
      await _firestore.collection('tickets').doc(ticketId).update({
        'status': newStatus.toString().split('.').last,
      });
      notifyListeners();
    }
  }

  Future<void> addMessageToTicket(String ticketId, String content) async {
    if (_currentUser != null) {
      await _firestore
          .collection('tickets')
          .doc(ticketId)
          .collection('messages')
          .add(
            TicketMessage(
              id: '',
              content: content,
              senderId: _currentUser!.id,
              createdAt: DateTime.now(),
            ).toFirestore(),
          );
      notifyListeners();
    }
  }

  Stream<List<TicketMessage>> getTicketMessages(String ticketId) {
    return _firestore
        .collection('tickets')
        .doc(ticketId)
        .collection('messages')
        .orderBy(
          'createdAt',
        )
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TicketMessage.fromFirestore(doc))
            .toList());
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    _tickets = [];
    notifyListeners();
  }
}
