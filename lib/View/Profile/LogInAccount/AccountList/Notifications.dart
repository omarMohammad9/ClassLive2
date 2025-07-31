import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

const Color primary = Color(0xFF1A4C9C);

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final Set<String> _selectedNotifications = {};
  bool _selectionMode = false;

  Stream<QuerySnapshot<Map<String, dynamic>>> get _notificationStream {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _clearAllNotifications() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .collection('notifications')
        .get();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    setState(() {
      _selectedNotifications.clear();
      _selectionMode = false;
    });
  }

  Future<void> _deleteSelectedNotifications() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final batch = FirebaseFirestore.instance.batch();
    for (var docId in _selectedNotifications) {
      final ref = FirebaseFirestore.instance
          .collection('User')
          .doc(uid)
          .collection('notifications')
          .doc(docId);
      batch.delete(ref);
    }
    await batch.commit();
    setState(() {
      _selectedNotifications.clear();
      _selectionMode = false;
    });
  }
  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {


    // يوجد إشعارات - عرض تأكيد الحذف
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Confirmation'.tr),
          content: Text('Do you want to delete all notifications?'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'.tr),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete All'.tr),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _clearAllNotifications();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: primary),
        title: Text(
          _selectionMode ? 'Select Notifications'.tr : 'Notifications'.tr,
          style: const TextStyle(
            color: primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Delete Selected',
              onPressed: _selectedNotifications.isNotEmpty
                  ? _deleteSelectedNotifications
                  : null,
            ),
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancel',
              onPressed: () {
                setState(() {
                  _selectionMode = false;
                  _selectedNotifications.clear();
                });
              },
            ),
          if (!_selectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Select to Delete',
              onPressed: () {
                setState(() {
                  _selectionMode = true;
                });
              },
            ),
          if (!_selectionMode)

            IconButton(
              icon: const Icon(Icons.delete_forever_outlined),
              tooltip: 'Clear All',
              onPressed: () => _showDeleteConfirmationDialog(context),
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _notificationStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error loading notifications'.tr));
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text('No notifications'.tr));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final docId = doc.id;
              final docRef = doc.reference;
              final data = doc.data();
              final title = data['title'] as String? ?? '';
              final body = data['body'] as String? ?? '';
              final ts = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
              final time = DateFormat('hh:mm a').format(ts);
              final read = data['read'] as bool? ?? false;
              final isSelected = _selectedNotifications.contains(docId);

              return Card(
                color: read ? Colors.white : const Color(0xFFE8F0FC),
                elevation: read ? 1 : 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    if (!_selectionMode && !read) {
                      docRef.update({'read': true});
                    } else if (_selectionMode) {
                      setState(() {
                        isSelected
                            ? _selectedNotifications.remove(docId)
                            : _selectedNotifications.add(docId);
                      });
                    }
                  },
                  onLongPress: () {
                    if (!_selectionMode) {
                      setState(() {
                        _selectionMode = true;
                        _selectedNotifications.add(docId);
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectionMode)
                          Checkbox(
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                val == true
                                    ? _selectedNotifications.add(docId)
                                    : _selectedNotifications.remove(docId);
                              });
                            },
                          ),
                        if (_selectionMode) const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 22,
                          backgroundImage: const AssetImage("images/LogoApp.png"),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: read ? FontWeight.normal : FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                body,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: read ? Colors.black45 : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  time,
                                  style: TextStyle(
                                    color: read ? Colors.grey.shade400 : Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
