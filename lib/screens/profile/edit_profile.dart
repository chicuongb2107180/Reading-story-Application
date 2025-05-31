import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../util.dart';
import '../../manager/auth_manager.dart';
import '../../models/user.dart';
import '../../main.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _introduceController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  File? _avatarImage;
  File? _coverImage;
  User? user;
  final ImagePickerHelper _imagePickerHelper = ImagePickerHelper();

  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  List<String> _genders = ['nam', 'nữ', 'không tiết lộ'];

  @override
  void initState() {
    super.initState();
    final authManager = context.read<AuthManager>();
    user = authManager.user;
    _displayNameController.text = user?.name ?? '';
    _usernameController.text = user?.username ?? '';
    _introduceController.text = user?.introduce ?? '';
    _emailController.text = user?.email ?? '';
    _selectedDateOfBirth = user?.DoB;
    _selectedGender = user?.gender;
    _avatarImage = user?.avatar;
    _coverImage = user?.cover;
  }

  void _selectAvatarImage() async {
    File? image = await _imagePickerHelper.pickImage(context);
    if (image != null) {
      setState(() {
        _avatarImage = image;
      });
    }
  }

  void _selectCoverImage() async {
    File? image = await _imagePickerHelper.pickImage(context);
    if (image != null) {
      setState(() {
        _coverImage = image;
      });
    }
  }

  void _selectDateOfBirth() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  void _selectGender(String? value) {
    setState(() {
      _selectedGender = value!;
    });
  }

  Future<void> _saveUserProfile() async {
    final authManager = context.read<AuthManager>();
    final updatedUser = user!.copyWith(
      name: _displayNameController.text,
      introduce: _introduceController.text,
      gender: _selectedGender,
      DoB: _selectedDateOfBirth,
      avatar: _avatarImage,
      cover: _coverImage,
    );
    await authManager.updateProfile(updatedUser);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cập nhật thông tin thành công!')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainBottomNavigationBar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chỉnh Thông Tin Cá Nhân',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const MainBottomNavigationBar(
                        index: 4,
                      )),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: _saveUserProfile,
            child: const Text(
              'Lưu',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: GestureDetector(
                onTap: _selectAvatarImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _avatarImage != null
                      ? FileImage(_avatarImage!)
                      : (user?.url_avatar != null &&
                              user!.url_avatar!.isNotEmpty
                          ? NetworkImage(user!.url_avatar!)
                          : null),
                  child: _avatarImage == null &&
                          (user?.url_avatar == null ||
                              user!.url_avatar!.isEmpty)
                      ? const Icon(Icons.person,
                          size: 50, color: Colors.black54)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 5),
            const Divider(),

            // Cover Image
            Center(
              child: GestureDetector(
                onTap: _selectCoverImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.grey[300],
                  child: _coverImage != null
                      ? Image.file(
                          _coverImage!,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      : (user?.url_cover != null && user!.url_cover!.isNotEmpty
                          ? Image.network(
                              user!.url_cover!,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                            )
                          : const Center(
                              child: Text(
                                'Sửa Ảnh Bìa',
                                style: TextStyle(color: Colors.black54),
                              ),
                            )),
                ),
              ),
            ),

            const SizedBox(height: 5),
            const Divider(),

            // Name
            buildTextField(
              'Tên',
              _displayNameController,
              hintText: user?.name ?? 'Chưa có tên',
            ),
            const SizedBox(height: 5),
            const Divider(),

            // Username
            buildTextField(
              'Tên Đăng Nhập',
              _usernameController,
              hintText: user?.username ?? 'trieuvi123',
              readOnly: true,
            ),
            const SizedBox(height: 5),
            const Divider(),

            // Email
            buildTextField(
              'Email',
              _emailController,
              hintText: user?.email ?? 'example@example.com',
              readOnly: true,
            ),
            const SizedBox(height: 5),
            const Divider(),

            // Introduction
            buildTextField(
              'Giới Thiệu Bản Thân',
              _introduceController,
              hintText: user?.introduce ?? 'Nhấn vào để nhập giới thiệu',
              maxLines: null,
            ),
            const SizedBox(height: 5),
            const Divider(),

            // Date of Birth
            const Text(
              'Ngày Sinh',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: _selectDateOfBirth,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _selectedDateOfBirth != null
                      ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                      : 'Chọn ngày sinh',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 5),
            const Divider(),

            // Gender
            const Text(
              'Giới Tính',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            DropdownButton<String>(
              value: _selectedGender,
              onChanged: _selectGender,
              items: _genders
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {String? hintText, int? maxLines, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: readOnly,
          enabled: !readOnly,
          decoration: InputDecoration(
            hintText: hintText ?? '',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
          ),
          maxLines: maxLines,
        ),
      ],
    );
  }
}
