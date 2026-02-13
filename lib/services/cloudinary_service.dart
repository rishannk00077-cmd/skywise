import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String _cloudName = 'drc88o44v'; // Placeholder
  final String _uploadPreset = 'profile_pics'; // Placeholder

  Future<String?> uploadImage(String filePath) async {
    try {
      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonResponse = jsonDecode(responseString);
        return jsonResponse['secure_url'];
      } else {
        print('Cloudinary Upload Failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Cloudinary Upload Error: $e');
      return null;
    }
  }
}
