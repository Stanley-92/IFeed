// comments_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// ───────── Public models you use from the feed ─────────
enum MediaType { image, video }

class PostMedia {
  final MediaType type;
  final String? url;   // network source
  final File? file;    // local source (picker)
  const PostMedia._(this.type, {this.url, this.file});

  // Network factories
  factory PostMedia.image(String url) => PostMedia._(MediaType.image, url: url);
  factory PostMedia.video(String url) => PostMedia._(MediaType.video, url: url);

  // Local factories
  factory PostMedia.imageFile(File file) => PostMedia._(MediaType.image, file: file);
  factory PostMedia.videoFile(File file) => PostMedia._(MediaType.video, file: file);

  bool get isLocal => file != null;
  String get key => isLocal ? file!.path : url!;
}

/// Public comment value object (used across pages)
class Comment {
  final String id;
  final String userName;
  final String avatar;
  final String time;
  final String text;
  final bool isReply;
  final List<Comment> replies;

  const Comment({
    required this.id,
    required this.userName,
    required this.avatar,
    required this.time,
    required this.text,
    this.isReply = false,
    this.replies = const [],
  });
}

/// ─────────────── CommentsPage ───────────────
class CommentsPage extends StatefulWidget {
  const CommentsPage({
    super.key,
    this.postAuthorName,
    this.postAuthorAvatar,
    this.postText,
    this.postTimeText,
    this.postMedia = const [],
    this.initialComments = const <Comment>[],
  });

  final String? postAuthorName;
  final String? postAuthorAvatar;
  final String? postText;     // caption (optional)
  final String? postTimeText; // e.g. "1h ago" (optional)
  final List<PostMedia> postMedia;
  final List<Comment> initialComments;

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final _scroll = ScrollController();
  final _input = TextEditingController();
  final _focus = FocusNode();

  // Internal tree we mutate in the UI
  final List<_CommentNode> _comments = [];
  _CommentNode? _replyTo;

  // Video controllers keyed by media key (url or file path)
  final Map<String, VideoPlayerController> _videoCtrls = {};
  final Map<String, Future<void>> _videoInits = {};

  @override
  void initState() {
    super.initState();

    // seed from public comments
    _comments.addAll(widget.initialComments.map(_CommentNode.fromPublic));

    // init videos (support local + network)
    for (final m in widget.postMedia.where((m) => m.type == MediaType.video)) {
      final ctrl = m.isLocal
          ? VideoPlayerController.file(m.file!)
          : VideoPlayerController.networkUrl(Uri.parse(m.url!));
      ctrl.setLooping(true);
      _videoCtrls[m.key] = ctrl;
      _videoInits[m.key] = ctrl.initialize();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _input.dispose();
    _focus.dispose();
    for (final c in _videoCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  // Convert current state to the public VO and pop
  void _popWithResult() {
    final result = _comments.map((n) => n.toPublic()).toList(growable: false);
    Navigator.pop<List<Comment>>(context, result);
  }

  void _startReply(_CommentNode c) {
    setState(() => _replyTo = c);
    _input
      ..clear()
      ..text = '@${c.userName} ';
    _focus.requestFocus();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;

    final node = _CommentNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'you',
      avatar: 'https://i.pravatar.cc/100?img=32',
      time: 'now',
      text: text,
      isReply: _replyTo != null,
    );

    setState(() {
      if (_replyTo == null) {
        _comments.add(node);
      } else {
        _replyTo!.replies.add(node);
      }
      _replyTo = null;
    });

    _input.clear();
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final authorAvatar = widget.postAuthorAvatar ?? 'https://i.pravatar.cc/100?img=68';
    final authorName = widget.postAuthorName ?? '';
    final postTime = widget.postTimeText ?? '';
    final hasCaption = (widget.postText != null && widget.postText!.trim().isNotEmpty);
    final hasMedia = widget.postMedia.isNotEmpty;

    return WillPopScope(
      onWillPop: () async {
        _popWithResult();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          title: const Text('Replies'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _popWithResult, // return comments when leaving
          ),
        ),
        body: Column(
          children: [
            // ─── Post header ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(authorAvatar),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  if (authorName.isNotEmpty || postTime.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (authorName.isNotEmpty)
                          Text(authorName,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        if (authorName.isNotEmpty && postTime.isNotEmpty)
                          const SizedBox(width: 6),
                        if (postTime.isNotEmpty)
                          Text(postTime,
                              style: const TextStyle(fontSize: 11, color: Colors.black45)),
                      ],
                    ),
                  ],
                  if (hasCaption) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 560),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEAEAEA)),
                      ),
                      child: SelectableText(
                        widget.postText!,
                        style: const TextStyle(fontSize: 14, height: 1.35),
                      ),
                    ),
                  ],
                  if (hasMedia) ...[
                    const SizedBox(height: 10),
                    _MediaGallery(
                      media: widget.postMedia,
                      videoCtrls: _videoCtrls,
                      videoInits: _videoInits,
                    ),
                  ],
                ],
              ),
            ),

            // ─── Comments list ───
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  if (_comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'No comments yet. Be the first to reply!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ..._comments.map(
                    (c) => _CommentTile(
                      comment: c,
                      onReply: _startReply,
                      onLikeToggle: () => setState(() => c.liked = !c.liked),
                      onToggleCollapse: () =>
                          setState(() => c.expanded = !c.expanded),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Input bar ───
            Container(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottom),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=32'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _input,
                      focusNode: _focus,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: _replyTo == null ? 'Write a reply…' : 'Replying…',
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        suffixIcon: _replyTo == null
                            ? null
                            : IconButton(
                                tooltip: 'Cancel reply',
                                onPressed: () => setState(() => _replyTo = null),
                                icon: const Icon(Icons.close, size: 18),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _send, child: const Icon(Icons.send, size: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ───────── Media gallery helpers ─────────
class _MediaGallery extends StatelessWidget {
  const _MediaGallery({
    required this.media,
    required this.videoCtrls,
    required this.videoInits,
  });

  final List<PostMedia> media;
  final Map<String, VideoPlayerController> videoCtrls;
  final Map<String, Future<void>> videoInits;

  @override
  Widget build(BuildContext context) {
    if (media.length == 1) return _mediaTile(media.first);

    final crossCount = media.length > 4 ? 3 : 2;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: media.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemBuilder: (context, i) => _mediaTile(media[i]),
    );
  }

  Widget _mediaTile(PostMedia m) {
    final r = BorderRadius.circular(12);

    if (m.type == MediaType.image) {
      return ClipRRect(
        borderRadius: r,
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: m.isLocal
              ? Image.file(m.file!, fit: BoxFit.cover)
              : Image.network(m.url!, fit: BoxFit.cover),
        ),
      );
    }

    final ctrl = videoCtrls[m.key]!;
    final init = videoInits[m.key]!;
    return ClipRRect(
      borderRadius: r,
      child: FutureBuilder(
        future: init,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const _VideoLoading();
          }
          return Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: ctrl.value.aspectRatio == 0 ? 16 / 9 : ctrl.value.aspectRatio,
                child: VideoPlayer(ctrl),
              ),
              _PlayPauseOverlay(ctrl: ctrl),
            ],
          );
        },
      ),
    );
  }
}

class _VideoLoading extends StatelessWidget {
  const _VideoLoading();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      child: const Center(
        child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}

class _PlayPauseOverlay extends StatefulWidget {
  const _PlayPauseOverlay({required this.ctrl});
  final VideoPlayerController ctrl;
  @override
  State<_PlayPauseOverlay> createState() => _PlayPauseOverlayState();
}

class _PlayPauseOverlayState extends State<_PlayPauseOverlay> {
  bool _show = true;
  void _toggle() async {
    if (widget.ctrl.value.isPlaying) {
      await widget.ctrl.pause();
    } else {
      await widget.ctrl.play();
    }
    setState(() => _show = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _show = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedOpacity(
        opacity: _show ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: Container(
          color: Colors.black26,
          child: Icon(
            widget.ctrl.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
            size: 56,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// ───────── Internal node + mapping helpers ─────────
class _CommentNode {
  final String id;
  final String userName;
  final String avatar;
  final String time;
  final String text;
  final bool isReply;
  final List<_CommentNode> replies;
  bool liked;
  bool expanded;

  _CommentNode({
    required this.id,
    required this.userName,
    required this.avatar,
    required this.time,
    required this.text,
    this.isReply = false,
    List<_CommentNode>? replies,
    this.liked = false,
    this.expanded = true,
  }) : replies = replies ?? [];

  factory _CommentNode.fromPublic(Comment c) => _CommentNode(
        id: c.id,
        userName: c.userName,
        avatar: c.avatar,
        time: c.time,
        text: c.text,
        isReply: c.isReply,
        replies: c.replies.map(_CommentNode.fromPublic).toList(),
      );

  Comment toPublic() => Comment(
        id: id,
        userName: userName,
        avatar: avatar,
        time: time,
        text: text,
        isReply: isReply,
        replies: replies.map((r) => r.toPublic()).toList(growable: false),
      );
}

class _CommentTile extends StatelessWidget {
  final _CommentNode comment;
  final void Function(_CommentNode) onReply;
  final VoidCallback onLikeToggle;
  final VoidCallback onToggleCollapse;

  const _CommentTile({
    required this.comment,
    required this.onReply,
    required this.onLikeToggle,
    required this.onToggleCollapse,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leftPad = comment.isReply ? 32.0 : 0.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(leftPad, 10, 0, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 14, backgroundImage: NetworkImage(comment.avatar)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
                        children: [
                          TextSpan(text: comment.userName, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const TextSpan(text: '  '),
                          TextSpan(text: comment.time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(comment.text),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(comment.liked ? Icons.favorite : Icons.favorite_border,
                              size: 20, color: comment.liked ? Colors.red : null),
                          onPressed: onLikeToggle,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.reply_outlined, size: 20),
                          onPressed: () => onReply(comment),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.replies.isNotEmpty && !comment.expanded)
            Padding(
              padding: EdgeInsets.only(left: leftPad + 46 - leftPad, top: 4),
              child: TextButton(
                onPressed: onToggleCollapse,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('Show ${comment.replies.length} replies…'),
              ),
            ),
          if (comment.expanded)
            ...comment.replies.map(
              (r) => _CommentTile(
                comment: r,
                onReply: onReply,
                onLikeToggle: () {},
                onToggleCollapse: () {},
              ),
            ),
        ],
      ),
    );
  }
}
