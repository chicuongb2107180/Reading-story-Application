import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/report_manager.dart';
import '../util/helper.dart';
import 'report_detail_screen.dart';

class ReportManagementScreen extends StatelessWidget {
  static const routeName = '/report-management';

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    context.read<ReportManager>().fetchReports();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý tố cáo'),
      ),
      body: Column(
        children: [
          // Ô tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm truyện hoặc người báo cáo...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  context.read<ReportManager>().searchQuery = value;
                },
              ),
            ),
          ),

          // Bộ lọc trạng thái
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                const Text('Lọc trạng thái:'),
                const SizedBox(width: 8),
                Consumer<ReportManager>(
                  builder: (context, manager, _) => DropdownButton<String>(
                    value: manager.filterStatus,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                      DropdownMenuItem(
                          value: 'pending', child: Text('Chưa phê duyệt')),
                      DropdownMenuItem(value: 'reject', child: Text('Từ chối')),
                      DropdownMenuItem(
                          value: 'approve', child: Text('Vi phạm')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        manager.filterStatus = value;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Danh sách báo cáo
          Expanded(
            child: Consumer<ReportManager>(
              builder: (context, reportManager, _) {
                final reports = reportManager.filteredReports;

                if (reports.isEmpty) {
                  return const Center(child: Text('Không có báo cáo phù hợp.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(6),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];

                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Xác nhận xoá'),
                            content: Text(
                                'Bạn có chắc muốn xoá báo cáo về "${report.novelName}" không?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Huỷ'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  reportManager.deleteReport(report.id!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Đã xoá báo cáo về "${report.novelName}"')),
                                  );
                                },
                                child: const Text('Xoá',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportDetailScreen(report: report),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  report.url_image_novelcover!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 48),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      report.novelName!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        'Người báo cáo: ${report.reporterName}',
                                        style: const TextStyle(fontSize: 12)),
                                    if (report.chapterTitle != null &&
                                        report.chapterTitle!.isNotEmpty)
                                      Text(
                                          'Chương vi phạm: ${report.chapterTitle}',
                                          style: const TextStyle(fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text.rich(
                                      TextSpan(
                                        text: 'Trạng thái: ',
                                        style: const TextStyle(fontSize: 12),
                                        children: [
                                          TextSpan(
                                            text: Helper.statusText(
                                                report.status),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Helper.statusColor(
                                                  report.status),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Báo cáo: ${Helper.formatRelativeTime(report.createdAt)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
