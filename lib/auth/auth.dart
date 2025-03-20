import 'package:dnt_22itb143/screen/login_screen.dart';
import 'package:dnt_22itb143/screen/product_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth {
  final _auth = FirebaseAuth.instance;

  // Đăng nhập tài khoản
  Future<void> login(String email, String password, context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProductScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'wrong-password' || e.code == 'user-not-found') {
        errorMessage =
            "Bạn sai tài khoản hoặc mật khẩu, vui lòng đăng nhập lại";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Địa chỉ email không hợp lệ, vui lòng nhập lại";
      } else {
        errorMessage = e.message ??
            "An unknown error occurred"; // Other Firebase error messages
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Đăng ký tài khoản
  Future<void> register(String email, String password, context) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      // ignore: unnecessary_null_comparison  
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
        // await FirebaseAuth.instance.signOut();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = "Email đã được sử dụng, vui lòng chọn email khác";
      } else if (e.code == 'weak-password') {
        errorMessage = "Mật khẩu quá yếu, vui lòng chọn mật khẩu khác";
      } else {
        errorMessage = e.message ??
            "An unknown error occurred"; // Other Firebase error messages
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
