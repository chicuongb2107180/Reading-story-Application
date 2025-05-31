import 'package:flutter/foundation.dart';

import '../../models/report.dart';
import '../../services/report_service.dart';

class ReportManager with ChangeNotifier {
  final ReportService _reportService = ReportService();

  List<Report> _reports = [];
  List<Report> get reports => _reports;

  String _filterStatus = 'all';
  String _searchQuery = '';
  String get filterStatus => _filterStatus;

  set filterStatus(String value) {
    _filterStatus = value;
    notifyListeners();
  }

  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  List<Report> get filteredReports {
    return _reports.where((report) {
      final matchStatus =
          _filterStatus == 'all' || report.status == _filterStatus;
      final query = _searchQuery.toLowerCase();
      final matchQuery =
          report.novelName?.toLowerCase().contains(query) == true ||
              report.reporterName?.toLowerCase().contains(query) == true;
      return matchStatus && matchQuery;
    }).toList();
  }

  Future<void> fetchReports() async {
    _reports = await _reportService.fetchReports();
    notifyListeners();
  }

  Report? getReportById(String id) {
    return _reports.firstWhere((report) => report.id == id);
  }

  Future<void> updateReportStatus(String reportId, String newStatus) async {
    await _reportService.updateReportStatus(reportId, newStatus);
    final index = _reports.indexWhere((report) => report.id == reportId);
    if (index != -1) {
      _reports[index] = _reports[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  Future<void> deleteReport(String reportId) async {
    await _reportService.deleteReport(reportId);
    _reports.removeWhere((report) => report.id == reportId);
    notifyListeners();
  }

  Future<bool> addReport(Report report) async {
    final success = await _reportService.addReport(report);
    if (success) {
      _reports.add(report);
      notifyListeners();
      return true;
    }
    return false;
  }
}
