import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/user_manager.dart';
import '../../models/user.dart';

class UserAccountsScreen extends StatefulWidget {
  static const routeName = '/user-accounts';

  const UserAccountsScreen({super.key});

  @override
  State<UserAccountsScreen> createState() => _UserAccountsScreenState();
}

class _UserAccountsScreenState extends State<UserAccountsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    await context.read<UserManager>().fetchUsers();
    setState(() {
      _isLoading = false;
    });
  }

  void _showRoleDialog(BuildContext context, User user) {
    final userManager = context.read<UserManager>();
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cập nhật quyền cho ${user.username}'),
          content: DropdownButtonFormField<String>(
            value: selectedRole,
            decoration: const InputDecoration(labelText: 'Chọn quyền'),
            items: const [
              DropdownMenuItem(value: 'user', child: Text('User')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'banned', child: Text('Bị cấm')),
            ],
            onChanged: (value) {
              if (value != null) {
                selectedRole = value;
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                await userManager.updateUserRole(user.id!, selectedRole);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cập nhật quyền thành công')),
                );
              },
              child: const Text('Cập nhật'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userManager = context.watch<UserManager>();
    final users = userManager.users;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý tài khoản'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(child: Text('Không có người dùng nào'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: users.length,
                  itemBuilder: (ctx, index) {
                    final user = users[index];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.url_avatar != null &&
                                  user.url_avatar!.isNotEmpty
                              ? NetworkImage(user.url_avatar!)
                              : const AssetImage(
                                      'assets/images/default_avatar.png')
                                  as ImageProvider,
                          radius: 25,
                        ),
                        title: Text(
                          user.name ?? 'Chưa đặt tên',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Username: ${user.username}'),
                            Text('Email: ${user.email ?? 'Không có'}'),
                            Text('Quyền: ${user.role}'),
                            if (user.role == 'banned')
                              const Text(
                                'Tài khoản đã bị cấm',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () => _showRoleDialog(context, user),
                          tooltip: 'Cập nhật quyền',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
