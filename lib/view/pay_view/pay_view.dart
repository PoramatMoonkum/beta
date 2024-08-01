import 'package:flutter/material.dart';
import 'package:pettakecare/view/pay_view/checkout_view.dart';

// คลาส MyOrderView ใช้สำหรับแสดงหน้าเลือกวิธีการชำระเงิน
class MyOrderView extends StatefulWidget {
  const MyOrderView({Key? key}) : super(key: key);

  @override
  State<MyOrderView> createState() => _MyOrderViewState();
}

// State ของ MyOrderView
class _MyOrderViewState extends State<MyOrderView> {
  // เก็บค่าของวิธีการชำระเงินที่ถูกเลือก
  PaymentMethod selectedPaymentMethod = PaymentMethod.QRCode;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size; // ขนาดของหน้าจอ

    return Scaffold(
      appBar: AppBar(
        title: Text("Payment"), // ชื่อแอพบาร์เป็น "Payment"
        leading: BackButton(), // ปุ่มย้อนกลับ
        backgroundColor: Colors.orange, // สีพื้นหลังของแอพบาร์
        foregroundColor: Colors.white, // สีของข้อความและไอคอนในแอพบาร์
        elevation: 0, // ไม่มีเงา
        centerTitle: true, // จัดกลางชื่อในแอพบาร์
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0), // กำหนดระยะห่างรอบๆ ของเนื้อหา
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 40, // ระยะห่างด้านบน
              ),
              // RadioListTile สำหรับเลือก QR Code เป็นวิธีการชำระเงิน
              RadioListTile<PaymentMethod>(
                title: const Text('QR Code'), // ข้อความที่แสดงบน RadioListTile
                value:
                    PaymentMethod.QRCode, // ค่าเมื่อวิธีการชำระเงินเป็น QR Code
                groupValue: selectedPaymentMethod, // ค่าในกลุ่มที่ถูกเลือก
                onChanged: (PaymentMethod? value) {
                  setState(() {
                    selectedPaymentMethod =
                        value!; // อัพเดตค่าเมื่อมีการเปลี่ยนแปลง
                  });
                },
              ),
              // RadioListTile สำหรับเลือก PayPal เป็นวิธีการชำระเงิน
              RadioListTile<PaymentMethod>(
                title: const Text('PayPal'), // ข้อความที่แสดงบน RadioListTile
                value:
                    PaymentMethod.paypal, // ค่าเมื่อวิธีการชำระเงินเป็น PayPal
                groupValue: selectedPaymentMethod, // ค่าในกลุ่มที่ถูกเลือก
                onChanged: (PaymentMethod? value) {
                  setState(() {
                    selectedPaymentMethod =
                        value!; // อัพเดตค่าเมื่อมีการเปลี่ยนแปลง
                  });
                },
              ),
              SizedBox(height: 20), // ระยะห่างด้านล่าง
              // ElevatedButton สำหรับดำเนินการชำระเงิน
              ElevatedButton(
                onPressed: () {
                  // นำทางไปยังหน้า CheckoutView
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CheckoutView()));
                  // ดำเนินการชำระเงินตามวิธีที่เลือก
                },
                child: Text("ชำระเงิน"), // ข้อความบนปุ่ม
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enum สำหรับการเลือกวิธีการชำระเงิน
enum PaymentMethod {
  QRCode, // QR Code
  paypal, // PayPal
}
