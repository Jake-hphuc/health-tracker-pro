class HealthTip {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String category; // 'Dinh dưỡng', 'Vận động', 'Giấc ngủ', 'Sức khỏe'
  final String author;
  final String iconEmoji;
  final String readTimeMinutes;

  const HealthTip({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.author,
    required this.iconEmoji,
    required this.readTimeMinutes,
  });
}
