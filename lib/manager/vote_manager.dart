import 'package:flutter/material.dart';

import '../models/vote.dart';
import '../services/vote_service.dart';

class VoteManager with ChangeNotifier {
  final VoteService _voteService = VoteService();

  Vote? _vote;

  Vote? get vote => _vote;

  Future<void> fetchVote(String novelId) async {
    _vote = await _voteService.getVote(novelId);
    notifyListeners();
  }

  Future<void> addVote(String novelId, int value) async {
    await _voteService.addVote(novelId, value);
    await fetchVote(novelId); // Refresh vote data
  }

  Future<void> updateVote(int value) async {
    if (_vote != null) {
      await _voteService.updateVote(_vote!.id!, value);
      _vote = _vote!.copyWith(value: value);
      notifyListeners();
    }
  }

  Future<void> deleteVote(String novelId) async {
    if (_vote != null) {
      await _voteService.deleteVote(_vote!.id!);
      _vote = null;
      notifyListeners();
    }
  }
}
