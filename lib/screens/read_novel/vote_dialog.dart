// vote_dialog.dart
import 'package:flutter/material.dart';

class VoteDialog extends StatefulWidget {
  final int initialStars; // Số sao ban đầu
  final ValueChanged<int> onVote; // Hàm callback khi người dùng vote

  const VoteDialog({
    super.key,
    required this.initialStars,
    required this.onVote,
  });

  @override
  State<VoteDialog> createState() => _VoteDialogState();
}

class _VoteDialogState extends State<VoteDialog> {
  int _selectedStars = 0;

  @override
  void initState() {
    super.initState();
    _selectedStars = widget.initialStars; // Gán giá trị ban đầu
  }

  void _clearVote() {
    setState(() {
      _selectedStars = 0;
    });
    widget.onVote(_selectedStars); // Gọi lại hàm callback với giá trị 0
    Navigator.of(context).pop(); // Đóng hộp thoại
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đánh giá truyện'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  Icons.star,
                  color: _selectedStars > index ? Colors.amber : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _selectedStars = index + 1;
                  });
                  widget.onVote(_selectedStars);
                  Navigator.of(context).pop();
                },
              );
            }),
          ),
          if (_selectedStars > 0)
            TextButton(
              onPressed: _clearVote, // Thực hiện xóa đánh giá
              child: const Text(
                'Xóa đánh giá',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
