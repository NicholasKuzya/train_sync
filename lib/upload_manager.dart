import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class UploadManager with ChangeNotifier {
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  double get uploadProgress => _uploadProgress;
  bool get isUploading => _isUploading;

  Future<Map<String, dynamic>> uploadFile(String token, String videoPath, String categoryId, String name, String description) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    var headers = {'authorization': token};
    var dio = Dio();
    dio.options.headers.addAll(headers);

    FormData formData = FormData.fromMap({
      'name': name,
      'description': description,
      'muscleCategoryId': categoryId,
      'video': await MultipartFile.fromFile(videoPath, filename: 'video.mp4'),
    });

    var response = await dio.post(
      'https://training-sync.com/api/trainer/exercises',
      data: formData,
      onSendProgress: (int sent, int total) {
        _uploadProgress = sent / total;
        notifyListeners();
      },
    );

    _isUploading = false;
    notifyListeners();
    return response.data;
  }
}
