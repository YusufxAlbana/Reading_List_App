class ReadingItem {
  String id;
  String title;
  bool isRead;
  DateTime createdAt;
  List<String> tags;

  ReadingItem({
    required this.id,
    required this.title,
    this.isRead = false,
    DateTime? createdAt,
    List<String>? tags,
  })  : createdAt = createdAt ?? DateTime.now(),
        tags = tags ?? const [];

  factory ReadingItem.fromJson(Map<String, dynamic> json) {
    DateTime parsed;
    try {
      parsed = DateTime.parse(json['createdAt'] ?? '');
    } catch (_) {
      parsed = DateTime.now();
    }

    final rawTags = json['tags'];
    List<String> parsedTags = [];
    try {
      if (rawTags is List) {
        parsedTags = rawTags.map((e) => e.toString()).toList();
      } else if (rawTags is String) {
        parsedTags = rawTags
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {
      parsedTags = [];
    }

    return ReadingItem(
      id: json['id'],
      title: json['title'],
      isRead: json['isRead'] ?? false,
      createdAt: parsed,
      tags: parsedTags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
    };
  }

  // Human friendly relative time, e.g. "1 day ago"
  String timeAgo() {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 30) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }

    final months = (diff.inDays / 30).floor();
    if (months < 12) return '$months month${months == 1 ? '' : 's'} ago';

    final years = (diff.inDays / 365).floor();
    return '$years year${years == 1 ? '' : 's'} ago';
  }
}