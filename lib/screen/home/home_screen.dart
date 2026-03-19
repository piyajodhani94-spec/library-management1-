import 'package:flutter/material.dart';
import 'dart:ui';
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

  // --- Design Constants ---
  final Color kPrimary = const Color(0xFF6366F1); 
  final Color kBackground = const Color(0xFF090B0D); 
  final Color kCardSurface = const Color(0xFF161A1F); 
  final Color kSuccess = const Color(0xFF10B981);
  final Color kWarning = const Color(0xFFF59E0B);

  // --- Logic Functions ---
  void showDeleteDialog(BuildContext context, BookModel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardSurface,
        title: const Text("Delete Book?", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to delete this book?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('books').doc(book.id!).delete();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Book deleted successfully!")),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Delete error: $e")),
                  );
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> togglePublish(BookModel book) async {
    try {
      await FirebaseFirestore.instance
          .collection('books')
          .doc(book.id!)
          .update({'isPublished': !book.isPublished});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(book.isPublished ? "Unpublished!" : "Published!"),
            backgroundColor: kPrimary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimary.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          user == null
              ? const Center(child: Text("User not logged in", style: TextStyle(color: Colors.white)))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('books')
                      .where('userId', isEqualTo: user!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                    }

                    final books = snapshot.data?.docs.map((doc) {
                      return BookModel.fromJson(doc.id, doc.data() as Map<String, dynamic>); 
                    }).toList() ?? [];

                    final filteredBooks = books.where((book) {
                      final matchesSearch = book.title.toLowerCase().contains(searchQuery) ||
                          book.author.toLowerCase().contains(searchQuery);
                      
                      final isPub = book.isPublished;
                      final matchesFilter = filterStatus == 'all' ||
                          (filterStatus == 'published' && isPub) ||
                          (filterStatus == 'draft' && !isPub);
                      return matchesSearch && matchesFilter;
                    }).toList();

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        _buildHeader(books.length),
                        _buildSearchAndFilters(books),
                        if (filteredBooks.isEmpty)
                          _buildEmptyState()
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildBookCard(filteredBooks[index]),
                                childCount: filteredBooks.length,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildHeader(int count) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: kBackground.withOpacity(0.8),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          "My Library ($count)", 
          style: const TextStyle(
            fontWeight: FontWeight.w800, 
            fontSize: 20, 
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
          },
          icon: const Icon(Icons.logout_rounded, color: Colors.white70),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchAndFilters(List<BookModel> books) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search title or author...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon: Icon(Icons.search_rounded, color: kPrimary),
                filled: true,
                fillColor: kCardSurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip("All", "all", books.length),
                  const SizedBox(width: 8),
                  _filterChip("Published", "published", books.where((b) => b.isPublished).length),
                  const SizedBox(width: 8),
                  _filterChip("Drafts", "draft", books.where((b) => !b.isPublished).length),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value, int count) {
    bool isSelected = filterStatus == value;
    return GestureDetector(
      onTap: () => setState(() => filterStatus = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : kCardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? kPrimary : Colors.white.withOpacity(0.05)),
        ),
        child: Text("$label ($count)", 
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60, 
            fontSize: 12, 
            fontWeight: FontWeight.bold
          )),
      ),
    );
  }

  Widget _buildBookCard(BookModel book) {
    final bool isPublished = book.isPublished;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 4, height: 45,
            decoration: BoxDecoration(
              color: isPublished ? kSuccess : kWarning,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text(book.author, 
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white30),
            color: kCardSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (val) {
              if (val == 'edit') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => EditBookPage(book: book)));
              } else if (val == 'publish') {
                togglePublish(book);
              } else if (val == 'delete') {
                showDeleteDialog(context, book);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text("Edit", style: TextStyle(color: Colors.white))),
              PopupMenuItem(value: 'publish', child: Text(isPublished ? "Unpublish" : "Publish", style: const TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.redAccent))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBookPage())),
      backgroundColor: kPrimary,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text("Add Book", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildEmptyState() {
    return const SliverFillRemaining(
      child: Center(
        child: Text("No books found matching your criteria.", 
          style: TextStyle(color: Colors.white24, fontSize: 14)),
      ),
    );
  }
}