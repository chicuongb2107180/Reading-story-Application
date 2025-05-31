import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

String formatDateTimeForPocketBase(DateTime dateTime) {
  final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss.SSS'Z'");
  return formatter.format(dateTime.toUtc());
}

class Helper {
  static String formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    } else {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
  }

static String formatRelativeTime(DateTime createdAt) {
  final now = DateTime.now();
  final difference = now.difference(createdAt);

  if (difference.inMinutes < 1) {
    return 'Vừa xong';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} phút trước';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} giờ trước';
  } else if (difference.inDays == 1) {
    return 'Hôm qua';
  } else if (difference.inDays <= 7) {
    return '${difference.inDays} ngày trước';
  } else {
    return DateFormat('dd/MM/yyyy').format(createdAt);
  }
}
static String statusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chưa phê duyệt';
      case 'reject':
        return 'Từ chối';
      case 'approve':
        return 'Vi phạm';
      default:
        return 'Không xác định';
    }
  }

  static Color statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'reject':
        return Colors.red;
      case 'approve':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }


}

