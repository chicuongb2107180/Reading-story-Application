import 'package:flutter/material.dart';
import 'chapter_list.dart';
import '../../models/novel.dart';
import '../../models/chapter.dart';

class ShowChapterListDialog {
  final BuildContext context;
  final Novel novel;
  final Chapter chapter;

  ShowChapterListDialog({
    required this.context,
    required this.novel,
    required this.chapter,
  });

  void show() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ChapterList',
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return const SizedBox.shrink();
      },
      barrierColor: Colors.black54.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 500),
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        final CurvedAnimation curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return AnimatedBuilder(
          animation: curvedAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: Tween<double>(
                    begin: -MediaQuery.of(context)
                        .size
                        .width, // Start off-screen on the right
                    end: 0, // Stick to the right edge of the screen
                  ).animate(curvedAnimation).value,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: SafeArea(
                    child: ChapterList(novel: novel),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}


void showChapterListDialog(BuildContext context, Novel novel,Chapter chapter) {

  ShowChapterListDialog(
    context: context,
    novel: novel,
    chapter: chapter,
  ).show();
}
