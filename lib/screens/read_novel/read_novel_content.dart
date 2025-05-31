import 'package:flutter/material.dart';
import '../../models/chapter.dart';

class NovelContent extends StatefulWidget {
  final double fontSize;
  final String selectedFont;
  final ThemeData currentTheme;
  final Chapter chapter;
  final ScrollController scrollController;
  final int commentCount;
  final bool iscommentsLoading;
  final double valuevotes;

  const NovelContent({
    super.key,
    required this.fontSize,
    required this.selectedFont,
    required this.currentTheme,
    required this.chapter,
    required this.scrollController,
    required this.commentCount,
    required this.iscommentsLoading,
    required this.valuevotes,
  });

  @override
  _NovelContentState createState() => _NovelContentState();
}

class _NovelContentState extends State<NovelContent> {
  bool hasExtraSpace = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contentHeight = context.size?.height ?? 0;
      final maxHeight = MediaQuery.of(context).size.height;


      if (contentHeight < maxHeight) {
        setState(() {
          hasExtraSpace = true;
        });
      } else {
        setState(() {
          hasExtraSpace = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> paragraphs = widget.chapter.content.split('\n');

    return Container(
      color: widget.currentTheme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: widget.scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  widget.chapter.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: widget.fontSize + 6,
                    fontWeight: FontWeight.bold,
                    fontFamily: widget.selectedFont,
                    color: widget.currentTheme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.valuevotes.toString(),
                        style: TextStyle(
                          fontSize: widget.fontSize - 2,
                          fontWeight: FontWeight.bold,
                          fontFamily: widget.selectedFont,
                          color: widget.currentTheme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.remove_red_eye,
                          color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.chapter.count_view.toString(),
                        style: TextStyle(
                          fontSize: widget.fontSize - 2,
                          fontFamily: widget.selectedFont,
                          color: widget.currentTheme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.comment, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      widget.iscommentsLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.grey,
                                ),
                              ),
                            )
                          :
                      Text(
                        widget.commentCount.toString(),
                        style: TextStyle(
                          fontSize: widget.fontSize - 2,
                          fontFamily: widget.selectedFont,
                          color: widget.currentTheme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ...paragraphs.map((paragraph) {
                  if (paragraph.trim().isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: [
                      Text(
                        paragraph.trim(),
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: widget.fontSize,
                          fontFamily: widget.selectedFont,
                          height: 1.5,
                          color: widget.currentTheme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
                hasExtraSpace
                    ? SizedBox(
                        height: constraints.maxHeight -
                            150)
                    : const SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }
}
