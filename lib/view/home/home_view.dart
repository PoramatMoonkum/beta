import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pettakecare/view/history/propage.dart';
import 'package:pettakecare/view/history/propet.dart';
import 'package:pettakecare/common/color_extension.dart';
import 'package:pettakecare/view/menu/PetOwner_view.dart';

// คลาสหลักสำหรับหน้า HomeView
class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirebaseAuth _auth = FirebaseAuth
      .instance; // อินสแตนซ์ของ FirebaseAuth ใช้สำหรับการจัดการการเข้าสู่ระบบ
  final FirebaseFirestore _firestore = FirebaseFirestore
      .instance; // อินสแตนซ์ของ Firestore ใช้สำหรับการจัดการข้อมูล

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser; // ดึงข้อมูลผู้ใช้ปัจจุบัน

    return Scaffold(
      backgroundColor: const Color(0xfffDfDfD), // สีพื้นหลังของ Scaffold
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 46),
              _buildHeader(context), // สร้าง header
              const SizedBox(height: 20),
              _buildSubHeader(), // สร้าง sub-header
              _buildPetList(user), // สร้างรายการสัตว์เลี้ยง
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันสร้าง header ของหน้า
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "โปรไฟล์สัตว์เลี้ยง", // ข้อความที่แสดงใน header
            style: TextStyle(
              color: TColor.primaryText, // สีของข้อความ
              fontSize: 30,
              decoration: TextDecoration.underline, // ขีดเส้นใต้
              fontWeight: FontWeight.w800,
            ),
          ),
          IconButton(
            onPressed: () {
              // นำทางไปยังหน้าจอ Propage เพื่อเพิ่มสัตว์เลี้ยงใหม่
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Propage()),
              );
            },
            icon: Image.asset(
              "assets/img/adds.png", // ไอคอนสำหรับเพิ่มสัตว์เลี้ยง
              width: 35,
              height: 35,
            ),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสร้าง sub-header
  Widget _buildSubHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "รายการสัตว์เลี้ยง", // ข้อความที่แสดงใน sub-header
            style: TextStyle(
              color: TColor.primaryText, // สีของข้อความ
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสร้างรายการสัตว์เลี้ยงจากข้อมูล Firestore
  Widget _buildPetList(User? user) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('history') // ดึงข้อมูลจาก collection 'history'
          .where('userId',
              isEqualTo: user?.uid) // กรองข้อมูลที่ userId ตรงกับ ID ของผู้ใช้
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator()); // แสดง progress indicator ขณะรอข้อมูล
        } else if (snapshot.hasError) {
          return Center(
              child: Text(
                  'เกิดข้อผิดพลาด: ${snapshot.error}')); // แสดงข้อความข้อผิดพลาดหากมี
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text('ไม่พบสัตว์เลี้ยง')); // แสดงข้อความหากไม่พบข้อมูล
        }

        final pets = snapshot.data!.docs; // ดึงข้อมูลสัตว์เลี้ยง
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: pets.map((pet) {
              return _buildPetCard(pet); // สร้างการ์ดสำหรับสัตว์เลี้ยงแต่ละตัว
            }).toList(),
          ),
        );
      },
    );
  }

  // ฟังก์ชันสร้างการ์ดสำหรับแต่ละสัตว์เลี้ยง
  Widget _buildPetCard(DocumentSnapshot pet) {
    var data =
        pet.data() as Map<String, dynamic>; // ดึงข้อมูลจากเอกสาร Firestore
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ชื่อสัตว์เลี้ยง: ${data['name']}', // แสดงชื่อสัตว์เลี้ยง
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // นำทางไปยังหน้าจอ Propet เพื่อแก้ไขข้อมูลสัตว์เลี้ยง
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Propet(
                          petId: pet.id,
                          name: data['name'],
                          history: data['history'],
                          address: data['address'],
                          imageUrl: data['imageUrl'],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit), // ไอคอนสำหรับแก้ไขข้อมูล
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'ประวัติโรคประจำตัวสัตว์เลี้ยง: ${data['history']}', // แสดงประวัติโรคประจำตัว
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'ที่อยู่: ${data['address']}', // แสดงที่อยู่
              style: const TextStyle(fontSize: 16),
            ),
            if (data['imageUrl'] != null)
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Image.network(
                  data['imageUrl'], // แสดงภาพสัตว์เลี้ยงจาก URL
                  fit: BoxFit.cover,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    log(data.toString());
                    // นำทางไปยังหน้าจอ PetOwnerView เพื่อฝากสัตว์เลี้ยง
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetOwnerView(pet: data),
                      ),
                    );
                    // เพิ่มฟังก์ชันการแก้ไขที่นี่
                    // ตัวอย่างเช่น นำทางไปยังหน้าจอแก้ไขด้วยข้อมูล
                  },
                  child: const Text('ฝากสัตว์เลี้ยง'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
