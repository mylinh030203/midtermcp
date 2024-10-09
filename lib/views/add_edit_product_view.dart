import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../view_models/product_vm.dart';
import '../model/product.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddEditProductView extends StatefulWidget {
  final Products? product;

  AddEditProductView({this.product});

  @override
  _AddEditProductViewState createState() => _AddEditProductViewState();
}

class _AddEditProductViewState extends State<AddEditProductView> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String type = '';
  double price = 0.0;
  String imagePath = '';
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      name = widget.product!.name;
      type = widget.product!.type;
      price = widget.product!.price;
      imagePath = widget.product!.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      if (imagePath.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn hình ảnh sản phẩm.')),
        );
        return;
      }

      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });

      final productViewModel =
          Provider.of<ProductViewModel>(context, listen: false);

      // Tạo đối tượng sản phẩm mới
      Products product = Products(
        id: widget.product?.id ?? '',
        // Nếu không có ID, tạo mới
        name: name,
        type: type,
        price: price,
        imageUrl: '', // Để trống URL ban đầu, sẽ cập nhật sau khi tải lên
      );

      // Tải ảnh lên và nhận URL
      String? savedImageUrl =
          await productViewModel.uploadImage(File(imagePath));
      if (savedImageUrl != null) {
        product.imageUrl = savedImageUrl; // Cập nhật imageUrl
      } else {
        if (widget.product!.imageUrl != null) {
          product.imageUrl = widget.product!.imageUrl;
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lưu hình ảnh thất bại.')),
          );
          return;
        }

      }

      // Thêm hoặc cập nhật sản phẩm
      bool success =
          await productViewModel.addOrUpdateProduct(product, product.imageUrl);
      setState(() {
        isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.product == null
                  ? 'Thêm sản phẩm thành công!'
                  : 'Cập nhật sản phẩm thành công!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thao tác thất bại!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa Sản Phẩm' : 'Thêm Sản Phẩm'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Tên sản phẩm
                    TextFormField(
                      initialValue: name,
                      decoration: InputDecoration(labelText: 'Tên Sản Phẩm'),
                      validator: (value) =>
                          value!.isEmpty ? 'Nhập tên sản phẩm' : null,
                      onSaved: (value) => name = value!,
                    ),
                    // Loại sản phẩm
                    TextFormField(
                      initialValue: type,
                      decoration: InputDecoration(labelText: 'Loại Sản Phẩm'),
                      validator: (value) =>
                          value!.isEmpty ? 'Nhập loại sản phẩm' : null,
                      onSaved: (value) => type = value!,
                    ),
                    // Giá sản phẩm
                    TextFormField(
                      initialValue: price != 0.0 ? price.toString() : '',
                      decoration: InputDecoration(labelText: 'Giá'),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (value) =>
                          value!.isEmpty ? 'Nhập giá sản phẩm' : null,
                      onSaved: (value) => price = double.parse(value!),
                    ),
                    SizedBox(height: 20),
                    // Hình ảnh sản phẩm
                    GestureDetector(
                      onTap: _pickImage,
                      child: imagePath.isNotEmpty
                          ? (imagePath.startsWith('http')
                              ? Image.network(
                                  imagePath,
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(imagePath),
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.cover,
                                ))
                          : widget.product != null &&
                                  widget.product!.imageUrl.isNotEmpty
                              ? Image.network(
                                  widget.product!.imageUrl,
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 300,
                                  height: 300,
                                  color: Colors.grey,
                                  child: Icon(Icons.camera_alt),
                                ),
                    ),

                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveProduct,
                      child: Text(isEdit ? 'Cập Nhật' : 'Thêm'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
