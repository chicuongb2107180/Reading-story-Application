
import '../models/report.dart';
import 'pocketbase_client.dart';

class ReportService {
  Future<List<Report>> fetchReports() async {
    final List<Report> reports = [];

    try {
      final pb = await getPocketBaseInstance();

      final reportModels = await pb.collection('report_view').getFullList(
            sort: '-report_created',
            expand: 'chapter_id,novel_id,reporter_id,novel_id.author',
          );

      for (final model in reportModels) {
        print("Model: $model");
        final json = model.toJson();
        reports.add(Report.fromJson(json));
      }
    } catch (e) {
      // Use a logging framework instead of print
      print("Error fetching reports: $e");
    }
    return reports;
  }

  Future<void> deleteReport(String reportId) async {
    try {
      final pb = await getPocketBaseInstance();
      await pb.collection('report').delete(reportId);
    } catch (e) {
      print("Delete report error: $e");
    }
  }

  Future<void> updateReportStatus(String reportId, String newStatus) async {
    try {
      final pb = await getPocketBaseInstance();
      await pb.collection('report').update(reportId, body: {
        'status': newStatus,
      });
    } catch (e) {
      print("Update report status error: $e");
    }
  }

  Future<bool> addReport(Report report) async {
    try {
      final pb = await getPocketBaseInstance();
      final reportModel = await pb.collection('report').create(body: report.toJson());
      return true;
    } catch (e) {
      print("Add report error: $e");
      return false;
    }
  }
}

