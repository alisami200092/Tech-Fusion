import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Modern Input Decoration Helper
  InputDecoration _customInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  // Show a dialog to add a new user.
  Future<void> _showAddUserDialog() async {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    String selectedRole = 'User';

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Add New User",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF000033))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: firstNameController,
                    decoration: _customInputDecoration("First Name")),
                const SizedBox(height: 12),
                TextField(
                    controller: lastNameController,
                    decoration: _customInputDecoration("Last Name")),
                const SizedBox(height: 12),
                TextField(
                    controller: emailController,
                    decoration: _customInputDecoration("Email Address")),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (context, setState) {
                    return DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: _customInputDecoration("Role"),
                      dropdownColor: Colors.white,
                      items: ['Admin', 'User']
                          .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500))))
                          .toList(),
                      onChanged: (newValue) =>
                          setState(() => selectedRole = newValue!),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000033),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0),
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                await _firestore.collection('users').add({
                  'firstName': firstNameController.text.trim(),
                  'lastName': lastNameController.text.trim(),
                  'email': emailController.text.trim(),
                  'role': selectedRole,
                });
                if (!mounted) return;
                navigator.pop();
              },
              child:
                  const Text("Add User", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Show a dialog to edit user data.
  Future<void> _showEditDialog(DocumentSnapshot userDoc) async {
    final Map<String, dynamic> userData =
        userDoc.data() as Map<String, dynamic>;
    final TextEditingController firstNameController =
        TextEditingController(text: userData['firstName'] ?? "");
    final TextEditingController lastNameController =
        TextEditingController(text: userData['lastName'] ?? "");
    final TextEditingController emailController =
        TextEditingController(text: userData['email'] ?? "");

    String selectedRole = (userData['role'] ?? 'User').toString();
    selectedRole = selectedRole.toLowerCase() == 'admin' ? 'Admin' : 'User';

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit User',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF000033))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: firstNameController,
                    decoration: _customInputDecoration('First Name')),
                const SizedBox(height: 12),
                TextField(
                    controller: lastNameController,
                    decoration: _customInputDecoration('Last Name')),
                const SizedBox(height: 12),
                TextField(
                    controller: emailController,
                    decoration: _customInputDecoration('Email Address')),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (context, setState) {
                    return DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: _customInputDecoration('Role'),
                      dropdownColor: Colors.white,
                      items: ['Admin', 'User']
                          .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500))))
                          .toList(),
                      onChanged: (newValue) =>
                          setState(() => selectedRole = newValue!),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000033),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0),
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                await _firestore.collection('users').doc(userDoc.id).update({
                  'firstName': firstNameController.text.trim(),
                  'lastName': lastNameController.text.trim(),
                  'email': emailController.text.trim(),
                  'role': selectedRole,
                });
                if (!mounted) return;
                navigator.pop();
              },
              child: const Text('Save Changes',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Show a confirmation dialog for deletion.
  Future<void> _showDeleteDialog(DocumentSnapshot userDoc) async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete User',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          content: const Text(
              'Are you sure you want to permanently delete this user? This action cannot be undone.',
              style: TextStyle(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0),
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                await _firestore.collection('users').doc(userDoc.id).delete();
                if (!mounted) return;
                navigator.pop();
              },
              child: const Text('Yes, Delete',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('User Management',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900), // Web constraint
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Registered Users',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000033))),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF000033),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      icon:
                          const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text('Add User',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      onPressed: _showAddUserDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Something went wrong!'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF000033)));
                      }

                      if (snapshot.hasData) {
                        final List<DocumentSnapshot> documents =
                            snapshot.data!.docs;
                        if (documents.isEmpty) {
                          return const Center(
                              child: Text('No users found.',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16)));
                        }

                        return ListView.builder(
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot user = documents[index];
                            final Map<String, dynamic> userData =
                                user.data() as Map<String, dynamic>;

                            String fName = userData['firstName'] ?? "";
                            String lName = userData['lastName'] ?? "";
                            String initials =
                                '${fName.isNotEmpty ? fName[0].toUpperCase() : ''}${lName.isNotEmpty ? lName[0].toUpperCase() : ''}';
                            if (initials.isEmpty) initials = '?';

                            bool isSuperAdmin =
                                (userData['role']?.toString().toLowerCase() ==
                                    'admin');

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4))
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: isSuperAdmin
                                      ? Colors.red.shade50
                                      : Colors.blue.shade50,
                                  child: Text(
                                    initials,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSuperAdmin
                                            ? Colors.red
                                            : Colors.blue),
                                  ),
                                ),
                                title: Text(
                                  '$fName $lName'.trim(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF000033)),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                      userData['email'] ?? "No Email Provided",
                                      style: TextStyle(
                                          color: Colors.grey.shade600)),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isSuperAdmin
                                            ? Colors.red.withValues(alpha: 0.1)
                                            : Colors.blue
                                                .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isSuperAdmin ? 'Admin' : 'User',
                                        style: TextStyle(
                                            color: isSuperAdmin
                                                ? Colors.red
                                                : Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          color: Color(0xFF000033)),
                                      tooltip: 'Edit User',
                                      onPressed: () => _showEditDialog(user),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      tooltip: 'Delete User',
                                      onPressed: () => _showDeleteDialog(user),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: Text('No users found.'));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
