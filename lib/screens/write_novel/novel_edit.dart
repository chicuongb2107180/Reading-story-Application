import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/category.dart';
import '../../models/novel.dart';
import '../../models/chapter.dart';
import '../../util.dart';
import 'select_category_dialog.dart';
import 'novelchapter_edit.dart';
import '../../manager/category_manager.dart';
import '../../manager/novels_manager.dart';
import '../../manager/chapter_manager.dart';

class EditNovelScreen extends StatefulWidget {
  final Novel? novel;

  EditNovelScreen({Key? key, this.novel}) : super(key: key);

  @override
  _EditNovelScreenState createState() => _EditNovelScreenState();
}

class _EditNovelScreenState extends State<EditNovelScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Category> categories = [];
  List<Category> selectedCategories = [];
  List<Chapter> chapters = [];
  File? _coverImage;
  final ImagePickerHelper _imagePickerHelper = ImagePickerHelper();
  bool isLoading = false;
  bool isCompleted = false;
  bool isRepost = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => isLoading = true);
    await _fetchCategories();
    await _fetchChapters();
    if (widget.novel != null) {
      _titleController.text = widget.novel!.novelName;
      _descriptionController.text = widget.novel!.description;
      selectedCategories = widget.novel!.categories ?? [];
      isCompleted = widget.novel!.isCompleted;
      isRepost = widget.novel!.isrepost;
    }
    setState(() => isLoading = false);
  }

  Future<void> _fetchCategories() async {
    await Provider.of<CategoryManager>(context, listen: false).fetchCategories();
    setState(() {
      categories = Provider.of<CategoryManager>(context, listen: false).categories;
    });
  }

  Future<void> _fetchChapters() async {
    if (widget.novel != null) {
      await context.read<ChapterManager>().fetchChapters(widget.novel!.id!);
      setState(() {
        chapters = context.read<ChapterManager>().chapters;
      });
    }
  }

  void _selectImage() async {
    File? image = await _imagePickerHelper.pickImage(context);
    if (image != null) {
      setState(() {
        _coverImage = image;
      });
    }
  }

  void _showGenrePicker() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          title: 'Chọn Thể Loại',
          items: categories.map((category) => category.name).toList(),
          selectedItems: selectedCategories.map((category) => category.name).toList(),
          onConfirm: (selected) {
            setState(() {
              selectedCategories = categories
                  .where((category) => selected.contains(category.name))
                  .toList();
            });
          },
        );
      },
    );
  }

  Future<void> _saveNovel() async {
    setState(() => isLoading = true);
    final novelsManager = Provider.of<NovelsManager>(context, listen: false);

    final newNovel = Novel(
      id: widget.novel?.id,
      novelName: _titleController.text,
      description: _descriptionController.text,
      author: widget.novel?.author,
      imageCover: _coverImage,
      categories: selectedCategories,
      isCompleted: isCompleted,
      isrepost: isRepost,
    );

    if (widget.novel != null) {
      await novelsManager.updateNovel(newNovel);
    } else {
      await novelsManager.createNovel(newNovel);
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.novel == null ? 'Thêm Truyện Mới' : 'Chỉnh Sửa Truyện'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const MainBottomNavigationBar(index: 3),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _saveNovel();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MainBottomNavigationBar(index: 3),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(widget.novel != null
                        ? 'Truyện đã được cập nhật.'
                        : 'Truyện đã được thêm mới.')),
              );
            },
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _selectImage,
                      child: _coverImage == null
                          ? Container(
                              width: 100,
                              height: 150,
                              color: Colors.grey[300],
                              child: widget.novel?.urlImageCover != null
                                  ? Image.network(widget.novel!.urlImageCover)
                                  : const Center(
                                      child: Text(
                                        'Sửa Bìa Truyện',
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    ),
                            )
                          : Image.file(
                              _coverImage!,
                              width: 100,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildTextField('Tiêu Đề Truyện', _titleController, hintText: 'Nhập tiêu đề truyện ở đây'),
                  const SizedBox(height: 20),
                  buildTextField('Mô Tả Truyện', _descriptionController, hintText: 'Nhập mô tả của truyện', maxLines: null),
                  const SizedBox(height: 20),
                  const Divider(),
                  const Text('Thể Loại Truyện', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _showGenrePicker,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        selectedCategories.isNotEmpty
                            ? selectedCategories.map((category) => category.name).join(', ')
                            : 'Chọn Thể Loại',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Loại Truyện', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  DropdownButton<bool>(
                    value: isRepost,
                    onChanged: (bool? newValue) {
                      setState(() {
                        isRepost = newValue!;
                      });
                    },
                    items: [
                      DropdownMenuItem(value: false, child: Text('Tự sáng tác')),
                      DropdownMenuItem(value: true, child: Text('Truyện đăng lại')),
                    ],
                  ),
                  if (isRepost)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        '⚠️ Truyện đăng lại vui lòng xin phép tác giả và ghi rõ tác giả ở phần mô tả.',
                        style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Trạng Thái Hoàn Thành', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Switch(
                        value: isCompleted,
                        onChanged: (bool value) {
                          setState(() {
                            isCompleted = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  if (widget.novel != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Bảng Mục Lục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...chapters.map((chapter) => buildChapterItem(chapter)).toList(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WriteChapterScreen(novel: widget.novel!),
                              ),
                            );
                            await _fetchChapters();
                          },
                          child: const Text('+ Thêm Chương Mới', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {String? hintText, int? maxLines}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText ?? '',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.black),
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget buildChapterItem(Chapter chapter) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WriteChapterScreen(
              novel: widget.novel!,
              chapter: chapter,
            ),
          ),
        );
        await _fetchChapters();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(chapter.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          Text(chapter.status == 'published' ? 'Đã Đăng' : 'Bản Thảo', style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const Divider(),
        ],
      ),
    );
  }
}
