import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnt_22itb143/service/product_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProductScreen extends StatefulWidget {
  final String productId;

  const UpdateProductScreen({
    super.key,
    required this.productId,
  });

  @override
  UpdateProductScreenState createState() => UpdateProductScreenState();
}

class UpdateProductScreenState extends State<UpdateProductScreen> {
  final _formkey = GlobalKey<FormState>();
  late TextEditingController typeController;
  late TextEditingController priceController;
  File? productImage;
  String productImageUrl = '';
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    typeController = TextEditingController();
    priceController = TextEditingController();
    fetchProductData();
  }

  Future<void> fetchProductData() async {
    try {
      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (productDoc.exists) {
        Map<String, dynamic> productData =
            productDoc.data() as Map<String, dynamic>;

        setState(() {
          typeController.text = productData['type'] ?? '';
          priceController.text = productData['price'].toString();
          productImageUrl = productData['image'] ?? ''; // Lưu URL ảnh
        });
      }
    } catch (e) {
      print('Lỗi lấy dữ liệu sản phẩm: $e');
    }
  }

  Future<void> imagePicker() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        productImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              SizedBox(height: 35),
              Center(
                child: Text(
                  'Cập nhật sản phẩm',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 25),
              Form(
                key: _formkey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Loại sản phẩm'),
                      controller: typeController,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Không được để trống'
                          : null,
                    ),
                    SizedBox(height: 25),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Giá sản phẩm'),
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Không được để trống'
                          : null,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: imagePicker,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50),
                    ),
                    child: Text('Chọn ảnh'),
                  ),
                  SizedBox(width: 20),
                  productImage != null
                      ? Image.file(productImage!, height: 100, width: 100)
                      : productImageUrl.isNotEmpty
                          ? Image.network(productImageUrl,
                              height: 100, width: 100)
                          : Container(
                              height: 100,
                              width: 100,
                              color: Colors.grey[300],
                              child: Icon(Icons.image, size: 50),
                            ),
                ],
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: Size(100, 50),
                    ),
                    onPressed: () async {
                      await ProductService().updateProduct(
                        productImageUrl,
                        productImage,
                        typeController.text,
                        priceController.text,
                        widget.productId,
                        context,
                        _formkey,
                      );
                    },
                    child: Text(
                      'Lưu sản phẩm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: Size(100, 50),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Hủy',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
