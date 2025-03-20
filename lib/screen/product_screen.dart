import 'package:dnt_22itb143/screen/creat_product_screen.dart';
import 'package:dnt_22itb143/screen/login_screen.dart';
import 'package:dnt_22itb143/screen/update_product_screen.dart';
import 'package:dnt_22itb143/service/product_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  ProductScreenState createState() => ProductScreenState();
}

class ProductScreenState extends State<ProductScreen> {
  final _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> productsList = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    List<Map<String, dynamic>> products = await ProductService().getProducts();
    setState(() {
      productsList = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsetsDirectional.only(top: 25, end: 25),
              child: IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
          Center(
            child: Text(
              'Danh sách sản phẩm',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 25),
          Expanded(
            child: ListView.builder(
              itemCount: productsList.length,
              itemBuilder: (context, index) {
                var product = productsList[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      product['image'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                    // ignore: prefer_interpolation_to_compose_strings
                    title: Text("Loại: " + product['type']),
                    // ignore: prefer_interpolation_to_compose_strings
                    subtitle: Text("Giá: " + product['price']),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.green),
                          onPressed: () async {
                            final updatedProduct = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateProductScreen(
                                    productId: product['docId']),
                              ),
                            );

                            if (updatedProduct != null) {
                              setState(() {
                                // Cập nhật danh sách sản phẩm sau khi nhận dữ liệu mới từ màn hình cập nhật
                                productsList[index] = updatedProduct;
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                              List<Map<String, dynamic>> updatedList = await ProductService().deleteProduct(
                                product['docId'],
                                index,
                                context,
                                productsList,
                              );
                              setState(() {
                                productsList = updatedList;
                              });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToCreateProductScreen(context);
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _navigateToCreateProductScreen(BuildContext context) async {
    final newProduct = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatProductScreen()),
    );

    if (newProduct != null) {
      setState(() {
        productsList.add(newProduct);
      });
    }
  }

  // Xóa sản phẩm
  // Future<void> deleteProduct(String docId, int index) async {
  //   try {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Xác nhận xóa'),
  //           content: Text('Bạn có chắc chắn muốn xóa sản phẩm này không?'),
  //           actions: <Widget>[
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //               child: Text('Hủy'),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 FirebaseFirestore.instance
  //                     .collection('products')
  //                     .doc(docId)
  //                     .delete();

  //                 setState(() {
  //                   productsList.removeAt(index);
  //                 });

  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(content: Text('Đã xóa sản phẩm thành công!')),
  //                 );

  //                 Navigator.of(context).pop();
  //               },
  //               child: Text(
  //                 'Xóa',
  //                 style: TextStyle(color: Colors.red),
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   } catch (e) {
  //     print("Lỗi khi xóa: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Xóa sản phẩm thất bại!')),
  //     );
  //   }
  // }
}
