import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Ensure these paths match your exact project structure
import '../../model/book_model.dart';
import '../book/add_book.dart';
import '../book/edit_book.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String searchQuery = '';
  String filterStatus = 'all';

  // 💜 Purple Brand Palette
  final Color brandColor = const Color(0xFF7C3AED);
  final Color bgColor = const Color(0xFFF3E8FF);
  final Color cardColor = const Color(0xFFFAF5FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: user == null
          ? const Center(child: Text("User not logged in"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('books')
                  .where('userId', isEqualTo: user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final books = snapshot.data?.docs.map((doc) {
                  return BookModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
                }).toList() ?? [];

                final filteredBooks = books.where((book) {
                  final matchesSearch = book.title.toLowerCase().contains(searchQuery) ||
                      book.author.toLowerCase().contains(searchQuery);
                  return matchesSearch;
                }).toList();

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildHeader(books.length),
                    _buildSearchBox(),
                    if (filteredBooks.isEmpty)
                      const SliverFillRemaining(
                        child: Center(child: Text("No books found", style: TextStyle(color: Colors.grey))),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildBookCard(filteredBooks[index]),
                            childCount: filteredBooks.length,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBookPage())),
        backgroundColor: brandColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Book", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: bgColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          "My Library ($count)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: brandColor),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => FirebaseAuth.instance.signOut(),
          icon: Icon(Icons.logout_rounded, color: brandColor),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBox() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextField(
          onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
          decoration: InputDecoration(
            hintText: "Search books...",
            prefixIcon: Icon(Icons.search, color: brandColor),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildBookCard(BookModel book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: brandColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.menu_book_rounded, color: brandColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  book.author,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note, color: Colors.grey),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => EditBookPage(book: book)));
            },
          ),
        ],
      ),
    );
  }
}


