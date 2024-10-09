import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'views/register_view.dart';
import 'view_models/user_view_model.dart';
import 'views/add_edit_product_view.dart';
import 'views/product_list_view.dart';
import 'package:provider/provider.dart';

import 'views/login_view.dart';
import 'view_models/product_vm.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(options: FirebaseOptions( apiKey: "AIzaSyAmayLBdtb_se0T4cQm7NYim1WC5M0wWXM",
        authDomain: "midterm-cross-platform.firebaseapp.com",
        databaseURL: "https://midterm-cross-platform-default-rtdb.firebaseio.com",
        projectId: "midterm-cross-platform",
        storageBucket: "midterm-cross-platform.appspot.com",
        messagingSenderId: "873186346138",
        appId: "1:873186346138:web:b87226f3425885e3350b23",
        measurementId: "G-MSBXW2XDXZ"));
  }else{
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Đây là widget gốc của ứng dụng
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Cung cấp UserViewModel và ProductViewModel cho toàn bộ ứng dụng
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
      ],
      child: MaterialApp(
        title: 'Admin Product Management',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AuthenticationWrapper(), // Sử dụng AuthenticationWrapper để kiểm tra trạng thái đăng nhập
        routes: {
          // Định nghĩa các route cho ứng dụng
          '/login': (context) => LoginView(),
          '/register': (context) => RegisterView(),
          '/products': (context) => ProductListView(),
          '/add_edit_product': (context) => AddEditProductView(),
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);

    if (userViewModel.currentUser != null) {
      return ProductListView();
    } else {
      return LoginView();
    }
  }
}