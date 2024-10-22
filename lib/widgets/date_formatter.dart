String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'À l\'instant';
  } else if (difference.inMinutes < 60) {
    return 'Il y a ${difference.inMinutes} min';
  } else if (difference.inHours < 24) {
    return 'Il y a ${difference.inHours} h';
  } else if (difference.inDays < 7) {
    return 'Il y a ${difference.inDays} j';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return 'Il y a $weeks sem';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return 'Il y a $months mois';
  } else {
    final years = (difference.inDays / 365).floor();
    return 'Il y a $years an${years > 1 ? 's' : ''}';
  }
}
