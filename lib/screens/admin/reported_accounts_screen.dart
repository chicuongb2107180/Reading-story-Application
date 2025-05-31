import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/user_manager.dart';
import '../../models/user.dart';

class ReportedAccountsScreen extends StatefulWidget {
  static const routeName = '/reported-accounts';

  @override
  _ReportedAccountsScreenState createState() => _ReportedAccountsScreenState();
}

class _ReportedAccountsScreenState extends State<ReportedAccountsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserManager>().fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tài khoản bị tố cáo'),
      ),
      body: Consumer<UserManager>(
        builder: (context, userManager, child) {
          // Lọc các tài khoản có số lần vi phạm lớn hơn 0
          final users =
              userManager.users.where((user) => user.violated > 0).toList();

          if (users.isEmpty) {
            return const Center(child: Text('Không có tài khoản bị tố cáo.'));
          }

          return ListView.builder(
            itemCount: users.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.url_avatar!),
                    radius: 24,
                  ),
                  title: Text(user.username),
                  subtitle: Text('Số lần vi phạm: ${user.violated}'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditDialog(user);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

void _showEditDialog(User user) {
    final TextEditingController _controller =
        TextEditingController(text: user.violated.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hiệu chỉnh số lần vi phạm'),
        content: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Số lần vi phạm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () async {
              final newViolatedCount = int.tryParse(_controller.text);
              if (newViolatedCount != null) {
                final userManager = context.read<UserManager>();

                // Gọi hàm cập nhật vào database
                await userManager.updateViolated(user.id!, newViolatedCount);

                // Cập nhật local và refresh UI
                user.violated = newViolatedCount;
                userManager.notifyListeners();

                Navigator.pop(context);

                // Hiển thị thông báo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cập nhật thành công!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

}
