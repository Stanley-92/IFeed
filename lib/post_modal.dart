// lib/post_model.dart

enum MediaType { image, video }

class PostMedia {
  final MediaType type;
  final String url;

  const PostMedia._(this.type, this.url);
  factory PostMedia.image(String url) => PostMedia._(MediaType.image, url);
  factory PostMedia.video(String url) => PostMedia._(MediaType.video, url);
}

class Comment {
  final String id;
  final String userName;
  final String avatar;
  final String time;
  final String text;
  final bool isReply;
  final List<Comment> replies;
   final List<PostMedia> media;  
  bool liked;
  bool expanded;

  Comment({
    required this.id,
    required this.userName,
    required this.avatar,
    required this.time,
    required this.text,
    this.isReply = false,
    List<Comment>? replies,
    this.liked = false,
    this.expanded = true,
    this.media = const <PostMedia>[],
  }) : replies = replies ?? [];
  
}

class Post {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String timeText;
  final String caption;
  final List<PostMedia> media;
  List<Comment> comments;

  Post({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.timeText,
    required this.caption,
    required this.media,
    List<Comment>? comments,
  }) : comments = comments ?? [];
}
