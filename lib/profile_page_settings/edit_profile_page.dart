import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _currentEmailController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ... KEEP YOUR _loadUserData and _saveProfile LOGIC EXACTLY THE SAME ...
  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!mounted) return;
      Map<String, dynamic>? userData = doc.data() as Map<String, dynamic>?;
      if (userData != null) {
        setState(() {
          _firstNameController.text = userData['firstName'] ?? '';
          _lastNameController.text = userData['lastName'] ?? '';
          _currentEmailController.text = user.email ?? '';
          _phoneController.text = userData['phone'] ?? '';
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      User? user = _auth.currentUser;
      if (user != null) {
        final String currentEmail = _currentEmailController.text.trim();
        final String newEmail = _newEmailController.text.trim();

        if (currentEmail == user.email) {
          try {
            setState(() => _isVerifying = true);
            await user.verifyBeforeUpdateEmail(newEmail);
            if (!mounted) return;
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({
              'firstName': _firstNameController.text.trim(),
              'lastName': _lastNameController.text.trim(),
              'phone': _phoneController.text.trim(),
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Verification email sent to the new address.'),
                  backgroundColor: Colors.green));
            }
          } catch (error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Error: $error'), backgroundColor: Colors.red));
            }
          } finally {
            if (mounted) setState(() => _isVerifying = false);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Current email is incorrect'),
                backgroundColor: Colors.red));
          }
        }
      }
    }
  }

  // Modern Input Builder
  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      bool readOnly = false,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        style: TextStyle(color: readOnly ? Colors.grey : Colors.black),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Edit Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              _buildTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              _buildTextField(
                  controller: _currentEmailController,
                  label: 'Current Email',
                  readOnly: true),
              _buildTextField(
                  controller: _newEmailController,
                  label: 'New Email (Optional)',
                  validator: (v) => (v!.isNotEmpty && !v.contains('@'))
                      ? 'Invalid email'
                      : null),
              _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000033),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _isVerifying ? null : _saveProfile,
                  child: _isVerifying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('SAVE CHANGES',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
