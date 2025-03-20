import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageService {
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
