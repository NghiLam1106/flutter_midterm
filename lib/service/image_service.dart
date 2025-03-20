import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker picker = ImagePicker();

  // Chọn ảnh từ thư viện
  Future<File?> imagePicker() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }

  // Lấy URL ảnh từ Cloudinary
  Future<String> saveImageLocally(File image) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dpjpqdp71/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'ml_default'
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = jsonDecode(responseString);
      return jsonResponse['secure_url'];
    } else {
      return '';
    }
  }
}
