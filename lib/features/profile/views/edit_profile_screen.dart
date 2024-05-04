import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../token_manager.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _achievementsController = TextEditingController();
  final TextEditingController _gymController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  String? _role;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    String? token = await TokenManager.getToken();
    String? role = await TokenManager.getRole();
    setState(() {
      _role = role;
    });

    if (_role != null && _role!.isNotEmpty) {
      var url = Uri.parse('http://192.168.0.105:4000/api/$_role/get');
      var response = await http.post(
        url,
        headers: {'authorization': '$token'},
      );
      var data = json.decode(response.body);
      var dataRes = data[_role!];
      setState(() {
        _fullNameController.text = dataRes["fullName"] ?? '';
        _countryController.text = dataRes["country"] ?? '';
        _cityController.text = dataRes["city"] ?? '';
        _districtController.text = dataRes["district"] ?? '';
        _genderController.text = dataRes["gender"] ?? '';
        _birthDateController.text =
        dataRes["birthDate"] != null ? _dateFormat.format(DateTime.parse(dataRes["birthDate"])) : '';

        _aboutController.text = dataRes["about"] ?? '';
        _achievementsController.text = dataRes["achievements"] ?? '';
        _gymController.text = dataRes["gym"] ?? '';
        _specializationController.text = dataRes["specialization"] ?? '';

        _weightController.text = dataRes["weight"] != null ? dataRes["weight"].toString() : '';
        _heightController.text = dataRes["height"] != null ? dataRes["height"].toString() : '';
        _goalController.text = dataRes["goal"] ?? '';
        _isLoading = false; // Устанавливаем флаг загрузки в false, так как данные получены
      });
    } else {
      setState(() {
        _isLoading = false; // Устанавливаем флаг загрузки в false, так как данные не получены
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.title_edit_profile),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fullName),
              ),
              TextField(
                controller: _countryController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.country),
              ),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.city),
              ),
              TextField(
                controller: _districtController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.district),
              ),
              TextField(
                controller: _genderController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.gender),
              ),
              GestureDetector(
                onTap: () {
                  picker.DatePicker.showDatePicker(
                    context,
                    showTitleActions: true,
                    onChanged: (date) {},
                    onConfirm: (date) {
                      setState(() {
                        _birthDateController.text = _dateFormat.format(date);
                      });
                    },
                    currentTime: DateTime.now(),
                  );
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: _birthDateController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.dateOfBirth),
                  ),
                ),
              ),
              if (_role == "student") ...[
                TextField(
                  controller: _weightController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.weight),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: _heightController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.height),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: _goalController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.goal),
                  maxLines: 5,
                ),
              ],
              if (_role == "trainer") ...[
                TextField(
                  controller: _aboutController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.profileAbout),
                  maxLines: 5,
                ),
                TextField(
                  controller: _achievementsController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.achiv),
                  maxLines: 5,
                ),
                TextField(
                  controller: _gymController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.gym),
                ),
                TextField(
                  controller: _specializationController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.specialization),
                  maxLines: 5,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    String? token = await TokenManager.getToken();
    if (_role != null && _role!.isNotEmpty) {
      var url = Uri.parse('http://192.168.0.105:4000/api/$_role/update');
      Map<String, dynamic> requestBody = {
        "fullName": _fullNameController.text,
        "country": _countryController.text,
        "city": _cityController.text,
        "district": _districtController.text,
        "gender": _genderController.text,
        "birthDate": _birthDateController.text,
      };

      if (_role == "trainer") {
        requestBody.addAll({
          "about": _aboutController.text,
          "achievements": _achievementsController.text,
          "gym": _gymController.text,
          "specialization": _specializationController.text,
        });
      } else if (_role == "student") {
        requestBody.addAll({
          "weight": _weightController.text,
          "height": _heightController.text,
          "goal": _goalController.text,
        });
      }

      var response = await http.put(
        url,
        headers: {'authorization': '$token', 'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      var responseBody = json.decode(response.body);
      print(responseBody);
      if (responseBody["success"]) {
        // Показать уведомление об успешном сохранении
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.editProfileSuccess),
          duration: Duration(seconds: 2),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.editProfileUnSuccess),
          duration: Duration(seconds: 2),
        ));
      }
    } else {
      // Обработать случай, когда _role пустой или равен null (например, показать сообщение об ошибке)
    }
  }
}

