import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/book_model.dart';

class EditBookPage extends StatefulWidget {
  final BookModel book;

  const EditBookPage({required this.book, super.key});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController isbnController;
  late TextEditingController genreController;
  late TextEditingController publicationDateController;
  late TextEditingController descriptionController;
  bool isLoading = false;

  // 💜 Purple Brand Color
  final Color brandColor = const Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.book.title);
    authorController = TextEditingController(text: widget.book.author);
    isbnController = TextEditingController(text: widget.book.isbn ?? '');
    genreController = TextEditingController(text: widget.book.genre ?? '');
    publicationDateController = TextEditingController(text: widget.book.publicationDate ?? '');
    descriptionController = TextEditingController(text: widget.book.description ?? '');
  }

  Future<void> editBook() async {
    if (titleController.text.trim().isEmpty || authorController.text.trim().isEmpty) {
      showMessage("Please fill in title and author");
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.book.id)
          .update({
        'title': titleController.text.trim(),
        'author': authorController.text.trim(),
        'isbn': isbnController.text.trim().isEmpty ? null : isbnController.text.trim(),
        'genre': genreController.text.trim().isEmpty ? null : genreController.text.trim(),
        'publicationDate': publicationDateController.text.trim().isEmpty ? null : publicationDateController.text.trim(),
        'description': descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
      });

      if (mounted) {
        showMessage("Book Updated Successfully!");
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

  Future<void> deleteBook() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Book?"),
        content: const Text("Are you sure you want to remove this book from your library?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      setState(() => isLoading = true);
      try {
        await FirebaseFirestore.instance.collection('books').doc(widget.book.id).delete();
        if (mounted) {
          showMessage("Book Deleted Successfully!");
          Navigator.pop(context);
        }
      } catch (e) {
        showMessage("Error: $e");
        if (mounted) setState(() => isLoading = false);
      }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: isLoading ? null : deleteBook,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Header Icon
              Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: brandColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.edit_note_rounded, size: 40, color: brandColor),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Edit Book Details",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                  ),
                  const Text(
                    "Keep your library information up to date",
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
                    _buildTextField(titleController, "Book title", Icons.book),

                    const SizedBox(height: 20),

                    _buildLabel("AUTHOR *"),
                    _buildTextField(authorController, "Author name", Icons.person),

                    const SizedBox(height: 20),

                    _buildLabel("ISBN"),
                    _buildTextField(isbnController, "ISBN number", Icons.qr_code),

                    const SizedBox(height: 20),

                    _buildLabel("GENRE"),
                    _buildTextField(genreController, "e.g. History, Tech", Icons.category),

                    const SizedBox(height: 20),

                    _buildLabel("PUBLICATION DATE"),
                    _buildTextField(publicationDateController, "YYYY-MM-DD", Icons.calendar_today),

                    const SizedBox(height: 20),

                    _buildLabel("DESCRIPTION"),
                    _buildTextAreaField(descriptionController, "Book summary..."),

                    const SizedBox(height: 30),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : editBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Update Details",
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
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      enabled: !isLoading,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: brandColor, size: 20),
        filled: true,
        fillColor: const Color(0xFFEDE9FE), // 💜 Light purple fields
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildTextAreaField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      enabled: !isLoading,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFEDE9FE),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}