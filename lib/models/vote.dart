class Vote {
  String? id;
  String userId;
  String novelId;
  int value;

  Vote({
    required this.id,
    required this.userId,
    required this.novelId,
    required this.value,
  });

  Vote copyWith({
    String? id,
    String? userId,
    String? novelId,
    int? value,
  }) {
    return Vote( 
      id: id ?? this.id,
      userId: userId ?? this.userId,
      novelId: novelId ?? this.novelId,
      value: value ?? this.value,
    );
  }


factory Vote.fromJson(Map<String, dynamic> json) {
  print(json);
    return Vote(
      id: json['id'] as String,
      userId: json['user'] as String,
      novelId: json['novel'] as String,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'novel': novelId,
      'value': value,
    };
  }
}