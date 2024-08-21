import 'dart:io'; // ใช้สำหรับการจัดการไฟล์
import 'package:flutter/material.dart'; // ใช้สำหรับสร้าง UI
import 'package:firebase_auth/firebase_auth.dart'; // ใช้สำหรับการตรวจสอบผู้ใช้ Firebase
import 'package:cloud_firestore/cloud_firestore.dart'; // ใช้สำหรับการจัดการข้อมูล Firestore
import 'package:firebase_storage/firebase_storage.dart'; // ใช้สำหรับการจัดการการเก็บไฟล์ใน Firebase Storage
import 'package:image_picker/image_picker.dart'; // ใช้สำหรับการเลือกภาพจาก Gallery หรือ Camera
import 'package:quickalert/quickalert.dart'; // ใช้สำหรับแสดง alert messages

// คลาสหลักสำหรับโปรไฟล์หน้า
class Propage extends StatefulWidget {
  const Propage({Key? key}) : super(key: key);

  @override
  State<Propage> createState() => _PropageState();
}

class _PropageState extends State<Propage> {
  final FirebaseAuth _auth = FirebaseAuth
      .instance; // อินสแตนซ์ของ FirebaseAuth ใช้สำหรับการจัดการการเข้าสู่ระบบ
  final FirebaseFirestore _firestore = FirebaseFirestore
      .instance; // อินสแตนซ์ของ Firestore ใช้สำหรับการจัดการข้อมูล
  final FirebaseStorage _storage = FirebaseStorage
      .instance; // อินสแตนซ์ของ FirebaseStorage ใช้สำหรับการจัดการการเก็บไฟล์
  final ImagePicker _picker =
      ImagePicker(); // อินสแตนซ์ของ ImagePicker ใช้สำหรับการเลือกภาพ

  late User _user; // ตัวแปรเก็บข้อมูลของผู้ใช้ปัจจุบัน

  XFile? _image; // ตัวแปรเก็บข้อมูลภาพที่เลือก
  final TextEditingController _nameController =
      TextEditingController(); // คอนโทรลเลอร์สำหรับการป้อนชื่อสัตว์เลี้ยง
  final TextEditingController _historyController =
      TextEditingController(); // คอนโทรลเลอร์สำหรับการป้อนประวัติโรคประจำตัวสัตว์เลี้ยง
  final TextEditingController _addressController =
      TextEditingController(); // คอนโทรลเลอร์สำหรับการป้อนที่อยู่

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!; // ดึงข้อมูลผู้ใช้ปัจจุบัน
  }

  // ฟังก์ชันสำหรับอัปเดตข้อมูลผู้ใช้
  Future<void> _updateUserData() async {
    String? imageUrl;

    // เช็คว่ามีการเลือกรูปภาพหรือไม่
    if (_image != null) {
      try {
        // สร้าง reference สำหรับการเก็บไฟล์ใน Firebase Storage
        final storageRef = _storage.ref().child('images/${_image!.name}');
        // อัปโหลดไฟล์ไปยัง Firebase Storage
        await storageRef.putFile(File(_image!.path));
        // รับ URL ของไฟล์ที่อัปโหลด
        imageUrl = await storageRef.getDownloadURL();
      } catch (e) {
        print('Error uploading image: $e'); // แสดงข้อผิดพลาดหากเกิดขึ้น
      }
    }

    // เพิ่มข้อมูลลงใน Firestore
    await _firestore.collection('history').add({
      'userId': _user.uid,
      'name': _nameController.text, // ข้อมูลชื่อสัตว์เลี้ยง
      'history': _historyController.text, // ข้อมูลประวัติโรคประจำตัว
      'address': _addressController.text, // ข้อมูลที่อยู่
      'imageUrl': imageUrl, // URL ของรูปภาพ
    });
  }

  // ฟังก์ชันสำหรับเลือกภาพจาก Gallery
  Future<void> _pickImage() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image; // อัปเดตสถานะของภาพที่เลือก
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์สัตว์เลี้ยง'),
        backgroundColor: const Color(0xffFC6011), // สีพื้นหลังของ AppBar
        actions: [
          IconButton(
            onPressed: () async {
              await _auth.signOut(); // ออกจากระบบ
              // นำทางไปยังหน้าจอเข้าสู่ระบบหรือหน้าจออื่น ๆ
            },
            icon: const Icon(Icons.logout), // ไอคอนสำหรับออกจากระบบ
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // การเว้นระยะรอบของเนื้อหา
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: Text(_image == null ? 'อัปโหลดรูปภาพ' : 'เปลี่ยนรูปภาพ'),
            ),
            if (_image != null)
              SizedBox(
                height: 200, // ความสูงของภาพ
                child: Image.file(
                  File(_image!.path), // แสดงภาพที่เลือก
                  fit: BoxFit.cover, // การปรับขนาดของภาพ
                  width: double.infinity, // ความกว้างเต็มที่
                ),
              ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'ชื่อสัตว์เลี้ยง'),
            ),
            TextField(
              controller: _historyController,
              decoration: const InputDecoration(
                  labelText: 'ประวัติโรคประจำตัวสัตว์เลี้ยง'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'ที่อยู่'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await _updateUserData(); // เรียกฟังก์ชันเพื่ออัปเดตข้อมูล

                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.success, // แสดง alert ว่าการบันทึกสำเร็จ
                  text: 'สำเร็จ!',
                );
              },
              child: const Text('บันทึก'),
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xffFC6011), // สีของข้อความในปุ่ม
              ),
            ),
          ],
        ),
      ),
    );
  }
}
