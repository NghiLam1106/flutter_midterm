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
  List<Map<String, dynamic>> filteredProducts = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    List<Map<String, dynamic>> products = await ProductService().getProducts();
    setState(() {
      productsList = products;
      filteredProducts = products; // Khởi tạo danh sách sản phẩm
    });
  }

  // Tìm kiếm sản phẩm theo tên hoặc loại
  void _searchProducts(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredProducts = productsList.where((product) {
        return product['idsanpham']
                .toString()
                .toLowerCase()
                .contains(searchQuery) ||
            product['loaisp'].toString().toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 25),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 20, end: 15, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Tìm kiếm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    onSubmitted: (value) {
                      _searchProducts(value);
                    },
                    // style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
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
              ],
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Danh sách sản phẩm',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: productsList.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 80, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        "Chưa có sản phẩm nào!",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  )
                : filteredProducts.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 80, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            "Không tìm thấy sản phẩm nào!",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          var product = filteredProducts[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Card(
                              child: ListTile(
                                leading: Image.network(
                                  product['hinhanh'],
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(product['idsanpham']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ignore: prefer_interpolation_to_compose_strings
                                    Text("Loại: " + product['loaisp']),
                                    // ignore: prefer_interpolation_to_compose_strings
                                    Text("Giá: ${product['gia']}"),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.edit, color: Colors.green),
                                      onPressed: () async {
                                        final updatedProduct =
                                            await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UpdateProductScreen(
                                                    productId:
                                                        product['docId']),
                                          ),
                                        );

                                        if (updatedProduct != null) {
                                          setState(() {
                                            // Cập nhật danh sách sản phẩm sau khi nhận dữ liệu mới từ màn hình cập nhật
                                            productsList[index] =
                                                updatedProduct;
                                          });
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        List<Map<String, dynamic>> updatedList =
                                            await ProductService()
                                                .deleteProduct(
                                          product['docId'],
                                          index,
                                          context,
                                          productsList,
                                        );
                                        setState(
                                          () {
                                            productsList = updatedList;
                                            filteredProducts = updatedList;
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
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
}
