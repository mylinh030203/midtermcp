// lib/services/firebase_service.dart
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../model/product.dart';
import '../model/user.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance; // Tạo tham chiếu đến Firebase Storage


  // USER RELATED METHODS

  // Đăng ký người dùng mới
  Future<void> registerUser(UserModel user) async {
    DatabaseReference usersRef = _dbRef.child('users');
    // Kiểm tra xem email đã tồn tại chưa
    Query emailQuery = usersRef.orderByChild('email').equalTo(user.email);
    // DatabaseEvent snapshot = await usersRef.orderByChild('email').equalTo(user.email).once();
    DatabaseEvent event = await emailQuery.once();
    if (event.snapshot.value!= null) {
      print(event.snapshot.value.toString());
      throw Exception('Email đã được sử dụng.');
    }else{
      // Thêm người dùng mới
      DatabaseReference newUserRef = usersRef.push();
      await newUserRef.set(user.toMap());
    }

    // emailQuery.once().then((DatabaseEvent snapshot) {
    //   if (snapshot.snapshot.value != null) {
    //     // Email đã tồn tại, thông báo lỗi
    //     print('Email đã được sử dụng.');
    //     throw Exception('Email đã được sử dụng.');
    //   } else {
    //     // Email không tồn tại, tiếp tục với logic đăng ký hoặc xử lý khác
    //     print('Email chưa được sử dụng, có thể tiếp tục.');
    //   }
    // }).catchError((error) {
    //   // Xử lý lỗi nếu có trong quá trình truy vấn
    //   print('Lỗi khi kiểm tra email: $error');
    // });
  }

  // Đăng nhập người dùng
  Future<UserModel?> loginUser(String email, String password) async {
    DatabaseReference usersRef = _dbRef.child('users');
    Query emailQuery = usersRef.orderByChild('email').equalTo(email);
    // DatabaseEvent snapshot = await usersRef.orderByChild('email').equalTo(user.email).once();
    DatabaseEvent event = await emailQuery.once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> usersMap = event.snapshot.value as dynamic;
      for (var key in usersMap.keys) {
        Map<dynamic, dynamic> userMap = usersMap[key];
        if (userMap['password'] == password) {
          return UserModel.fromMap(userMap, key);
        }
      }
    }
    return null; // Không tìm thấy người dùng hoặc mật khẩu không đúng
  }

  // PRODUCT RELATED METHODS

  // Lấy danh sách sản phẩm
  Stream<List<Products>> getProducts() {
    return _dbRef.child('products').onValue.map((event) {
      final List<Products> products = [];
      if (event.snapshot.value != null) {
        // Map<dynamic, dynamic> data = event.snapshot.value;
        // data.forEach((key, value) {
        //   products.add(Products.fromMap(value, key));
        // });
        Map<dynamic, dynamic>.from(event.snapshot.value as dynamic).forEach((key, value) => products.add(Products.fromMap(value, key)));
      }
      return products;
    });
  }

  // Thêm hoặc cập nhật sản phẩm
  // Future<void> addOrUpdateProduct(Products product) async {
  //   DatabaseReference productsRef = _dbRef.child('products');
  //   if (product.id.isEmpty) {
  //     DatabaseReference newProductRef = productsRef.push();
  //     await newProductRef.set(product.toMap());
  //   } else {
  //     await productsRef.child(product.id).set(product.toMap());
  //   }
  // }

  // Thêm hoặc cập nhật sản phẩm
  Future<void> addOrUpdateProduct(Products product, String imageUrl) async {
    DatabaseReference productsRef = _dbRef.child('products');

    // Nếu có ảnh mới, tải lên Firebase Storage
    // if (imageFile != null) {
    //   String? imageUrl = await uploadImageToFirebaseStorage(imageFile);
      if (imageUrl != null) {
        product.imageUrl = imageUrl; // Cập nhật URL của ảnh vào model product
      }
    // }

    if (product.id.isEmpty) {
      DatabaseReference newProductRef = productsRef.push();
      await newProductRef.set(product.toMap());
    } else {
      await productsRef.child(product.id).set(product.toMap());
    }
  }

  // Tải ảnh lên Firebase Storage
  Future<String?> uploadImageToFirebaseStorage(File imageFile) async {
    try {
      // Tạo tham chiếu đến Firebase Storage
      final storageRef = _storage.ref().child('product_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Tải lên file
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => null);

      // Lấy URL của ảnh đã tải lên
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Lỗi khi tải ảnh lên Firebase Storage: $e');
      return null;
    }

  }

  // Xóa sản phẩm
  Future<void> deleteProduct(String id) async {
    DatabaseReference productsRef = _dbRef.child('products');
    await productsRef.child(id).remove();
  }

  // Xóa hình ảnh khỏi thư mục
  Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // IMAGE RELATED METHODS
  //
  // // Lưu hình ảnh vào thư mục trong dự án và trả về đường dẫn
  // Future<String> saveImageLocally(File imageFile) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final String fileName = path.basename(imageFile.path);
  //   final String newPath = path.join(directory.path, 'images');
  //   final imagesDir = Directory(newPath);
  //
  //   if (!await imagesDir.exists()) {
  //     await imagesDir.create(recursive: true);
  //   }
  //
  //   final String localPath = path.join(imagesDir.path, fileName);
  //   final File localImage = await imageFile.copy(localPath);
  //   return localImage.path;
  // }
  //
  // // Xóa hình ảnh khỏi thư mục
  // Future<void> deleteImage(String imagePath) async {
  //   final file = File(imagePath);
  //   if (await file.exists()) {
  //     await file.delete();
  //   }
  // }

}

extension on DatabaseEvent {
  get value => null;
}
