// bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'vote_dialog.dart';

class BottomNavBar extends StatefulWidget {
  final bool isVisible;
  final VoidCallback showFontSettings;
  final VoidCallback showComment;
  final Function(int) onVote;
  final int initialVote;

  const BottomNavBar({
    super.key,
    required this.isVisible,
    required this.showFontSettings,
    required this.showComment,
    required this.onVote,
    required this.initialVote,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedStars = 0;

  @override
  void initState() {
    super.initState();
    _selectedStars = widget.initialVote;
  }

  void _handleVote(int stars) {
    setState(() {
      _selectedStars = stars;
    });
    widget.onVote(stars);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      bottom: widget.isVisible ? 0 : -80,
      left: 0,
      right: 0,
      child: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 83, 69, 69),
        selectedItemColor: const Color.fromARGB(255, 194, 139, 88),
        unselectedItemColor: const Color.fromARGB(255, 194, 139, 88),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 2) {
            widget.showFontSettings();
          }
          if (index == 1) {
            widget.showComment();
          }
          if (index == 0) {
            showDialog(
              context: context,
              builder: (context) {
                return VoteDialog(
                  initialStars: _selectedStars,
                  onVote: _handleVote,
                );
              },
            );
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: GestureDetector(
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return VoteDialog(
                      initialStars: _selectedStars,
                      onVote: _handleVote,
                    );
                  },
                );
              },
              child: Icon(
                Icons.star,
                color: _selectedStars > 0 ? Colors.amber : null,
              ),
            ),
            label: _selectedStars > 0 ? 'Voted' : 'Vote',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.comment),
            label: 'Comment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_format, size: 30),
            label: 'Aa',
          ),
        ],
      ),
    );
  }
}
