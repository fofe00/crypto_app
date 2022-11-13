import 'package:crypto_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfileScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  Future<void> saveData(String key, String value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(key, value);
  }

  void saveUserDetails() async {
    String name = nameController.text;
    String email = emailController.text;
    String age = ageController.text;
    await saveData("name", name);
    await saveData("email", email);
    await saveData("age", age);
  }

  bool isDarkModeEnabled = AppTheme.isDarkModeEnabled;

  UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkModeEnabled ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text("Profile Update"),
      ),
      body: Column(
        children: [
          customTextField("Name", nameController, false),
          customTextField("Email", emailController, false),
          customTextField("Age", ageController, true),
          ElevatedButton(
            onPressed: () {
              saveUserDetails();
            },
            child: const Text("Save Details"),
          )
        ],
      ),
    );
  }

  Padding customTextField(
      String title, TextEditingController controller, bool numberInput) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isDarkModeEnabled ? Colors.white : Colors.grey)),
            hintText: title,
            hintStyle:
                TextStyle(color: isDarkModeEnabled ? Colors.white : null)),
        keyboardType: numberInput ? TextInputType.number : null,
      ),
    );
  }
}
