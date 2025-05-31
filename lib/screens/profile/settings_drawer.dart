import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/auth_manager.dart';
import 'edit_profile.dart';

class SettingsDrawer extends StatelessWidget {
  final VoidCallback onClose;

  const SettingsDrawer({Key? key, required this.onClose}) : super(key: key);

  Future<void> _deleteAccount(BuildContext context) async {
    final authManager = context.read<AuthManager>();
    final user = authManager.user;

    if (user != null) {
      // Hiển thị hộp thoại xác nhận xóa tài khoản
      final confirmDelete = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Xác nhận xóa tài khoản'),
          content: const Text(
              'Bạn có chắc chắn muốn xóa tài khoản này? Hành động này không thể hoàn tác.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        ),
      );

      // Nếu người dùng xác nhận xóa
      if (confirmDelete == true) {
        await authManager.deleteAccount(user); // Xóa tài khoản
        await authManager.logout(); // Đăng xuất người dùng

        // Điều hướng về màn hình đăng nhập
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 2 / 3,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.grey[200],
            height: 60,
            child: const Center(
              child: Text(
                'Cài đặt',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Đổi thông tin cá nhân'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Đăng xuất'),
            onTap: () {
              context.read<AuthManager>().logout();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Xóa tài khoản'),
            onTap: () => _deleteAccount(context),
          ),
        ],
      ),
    );
  }
}
