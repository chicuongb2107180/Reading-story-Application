import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../manager/auth_manager.dart';
import 'show_error.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String _selectedGender = 'nam';
  DateTime _selectedDate = DateTime(2000, 1, 1);
  final User _user = User(
    email: '',
    name: '',
    introduce: '',
    DoB: DateTime.now(),
    username: '',
    role: 'user',
    gender: 'nam',
  );
  final _isSubmitting = ValueNotifier<bool>(false);
  String _password = '';
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    _isSubmitting.value = true;
    try {
      await context.read<AuthManager>().signup(
            _user,
            _password,
          );
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: const Text('Đăng ký thành công, hãy kiểm tra email để kích hoạt tài khoản.'),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            )
          ],
        ),
      );
    } catch (error) {
      if (mounted) {
        showErrorDialog(context, 'username hoặc email đã tồn tại');
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // Hiển thị ngày mặc định
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _user.DoB = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Thêm SafeArea ở đây
        child: Stack(
          children: <Widget>[
            // Ảnh nền cuốn sách từ mạng
            Image.asset(
              'assets/loginbackground.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            // Lớp phủ đen để làm dịu ảnh nền
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5),
            ),
            // Nội dung phần đăng ký
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Đăng ký',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildnameTextField(),
                                  const SizedBox(height: 16),
                                  _buildUsernameTextField(),
                                  const SizedBox(height: 16),
                                  _buildEmailTextField(),
                                  const SizedBox(height: 16),
                                  _buildPasswordTextField(),
                                  const SizedBox(height: 16),
                                  _buildConfirmPasswordTextField(),
                                  const SizedBox(height: 16),
                                  _buildDateOfBirthField(context),
                                  const SizedBox(height: 16),
                                  _buildGenderField(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ValueListenableBuilder(
                              valueListenable: _isSubmitting,
                              builder: (context, isSubmitting, child) {
                                return ElevatedButton(
                                  onPressed: () {
                                    _submit();
                                  },
                                  child: const Text('Đăng ký'),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Bạn đã có tài khoản? "),
                                GestureDetector(
                                  onTap: () {
                                    // Điều hướng đến trang đăng nhập
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildnameTextField() {
    return TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Họ và tên',
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      ),
      onSaved: (value) {
        _user.name = value!;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Họ và tên không được để trống';
        }
        if (value.length < 6) {
          return 'Họ và tên phải có ít nhất 6 ký tự';
        }
        return null;
      },
    );
  }

  Widget _buildUsernameTextField() {
    return TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Tên đăng nhập',
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      ),
      onSaved: (value) {
        _user.username = value!;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Tên đăng nhập không được để trống';
        }
        if (value.length < 6) {
          return 'Tên đăng nhập phải có ít nhất 6 ký tự';
        }
        return null;
      },
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Email',
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      ),
      onSaved: (value) {
        _user.email = value!;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Email không được để trống';
        }
        if (!value.contains('@')) {
          return 'Email không hợp lệ';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Mật khẩu',
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      ),
      obscureText: true,
      controller: _passwordController,
      onSaved: (value) {
        _password = value!;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Mật khẩu không được để trống';
        }
        if (value.length < 6) {
          return 'Mật khẩu phải có ít nhất 6 ký tự';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Xác nhận mật khẩu',
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      ),
      obscureText: true,
      validator: (value) {
        if (value != _passwordController.text) {
          return 'Mật khẩu không khớp';
        }
        return null;
      },
    );
  }

  Widget _buildDateOfBirthField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ngày sinh:',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_today),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giới tính:',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
          ),
          child: DropdownButton<String>(
            value: _selectedGender,
            isExpanded: true,
            underline: const SizedBox(),
            items: <String>[
              'nam',
              'nữ',
              'không tiết lộ',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedGender = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }
}
