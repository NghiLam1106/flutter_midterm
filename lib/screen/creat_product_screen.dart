import 'dart:io';

import 'package:dnt_22itb143/service/image_service.dart';
import 'package:dnt_22itb143/service/product_service.dart';
import 'package:flutter/material.dart';

class CreatProductScreen extends StatefulWidget {
  const CreatProductScreen({super.key});

  @override
  CreatProductScreenState createState() => CreatProductScreenState();
}

class CreatProductScreenState extends State<CreatProductScreen> {
  final _formkey = GlobalKey<FormState>();
  String productType = '';
  String productPrice = '';
  File? productImage;
  String productId = '';
  List<Map<String, dynamic>> productsList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 25, right: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 35),
              Center(
                child: Text(
                  'Tạo sản phẩm',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 25),
              Center(
                child: Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Loại sản phẩm'),
                        onChanged: (value) => productType = value,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Không được để trống'
                            : null,
                      ),
                      SizedBox(height: 25),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Giá sản phẩm'),
                        onChanged: (value) => productPrice = value,
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Không được để trống'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      ImageService imageService = ImageService();
                      File? imageFile =
                          await imageService.imagePicker(); // Chờ lấy ảnh xong
                      if (imageFile != null) {
                        setState(() {
                          // Cập nhật UI sau khi có ảnh
                          productImage = imageFile;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50),
                    ),
                    child: Text('Thêm ảnh'),
                  ),
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: productImage != null
                        ? Image.file(
                            productImage!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 100,
                            width: 100,
                            color: Colors.grey[300],
                            child: Icon(Icons.image, size: 50),
                          ),
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
                    onPressed: () {
                      ProductService productService = ProductService();
                      productService.addProduct(
                        productType,
                        productPrice,
                        productImage,
                        _formkey,
                        context,
                      );
                      // addProduct();
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Hủy',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
