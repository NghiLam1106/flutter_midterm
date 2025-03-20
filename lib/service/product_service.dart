import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnt_22itb143/screen/product_screen.dart';
import 'package:dnt_22itb143/service/image_service.dart';
import 'package:flutter/material.dart';

class ProductService {
  ImageService imageService = ImageService();

  // Lấy danh sách sản phẩm từ Firestore
  Future<List<Map<String, dynamic>>> getProducts() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('products').get();
    return querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['docId'] = doc.id; // Lưu ID tài liệu
      return data;
    }).toList();
  }

  // Thêm sản phẩm vào Firestore
  Future<void> addProduct(String productType, String productPrice,
      File? productImage, GlobalKey<FormState> formkey, context) async {
    if (formkey.currentState!.validate()) {
      // ignore: non_constant_identifier_names
      String ImageURL = '';

      if (productImage != null) {
        // ImageURL = await saveImageLocally(productImage);
        ImageURL = await imageService.saveImageLocally(productImage);
      }

      try {
        await FirebaseFirestore.instance.collection('products').add({
          'type': productType,
          'price': productPrice,
          'image': ImageURL,
        });

        // Hiển thị thông báo thêm sản phẩm thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thêm sản phẩm thành công!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProductScreen(),
          ),
        );
      } catch (e) {
        print(e);
      }
    }
  }

  // Xóa sản phẩm
  Future<List<Map<String, dynamic>>> deleteProduct(String docId, int index,
      BuildContext context, List<Map<String, dynamic>> productsList) async {
    try {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Xác nhận xóa'),
            content: Text('Bạn có chắc chắn muốn xóa sản phẩm này không?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  'Xóa',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(docId)
            .delete();

        productsList.removeAt(index);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa sản phẩm thành công!')),
        );
      }
    } catch (e) {
      print("Lỗi khi xóa: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa sản phẩm thất bại!')),
      );
    }
    return productsList;
  }

  // Cập nhật sản phẩm
  Future<void> updateProduct(productImageUrl, productImage, typeController,
      priceController, productId, context, GlobalKey<FormState> formkey) async {
    if (formkey.currentState!.validate()) {
      try {
        String updatedImageUrl = productImageUrl;

        // Nếu có ảnh mới, tải lên Cloudinary trước
        if (productImage != null) {
          // updatedImageUrl = await uploadImage(productImage!);
          updatedImageUrl = await imageService.saveImageLocally(productImage);
        }

        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .update({
          'type': typeController,
          'price': priceController,
          'image': updatedImageUrl,
        });

        // Hiển thị thông báo cập nhật thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật sản phẩm thành công!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProductScreen(),
          ),
        );
      } catch (e) {
        print('Lỗi cập nhật sản phẩm: $e');
      }
    }
  }
}
