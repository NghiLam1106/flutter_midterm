import 'package:dnt_22itb143/screen/login_screen.dart';
import 'package:dnt_22itb143/screen/product_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth {
  final _auth = FirebaseAuth.instance;

  // Đăng nhập tài khoản
  Future<void> login(String email, String password, context) async {
    try {
      // Hiển thị trạng thái tải (tùy chọn)
      showLoadingDialog(context);

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await user.reload(); // Cập nhật trạng thái tài khoản

        if (!user.emailVerified) {
          // Nếu email chưa xác minh, yêu cầu người dùng xác nhận
          Navigator.pop(context); // Đóng hộp thoại tải
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text("Email chưa được xác minh! Vui lòng kiểm tra hộp thư."),
              backgroundColor: Colors.red,
            ),
          );
          await user.sendEmailVerification(); // Gửi lại email xác minh
        } else {
          // Nếu đã xác minh, chuyển hướng đến màn hình sản phẩm
          Navigator.pop(context); // Đóng hộp thoại tải
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProductScreen()),
          );
        }
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

  // Hiển thị hộp thoại tải
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  // Đăng ký tài khoản
  Future<void> register(String email, String password, context) async {
    try {
      // Hiển thị trạng thái tải (tùy chọn)
      showLoadingDialog(context);

      final user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // ignore: unnecessary_null_comparison
      if (user != null) {
        Navigator.pop(context); // Đóng hộp thoại tải
        Navigator.pop(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
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
