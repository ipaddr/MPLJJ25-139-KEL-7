import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Jika Anda ingin mengunggah gambar berita, Anda akan memerlukan paket seperti image_picker dan firebase_storage.
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'dart:io'; // Untuk File

class AddNewsScreen extends StatefulWidget {
  const AddNewsScreen({super.key});

  @override
  State<AddNewsScreen> createState() => _AddNewsScreenState();
}

class _AddNewsScreenState extends State<AddNewsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // File? _imageFile; // Untuk gambar berita (jika diimplementasikan)
  // final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   setState(() {
  //     if (pickedFile != null) {
  //       _imageFile = File(pickedFile.path);
  //     } else {
  //       print('Tidak ada gambar yang dipilih.');
  //     }
  //   });
  // }

  Future<void> _uploadNews() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua bidang Judul dan Konten.')),
      );
      return;
    }

    // String? imageUrl;
    // if (_imageFile != null) {
    //   try {
    //     // Mengunggah gambar ke Firebase Storage
    //     String fileName = '${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.path.split('/').last}';
    //     Reference storageRef = FirebaseStorage.instance.ref().child('news_images/$fileName');
    //     UploadTask uploadTask = storageRef.putFile(_imageFile!);
    //     await uploadTask.whenComplete(() => null);
    //     imageUrl = await storageRef.getDownloadURL();
    //   } catch (e) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Gagal mengunggah gambar: $e')),
    //     );
    //     return; // Berhenti jika gagal mengunggah gambar
    //   }
    // }

    try {
      await _firestore.collection('berita').add({
        'judul': _titleController.text.trim(),
        'konten': _contentController.text.trim(),
        'tanggal': FieldValue.serverTimestamp(), // Timestamp saat berita ditambahkan
        // 'imageUrl': imageUrl, // Tambahkan URL gambar jika ada
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berita berhasil ditambahkan!')),
      );
      // Bersihkan form setelah berhasil
      _titleController.clear();
      _contentController.clear();
      // setState(() { _imageFile = null; });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan berita: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tambah Berita Baru',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Judul Berita :',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 10),
            _buildInputField(_titleController, hintText: 'Masukkan judul berita'),
            const SizedBox(height: 20),

            const Text(
              'Konten Berita :',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 10),
            _buildMultiLineInputField(_contentController, hintText: 'Tulis konten berita di sini'),
            const SizedBox(height: 20),

            // Bagian untuk memilih gambar (opsional, uncomment jika ingin implementasi)
            // if (_imageFile != null)
            //   Image.file(
            //     _imageFile!,
            //     height: 150,
            //     fit: BoxFit.cover,
            //   ),
            // const SizedBox(height: 10),
            // ElevatedButton.icon(
            //   onPressed: _pickImage,
            //   icon: const Icon(Icons.image),
            //   label: const Text('Pilih Gambar Berita'),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.grey[300],
            //     foregroundColor: Colors.black,
            //   ),
            // ),
            // const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _uploadNews,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange, // Warna sesuai tema admin
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'PUBLIKASIKAN BERITA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk input field standar
  Widget _buildInputField(TextEditingController controller, {String? hintText}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  // Widget pembantu untuk input field multi-baris
  Widget _buildMultiLineInputField(TextEditingController controller, {String? hintText}) {
    return Container(
      height: 200, // Tinggi lebih besar untuk konten
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        maxLines: null, // Memungkinkan banyak baris
        keyboardType: TextInputType.multiline,
        expands: true, // Memungkinkan TextField mengembang
        textAlignVertical: TextAlignVertical.top, // Mulai teks dari atas
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
