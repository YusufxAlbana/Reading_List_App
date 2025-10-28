class ReadingItem {
  String id;
  String title;
  bool isRead;

  ReadingItem({
    required this.id,
    required this.title,
    this.isRead = false,
  });

  factory ReadingItem.fromJson(Map<String, dynamic> json) {
    return ReadingItem(
      id: json['id'],
      title: json['title'],
      isRead: json['isRead'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isRead': isRead,
    };
  }
}
