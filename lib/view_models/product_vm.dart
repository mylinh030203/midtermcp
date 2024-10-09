
import 'dart:io';

import 'package:flutter/material.dart';
import '../model/product.dart';
import '../services/fb_service.dart';

class ProductViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Products> _products = [];
  bool isLoading = false;
  String? errorMessage;

  List<Products> get products => _products;

  ProductViewModel() {
    fetchProducts();
  }

  void fetchProducts() {
    _firebaseService.getProducts().listen((productsData) {
      _products = productsData;
      notifyListeners();
    });
  }

  // Future<bool> addOrUpdateProduct(Products product) async {
  //   isLoading = true;
  //   notifyListeners();
  //   try {
  //     await _firebaseService.addOrUpdateProduct(product);
  //     isLoading = false;
  //     notifyListeners();
  //     return true;
  //   } catch (e) {
  //     isLoading = false;
  //     errorMessage = e.toString();
  //     notifyListeners();
  //     return false;
  //   }
  // }

  Future<bool> addOrUpdateProduct(Products product, String img ) async {
    isLoading = true;
    notifyListeners();

    try {
      // Kiểm tra xem có file hình ảnh hay không
      if (img != null) {
        await _firebaseService.addOrUpdateProduct(product, img);
        isLoading = false;
        notifyListeners();
        return true;
      }else{
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(Products product) async {
    isLoading = true;
    notifyListeners();
    try {
      await _firebaseService.deleteProduct(product.id);
      // Xóa hình ảnh cục bộ
      if (product.imageUrl.isNotEmpty) {
        await _firebaseService.deleteImage(product.imageUrl);
      }
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Future<String?> uploadImage(String filePath) async {
  //   try {
  //     String localPath = await _firebaseService.saveImageLocally(File(filePath));
  //     return localPath;
  //   } catch (e) {
  //     errorMessage = e.toString();
  //     notifyListeners();
  //     return null;
  //   }
  // }

// Phương thức tải ảnh lên
  Future<String?> uploadImage(File imageFile) async {
    try {
      return await _firebaseService.uploadImageToFirebaseStorage(imageFile);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
}
