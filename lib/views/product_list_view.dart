import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../view_models/product_vm.dart';
import '../model/product.dart';
import 'add_edit_product_view.dart';
import 'login_view.dart';
import '../view_models/user_view_model.dart';

class ProductListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productViewModel = Provider.of<ProductViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Quản Lý Sản Phẩm'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              userViewModel.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginView()),
              );
            },
          ),
        ],
      ),
      body: productViewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : productViewModel.products.isEmpty
              ? Center(child: Text('Không có sản phẩm nào.'))
              : ListView.builder(
                  itemCount: productViewModel.products.length,
                  itemBuilder: (context, index) {
                    final product = productViewModel.products[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hiển thị ảnh sản phẩm
                          product.imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: product.imageUrl,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover)
                              : Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey,
                                  child: Icon(Icons.image, color: Colors.white),
                                ),
                          SizedBox(width: 10),
                          // Hiển thị thông tin sản phẩm
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text('${product.type} - \$${product.price}'),
                              ],
                            ),
                          ),
                          // Các nút chỉnh sửa và xóa
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddEditProductView(product: product),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _confirmDelete(
                                      context, productViewModel, product);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditProductView(product: null),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, ProductViewModel viewModel, Products product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Xóa Sản Phẩm'),
        content: Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              bool success = await viewModel.deleteProduct(product);
              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Xóa sản phẩm thành công!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Xóa sản phẩm thất bại!')),
                );
              }
            },
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
