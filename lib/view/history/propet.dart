import 'dart:io'; // ใช้สำหรับการจัดการไฟล์
import 'package:flutter/material.dart'; // ใช้สำหรับสร้าง UI
import 'package:firebase_auth/firebase_auth.dart'; // ใช้สำหรับการตรวจสอบผู้ใช้ Firebase
import 'package:cloud_firestore/cloud_firestore.dart'; // ใช้สำหรับการจัดการข้อมูล Firestore
import 'package:firebase_storage/firebase_storage.dart'; // ใช้สำหรับการจัดการการเก็บไฟล์ใน Firebase Storage
import 'package:image_picker/image_picker.dart'; // ใช้สำหรับการเลือกภาพจาก Gallery หรือ Camera
import 'package:quickalert/quickalert.dart'; // ใช้สำหรับแสดง alert messages

// คลาสหลักสำหรับหน้าโปรไฟล์สัตว์เลี้ยง
class Propet extends StatefulWidget {
  final String petId; // ID ของสัตว์เลี้ยง
  final String name; // ชื่อของสัตว์เลี้ยง
  final String history; // ประวัติโรคประจำตัวของสัตว์เลี้ยง
  final String address; // ที่อยู่
  final String? imageUrl; // URL ของรูปภาพ (อาจเป็น null)

  const Propet({
    Key? key,
    required this.petId,
    required this.name,
    required this.history,
    required this.address,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<Propet> createState() => _PropetState();
}

class _PropetState extends State<Propet> {
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

  late TextEditingController
      _nameController; // คอนโทรลเลอร์สำหรับการป้อนชื่อสัตว์เลี้ยง
  late TextEditingController
      _historyController; // คอนโทรลเลอร์สำหรับการป้อนประวัติโรคประจำตัวสัตว์เลี้ยง
  late TextEditingController
      _addressController; // คอนโทรลเลอร์สำหรับการป้อนที่อยู่

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!; // ดึงข้อมูลผู้ใช้ปัจจุบัน
    // กำหนดค่าเริ่มต้นให้กับคอนโทรลเลอร์ตามค่าที่ได้รับจาก widget
    _nameController = TextEditingController(text: widget.name);
    _historyController = TextEditingController(text: widget.history);
    _addressController = TextEditingController(text: widget.address);
  }

  @override
  void dispose() {
    // ทำความสะอาดคอนโทรลเลอร์เมื่อไม่ใช้แล้ว
    _nameController.dispose();
    _historyController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับอัปเดตข้อมูลสัตว์เลี้ยง
  Future<void> _updateUserData() async {
    String? imageUrl = widget.imageUrl; // ใช้ URL ของรูปภาพที่มีอยู่แล้ว

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

    // อัปเดตข้อมูลใน Firestore ด้วยข้อมูลใหม่
    await _firestore.collection('history').doc(widget.petId).update({
      'name': _nameController.text, // ชื่อสัตว์เลี้ยง
      'history': _historyController.text, // ประวัติโรคประจำตัว
      'address': _addressController.text, // ที่อยู่
      'imageUrl': imageUrl, // URL ของรูปภาพ
    });

    // แสดง alert ว่าการบันทึกสำเร็จ
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'แก้ไขสำเร็จ!',
    );
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
        title: const Text('โปรไฟล์สัตว์เลี้ยง'), // ชื่อของ AppBar
        backgroundColor: const Color(0xffFC6011), // สีพื้นหลังของ AppBar
        actions: [
          IconButton(
            onPressed: () async {
              await _auth.signOut(); // ออกจากระบบ
              // นำทางไปยังหน้าจอล็อกอินหรือหน้าจออื่น
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
              onPressed: _pickImage, // เรียกฟังก์ชันเพื่อเลือกภาพ
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
              )
            else if (widget.imageUrl != null)
              SizedBox(
                height: 200, // ความสูงของภาพ
                child: Image.network(
                  widget.imageUrl!, // แสดงภาพจาก URL
                  fit: BoxFit.cover, // การปรับขนาดของภาพ
                  width: double.infinity, // ความกว้างเต็มที่
                ),
              ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nameController, // เชื่อมโยงกับคอนโทรลเลอร์
              decoration: const InputDecoration(
                  labelText: 'ชื่อสัตว์เลี้ยง'), // ข้อความป้าย
            ),
            TextField(
              controller: _historyController, // เชื่อมโยงกับคอนโทรลเลอร์
              decoration: const InputDecoration(
                labelText: 'ประวัติโรคประจำตัวสัตว์เลี้ยง', // ข้อความป้าย
              ),
            ),
            TextField(
              controller: _addressController, // เชื่อมโยงกับคอนโทรลเลอร์
              decoration:
                  const InputDecoration(labelText: 'ที่อยู่'), // ข้อความป้าย
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateUserData, // เรียกฟังก์ชันเพื่ออัปเดตข้อมูล
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
