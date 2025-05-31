import 'package:pocketbase/pocketbase.dart';

import '../models/vote.dart';
import './pocketbase_client.dart';

class VoteService {
  Future<Vote?> getVote(String novelId) async {
    try {
      final pb = await getPocketBaseInstance();
      final userId = pb.authStore.model!.id;
      final vote = await pb.collection('vote').getFullList(
            filter: "user ?~'$userId' && novel ?~ '$novelId'",
          );
          if(vote.isEmpty){
            return null;
          }
      return Vote.fromJson(vote.first.toJson());
    } catch (error) {
      print('Error getting vote: $error');
      throw Exception('An error occurred');
    }
  }

  Future<void> addVote(String novelId, int value) async {
    try {
      final pb = await getPocketBaseInstance();
      final userId = pb.authStore.model!.id;
      await pb.collection('vote').create( body: {
        'user': userId,
        'novel': novelId,
        'value': value,
      });
    } catch (error) {
      print('Error adding vote: $error');
      throw Exception('An error occurred while adding the vote');
    }
  }

  Future<void> updateVote(String voteId, int value) async {
    try {
      final pb = await getPocketBaseInstance();
      await pb.collection('vote').update(voteId, body: {
        'value': value,
      });
    } catch (error) {
      print('Error updating vote: $error');
      throw Exception('An error occurred while updating the vote');
    }
  }

  Future<void> deleteVote(String voteId) async {
    try {
      final pb = await getPocketBaseInstance();
      await pb.collection('vote').delete(voteId);
    } catch (error) {
      print('Error deleting vote: $error');
      throw Exception('An error occurred while deleting the vote');
    }
  }
}

