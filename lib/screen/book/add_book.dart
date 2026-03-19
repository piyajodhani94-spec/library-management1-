import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/book_model.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final isbnController = TextEditingController();
  final genreController = TextEditingController();
  final publicationDateController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isLoading = false;

  // 💜 Purple Brand Color
  final Color brandColor = const Color(0xFF7C3AED);

  Future<void> addBook() async {
    if (titleController.text.trim().isEmpty || authorController.text.trim().isEmpty) {
      showMessage("Please fill in title and author");
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showMessage("User not logged in");
        return;
      }

      final book = BookModel(
        title: titleController.text.trim(),
        author: authorController.text.trim(),
        isbn: isbnController.text.trim().isEmpty ? null : isbnController.text.trim(),
        genre: genreController.text.trim().isEmpty ? null : genreController.text.trim(),
        publicationDate: publicationDateController.text.trim().isEmpty ? null : publicationDateController.text.trim(),
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
        userId: user.uid,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance.collection('books').add(book.toJson());

      if (mounted) {
        showMessage("Book Added Successfully!");
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      showMessage("Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showMessage(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    isbnController.dispose();
    genreController.dispose();
    publicationDateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF), // 💜 Light Purple Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: brandColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Add Book", style: TextStyle(color: brandColor, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Header Section
              Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: brandColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.library_add, size: 40, color: brandColor),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Create New Entry",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                  ),
                  const Text(
                    "Add a new book to your professional library",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Form Card
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF5FF), // 💜 Card color
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("BOOK TITLE *"),
                    _buildTextField(titleController, "Enter book title", Icons.book),

                    const SizedBox(height: 20),

                    _buildLabel("AUTHOR *"),
                    _buildTextField(authorController, "Enter author name", Icons.person),

                    const SizedBox(height: 20),

                    _buildLabel("ISBN"),
                    _buildTextField(isbnController, "Enter ISBN (optional)", Icons.qr_code),

                    const SizedBox(height: 20),

                    _buildLabel("GENRE"),
                    _buildTextField(genreController, "e.g. Fiction, Science", Icons.category),

                    const SizedBox(height: 20),

                    _buildLabel("PUBLICATION DATE"),
                    _buildTextField(publicationDateController, "YYYY-MM-DD", Icons.calendar_today),

                    const SizedBox(height: 20),

                    _buildLabel("DESCRIPTION"),
                    _buildTextAreaField(descriptionController, "Write a short summary..."),

                    const SizedBox(height: 30),

                    // Add Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : addBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Save to Library",
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: brandColor, size: 20),
        filled: true,
        fillColor: const Color(0xFFEDE9FE), // 💜 Light purple input
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildTextAreaField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFEDE9FE), // 💜 Light purple input
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}