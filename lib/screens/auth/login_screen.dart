import 'dart:developer' as developer show log;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'show_error.dart';
import 'register_screen.dart';
import '../../manager/auth_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final Map<String, String> _authData = {
    'username': '',
    'password': '',
  };
  final _isSubmitting = ValueNotifier<bool>(false);
  final _passwordController = TextEditingController();
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    _isSubmitting.value = true;
    try {
      await context.read<AuthManager>().login(
            _authData['username']!,
            _authData['password']!,
          );
    } catch (error) {
      developer.log('$error');
      if (mounted) {
      String errorMessage = 'Sai tên đăng nhập hoặc mật khẩu';
        if (error.toString().contains('bị cấm')) {
          errorMessage = 'Tài khoản của bạn đã bị cấm';
        }
        showErrorDialog(context, errorMessage);

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Image.asset(
              'assets/loginbackground.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5),
            ),
            // Nội dung phần đăng nhập
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                            'Đăng nhập',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Form(
                              key: _formKey,
                              child: SingleChildScrollView(
                                  child: Column(children: [
                                const SizedBox(height: 16),
                                _buildUsernameTextField(),
                                const SizedBox(height: 16),
                                _buildPasswordTextField(),
                                const SizedBox(height: 16),
                                ValueListenableBuilder<bool>(
                                    valueListenable: _isSubmitting,
                                    builder: (context, isSubmitting, child) {
                                      return ElevatedButton(
                                        onPressed: () {
                                          _submit();
                                        },
                                        child: const Text('Đăng nhập'),
                                      );
                                    }),
                              ]))),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              // Xử lý sự kiện Quên mật khẩu
                            },
                            child: const Text(
                              'Quên mật khẩu?',
                              style: TextStyle(color: Colors.deepPurple),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Bạn chưa có tài khoản? "),
                              GestureDetector(
                                onTap: () {
                                  // Điều hướng đến màn hình đăng ký
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterScreen()),
                                  );
                                },
                                child: const Text(
                                  'Đăng ký',
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
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameTextField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Tên đăng nhập',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Tên đăng nhập không được để trống';
        }
        return null;
      },
      onSaved: (value) {
        _authData['username'] = value!;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Mật khẩu',
        border: OutlineInputBorder(),
      ),
      obscureText: true,
      controller: _passwordController,
      validator: (value) {
        if (value!.isEmpty || value.length < 5) {
          return 'Mật khẩu quá ngắn';
        }
        return null;
      },
      onSaved: (value) {
        _authData['password'] = value!;
      },
    );
  }
}
