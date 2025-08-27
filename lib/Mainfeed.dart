// mainfeed.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/gg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:iconify_flutter/icons/uil.dart';

import 'comments_page.dart' as reply; // alias the comments page models/widgets
import 'listcontact.dart' as lc;       // lc.ChatListScreen
import 'profile.dart' as profile;      // profile.ProfileUserScreen

const String defaultAvatarAsset = 'assets/images/default_avatar.png';

void main() => runApp(const MaterialApp(home: MainfeedScreen()));

/// ======================= MAIN FEED =======================
class MainfeedScreen extends StatefulWidget {
  const MainfeedScreen({super.key});
  @override
  State<MainfeedScreen> createState() => _MainfeedScreenState();
}

class _MainfeedScreenState extends State<MainfeedScreen> {
  final List<_Post> _feedPosts = []; // start empty

  Future<void> _handleAddPost(BuildContext context) async {
    final Post? newPost = await Navigator.push<Post>(
      context,
      MaterialPageRoute(builder: (_) => const UploadPostPage()),
    );
    if (newPost == null) return;

    final _Post converted = _Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: newPost.userName,
      avatar: "", // empty -> show default asset in feed
      time: "just now",
      caption: newPost.text,
      aspect: CardAspect.auto,
      media: newPost.media
          .map((m) => _FeedMedia(
                path: m.file.path,
                type: MediaType.image == m.type ? MediaType.image : MediaType.video,
                isNetwork: false, // picker results are local files
              ))
          .toList(),
      comments: <reply.Comment>[], // start with no comments
    );

    setState(() => _feedPosts.insert(0, converted));
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    final v = (count / 1000).toStringAsFixed(1);
    return v.endsWith('.0') ? '${v.substring(0, v.length - 2)}K' : '${v}K';
  }

  /// Always provide a network image URL for the reply screen header
  String _replyHeaderAvatar(String avatar) {
    if (avatar.isNotEmpty && avatar.startsWith('http')) return avatar;
    // fallback to a network avatar so CommentsPage can render it
    return 'https://i.pravatar.cc/150?img=68';
  }

  /// Convert feed media -> reply screen media (supports local + network)
  List<reply.PostMedia> _toReplyMedia(List<_FeedMedia> items) {
    final out = <reply.PostMedia>[];
    for (final m in items) {
      if (m.type == MediaType.image) {
        out.add(
          m.isNetwork
              ? reply.PostMedia.image(m.path)
              : reply.PostMedia.imageFile(File(m.path)),
        );
      } else {
        out.add(
          m.isNetwork
              ? reply.PostMedia.video(m.path)
              : reply.PostMedia.videoFile(File(m.path)),
        );
      }
    }
    return out;
  }

  Future<void> _openComments(_Post post) async {
    final updated = await Navigator.push<List<reply.Comment>>(
      context,
      MaterialPageRoute(
        builder: (_) => reply.CommentsPage(
          postAuthorName: post.username,
          postAuthorAvatar: _replyHeaderAvatar(post.avatar),
          postTimeText: post.time,
          postText: post.caption,
          postMedia: _toReplyMedia(post.media),
          initialComments: post.comments, // pass current comments
          showAvatars: true,               // show avatars in replies UI
        ),
      ),
    );

    if (updated != null) {
      setState(() {
        post.comments = updated;                 // store back on the post
        post.commentCount = updated.length;      // keep count in sync
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.8,
        titleSpacing: 16,
        title: const Text(
          'iFeed',
          style: TextStyle(
            color: Color(0xff16a34a),
            fontWeight: FontWeight.w800,
            fontSize: 35,
          ),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 25),
            child: Iconify(Ph.heart_bold, color: Colors.black87, size: 28),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const lc.ChatListScreen()),
                );
              },
              child: const Iconify(Ph.chat_circle, color: Colors.black87, size: 26),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // -------- Stories --------
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: SizedBox(
                  height: 105,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) {
                      return Column(
                        children: [
                          _StoryRing(imageUrl: _avatars[i % _avatars.length]),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 70,
                            child: Text(
                              _names[i % _names.length],
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 22),
                    itemCount: 12,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // -------- Empty state --------
            if (_feedPosts.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: const Column(
                    children: [
                      Icon(Icons.photo_library_outlined, size: 60, color: Color.fromARGB(255, 15, 70, 209)),
                      SizedBox(height: 16),
                      Text('No posts yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Share your first post!', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
              ),

            // -------- Feed list --------
            SliverList.separated(
              itemCount: _feedPosts.length,
              itemBuilder: (_, i) => _PostCard(
                post: _feedPosts[i],
                onOpenComments: () => _openComments(_feedPosts[i]),
                onLike: () {
                  setState(() {
                    final p = _feedPosts[i];
                    p.isLiked = !p.isLiked;
                    p.isLiked ? p.likeCount++ : p.likeCount--;
                  });
                },
                onShare: () {
                  setState(() {
                    _feedPosts[i].isShared = !_feedPosts[i].isShared;
                  });
                },
                onRepost: () {
                  setState(() {
                    _feedPosts[i].shareCount++;
                  });
                },
                formatCount: _formatCount,
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 30),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(
        onAdd: () => _handleAddPost(context),
        onProfile: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const profile.ProfileUserScreen()),
          );
        },
      ),
    );
  }
}

/// ------------------------- Story Ring -------------------------
class _StoryRing extends StatelessWidget {
  final String imageUrl;
  const _StoryRing({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [Color(0xffb14cff), Color(0xffff4cf0), Color(0xffb14cff)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          padding: const EdgeInsets.all(3),
          child: CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            onBackgroundImageError: (_, __) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}

/// ------------------------- Comments Preview -------------------------
class _CommentsPreview extends StatelessWidget {
  const _CommentsPreview({
    required this.comments,
    required this.onViewAll,
  });

  final List<reply.Comment> comments;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) return const SizedBox.shrink();

    final toShow = comments.length > 2 ? comments.take(2).toList() : comments;
    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 8, 16, 12), // align with caption
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final c in toShow)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: GestureDetector(
                onTap: onViewAll,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.35),
                    children: [
                      TextSpan(text: c.userName, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const TextSpan(text: '  '),
                      TextSpan(text: c.text),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          if (comments.length > 2)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View all ${comments.length} comments',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}

/// ------------------------- Post Card -------------------------
class _PostCard extends StatelessWidget {
  final _Post post;
  final VoidCallback onOpenComments;
  final VoidCallback onLike;
  final VoidCallback onShare;   // paper-plane toggle
  final VoidCallback onRepost;  // shuffle increments shareCount
  final String Function(int) formatCount;

  const _PostCard({
    required this.post,
    required this.onOpenComments,
    required this.onLike,
    required this.onShare,
    required this.onRepost,
    required this.formatCount,
  });

  ImageProvider _avatarProvider(String avatar) {
    if (avatar.isEmpty) return const AssetImage(defaultAvatarAsset);
    if (avatar.startsWith('http')) return NetworkImage(avatar);
    return AssetImage(avatar);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 12, 5),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: _avatarProvider(post.avatar),
                  onBackgroundImageError: (_, __) {},
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.username,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      Text(post.time,
                          style: const TextStyle(color: Colors.black54, fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Iconify(Mdi.dots_horizontal, size: 24),
                  onPressed: () => _showPostMenu(context, post),
                ),
              ],
            ),
          ),

          // Caption
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(60, 0, 16, 18),
              child: Text(
                post.caption,
                style: const TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.35),
              ),
            ),

          // Media
          if (post.media.isNotEmpty) _PostMedia(post: post),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 18, 0),
            child: Row(
              children: [
                // Like
                IconButton(
                  icon: Iconify(
                    post.isLiked ? Ph.heart_fill : Ph.heart_bold,
                    size: 24,
                    color: post.isLiked ? Colors.red : null,
                  ),
                  onPressed: onLike,
                ),
                const SizedBox(width: 4),
                Text(
                  formatCount(post.likeCount),
                  style: TextStyle(
                    fontSize: 13,
                    color: post.isLiked ? Colors.red : Colors.black54,
                  ),
                ),

                const SizedBox(width: 16),

                // Comments
                IconButton(
                  icon: const Iconify(Uil.comment, size: 24),
                  onPressed: onOpenComments,
                ),
                const SizedBox(width: 4),
                Text(formatCount(post.commentCount), style: const TextStyle(fontSize: 13)),

                const SizedBox(width: 16),

                // Repost (shuffle) — bumps shareCount
                IconButton(
                  icon: const Iconify(Ph.shuffle_fill, size: 24),
                  onPressed: onRepost,
                ),
                const SizedBox(width: 4),
                Text(formatCount(post.shareCount), style: const TextStyle(fontSize: 13)),

                const SizedBox(width: 16),

                // Send/Share (paper-plane) — toggle highlight only
                IconButton(
                  icon: Iconify(
                    post.isShared ? Ph.paper_plane_tilt_fill : Ph.paper_plane_tilt,
                    size: 24,
                    color: post.isShared ? Colors.blue : null,
                  ),
                  onPressed: onShare,
                ),
              ],
            ),
          ),

          // ✅ Inline comments preview
          if (post.comments.isNotEmpty)
            _CommentsPreview(
              comments: post.comments,
              onViewAll: onOpenComments,
            ),
        ],
      ),
    );
  }
}

//Icon 3 dot Popup ——
void _showPostMenu(BuildContext context, _Post post) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: false,
    builder: (_) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MenuSection(
                children: [
                  _MenuItem(
                    icon: Icons.download_outlined,
                    label: 'Save',
                    onTap: () => Navigator.pop(context),
                  ),
                  _MenuItem(
                    icon: Icons.article_outlined,
                    label: 'Detail',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
              _MenuSection(
                children: [
                  _MenuItem(
                    icon: Icons.link_outlined,
                    label: 'Copy link',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
              _MenuSection(
                children: [
                  _MenuItem(
                    icon: Icons.notifications_off_outlined,
                    label: 'Mute',
                    onTap: () => Navigator.pop(context),
                  ),
                  _MenuItem(
                    icon: Icons.block_outlined,
                    label: 'Block',
                    danger: true,
                    onTap: () => Navigator.pop(context),
                  ),
                  _MenuItem(
                    icon: Icons.report_gmailerrorred_outlined,
                    label: 'Report',
                    danger: true,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> children;
  const _MenuSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: List.generate(children.length, (i) {
          final w = children[i];
          return Column(
            children: [
              if (i != 0)
                const Divider(height: 1, thickness: 0.7, color: Color(0xFFE5E7EB)),
              ListTile(
                leading: Icon(w.icon, color: w.danger ? const Color(0xFFEF4444) : Colors.black87),
                title: Text(
                  w.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: w.danger ? const Color(0xFFEF4444) : Colors.black87,
                  ),
                ),
                onTap: w.onTap,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final bool danger;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });
}

/// ------------------------- Media helpers & layouts -------------------------
enum CardAspect { auto, vertical, horizontal, square }

double? _forcedAspectFrom(CardAspect a) {
  switch (a) {
    case CardAspect.vertical:
      return 4 / 5;
    case CardAspect.horizontal:
      return 16 / 9;
    case CardAspect.square:
      return 1 / 1;
    case CardAspect.auto:
      return null;
  }
}

/// 1 item  -> single edge-to-edge
/// 2 items -> two-up row
/// 3+      -> horizontal scroll
class _PostMedia extends StatelessWidget {
  final _Post post;
  const _PostMedia({required this.post});

  static const double _side = 60.0;
  static const double _gap = 12.0;
  static const double _minH = 180.0;
  static const double _maxScreenFraction = 0.55;

  @override
  Widget build(BuildContext context) {
    final forcedAspect = _forcedAspectFrom(post.aspect);

    return LayoutBuilder(builder: (context, c) {
      final aspect = forcedAspect ?? 4 / 5;
      final contentW = c.maxWidth - _side * 2;
      final naturalH = contentW / aspect;
      final maxH = MediaQuery.of(context).size.height * _maxScreenFraction;
      final h = naturalH.clamp(_minH, maxH);

      if (post.media.length == 1) {
        final m = post.media.first;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: _side),
          child: SizedBox(
            height: h,
            child: _RoundedTile(m: m, aspect: aspect),
          ),
        );
      }

      if (post.media.length == 2) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: _side),
          child: SizedBox(
            height: h,
            child: Row(
              children: [
                Expanded(child: _RoundedTile(m: post.media[0], aspect: aspect)),
                const SizedBox(width: _gap),
                Expanded(child: _RoundedTile(m: post.media[1], aspect: aspect)),
              ],
            ),
          ),
        );
      }

      return SizedBox(
        height: h,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: _side),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: post.media.length,
          separatorBuilder: (_, __) => const SizedBox(width: _gap),
          itemBuilder: (_, i) {
            final m = post.media[i];
            return SizedBox(
              width: h * aspect,
              child: _RoundedTile(m: m, aspect: aspect),
            );
          },
        ),
      );
    });
  }
}

class _RoundedTile extends StatelessWidget {
  final _FeedMedia m;
  final double aspect;
  const _RoundedTile({required this.m, required this.aspect});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: aspect,
        child: (m.type == MediaType.image)
            ? (m.isNetwork
                ? Image.network(m.path, fit: BoxFit.cover)
                : Image.file(File(m.path), fit: BoxFit.cover))
            : _CoverVideo(path: m.path, isNetwork: m.isNetwork),
      ),
    );
  }
}

class FillMedia extends StatelessWidget {
  final _FeedMedia m;
  const FillMedia({required this.m});

  @override
  Widget build(BuildContext context) {
    if (m.type == MediaType.image) {
      return m.isNetwork
          ? Image.network(m.path, fit: BoxFit.cover)
          : Image.file(File(m.path), fit: BoxFit.cover);
    }
    return _CoverVideo(path: m.path, isNetwork: m.isNetwork);
  }
}

class _CoverVideo extends StatefulWidget {
  final String path;
  final bool isNetwork;
  const _CoverVideo({required this.path, required this.isNetwork});

  @override
  State<_CoverVideo> createState() => _CoverVideoState();
}

class _CoverVideoState extends State<_CoverVideo> {
  VideoPlayerController? _c;
  bool _ready = false;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _c = widget.isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(widget.path))
        : VideoPlayerController.file(File(widget.path));
    _c!.setLooping(true);
    _c!.initialize().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _c?.pause();
    _c?.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!_ready) return;
    setState(() {
      _playing = !_playing;
      _playing ? _c!.play() : _c!.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: _ready
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _c!.value.size.width,
                    height: _c!.value.size.height,
                    child: VideoPlayer(_c!),
                  ),
                )
              : const ColoredBox(
                  color: Colors.black12,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
        ),
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black26, Colors.transparent],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggle,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _playing ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: const Icon(Icons.play_circle_fill, size: 56, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ------------------------- Auto-aspect (images/videos) -------------------------
class _ImageAutoAspect extends StatefulWidget {
  final String path;
  final bool isNetwork;
  const _ImageAutoAspect({required this.path, required this.isNetwork});

  @override
  State<_ImageAutoAspect> createState() => _ImageAutoAspectState();
}

class _ImageAutoAspectState extends State<_ImageAutoAspect> {
  double? _aspect; // width / height
  @override
  void initState() {
    super.initState();
    final ImageProvider provider =
        widget.isNetwork ? NetworkImage(widget.path) : FileImage(File(widget.path));

    provider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, _) {
        final w = info.image.width.toDouble();
        final h = info.image.height.toDouble();
        if (mounted) setState(() => _aspect = w / h);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aspect = _aspect ?? (4 / 5);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: aspect,
        child: widget.isNetwork
            ? Image.network(widget.path, fit: BoxFit.cover)
            : Image.file(File(widget.path), fit: BoxFit.cover),
      ),
    );
  }
}

class _VideoAutoAspect extends StatefulWidget {
  final String path;
  final bool isNetwork;
  const _VideoAutoAspect({required this.path, required this.isNetwork});

  @override
  State<_VideoAutoAspect> createState() => _VideoAutoAspectState();
}

class _VideoAutoAspectState extends State<_VideoAutoAspect> {
  VideoPlayerController? _c;
  bool _ready = false;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _c = widget.isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(widget.path))
        : VideoPlayerController.file(File(widget.path));
    _c!.setLooping(true);
    _c!.initialize().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _c?.pause();
    _c?.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!_ready) return;
    setState(() {
      _playing = !_playing;
      _playing ? _c!.play() : _c!.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    final aspect = _ready ? _c!.value.aspectRatio : (16 / 9);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: aspect,
        child: Stack(
          children: [
            Positioned.fill(
              child: _ready
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _c!.value.size.width,
                        height: _c!.value.size.height,
                        child: VideoPlayer(_c!),
                      ),
                    )
                  : const ColoredBox(
                      color: Colors.black12,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
            ),
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black26, Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggle,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _playing ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: const Icon(Icons.play_circle_fill, size: 56, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ======================= HOME BOTTOM BAR =======================
class _BottomBar extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onProfile;
  const _BottomBar({required this.onAdd, required this.onProfile});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xffe5e7eb))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const _BarIcon(icon: MaterialSymbols.home_outline_rounded),
          const _BarIcon(icon: Ion.search),
          _AddButton(onTap: onAdd),
          const _BarIcon(icon: Ph.heart),
          _BarIcon(icon: Gg.profile, onTap: onProfile),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF5B6BFF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  final String icon;
  final VoidCallback? onTap;
  const _BarIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Iconify(icon, color: const Color.fromARGB(221, 87, 86, 86), size: 30),
    );
  }
}

/// ======================= UPLOAD PAGE (no popup) =======================
class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});
  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  final _picker = ImagePicker();
  final _text = TextEditingController();
  final List<PickedMedia> _media = [];
  String? _location;

  bool get _canPost => _text.text.trim().isNotEmpty || _media.isNotEmpty;

  Future<void> _pickImage() async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (x != null) setState(() => _media.add(PickedMedia(File(x.path), MediaType.image)));
  }

  Future<void> _pickMultipleMedia() async {
    final files = await _picker.pickMultipleMedia(); // images & videos
    if (files.isEmpty) return;

    bool isVideoPath(String p) {
      final s = p.toLowerCase();
      return s.endsWith('.mp4') ||
          s.endsWith('.mov') ||
          s.endsWith('.m4v') ||
          s.endsWith('.3gp') ||
          s.endsWith('.webm') ||
          s.endsWith('.mkv') ||
          s.endsWith('.avi');
    }

    setState(() {
      for (final x in files) {
        final type = isVideoPath(x.path) ? MediaType.video : MediaType.image;
        _media.add(PickedMedia(File(x.path), type));
      }
    });
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
    );

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFEFEFEF))),
                ),
                child: const Center(
                  child: Text(
                    'iFeed',
                    style: TextStyle(
                      color: Color(0xFF22C55E),
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=68'),
                        ),
                        SizedBox(width: 10),
                        Text('sinayun_xyn', style: TextStyle(fontWeight: FontWeight.w600)),
                        Spacer(),
                        Text('Share a new iFeed', style: TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _text,
                      onChanged: (_) => setState(() {}),
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Write something ...',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: border,
                        enabledBorder: border,
                        focusedBorder: border.copyWith(
                          borderSide: const BorderSide(color: Color(0xFFB4E3C7)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Media',
                          onPressed: _pickMultipleMedia,
                          icon: const Icon(Icons.image_outlined),
                        ),
                        IconButton(
                          tooltip: 'Camera (demo)',
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_camera_outlined),
                        ),
                        IconButton(
                          tooltip: 'Location',
                          onPressed: () => setState(
                            () => _location = _location == null ? 'Phnom Penh' : null,
                          ),
                          icon: const Icon(Icons.location_on_outlined),
                        ),
                      ],
                    ),
                    if (_media.isNotEmpty)
                      _PreviewWrap(
                        media: _media,
                        onRemove: (i) => setState(() => _media.removeAt(i)),
                      ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        const Text('Add a caption', style: TextStyle(color: Colors.black54)),
                        const Spacer(),
                        FilledButton(
                          onPressed: _canPost
                              ? () {
                                  final post = Post(
                                    userName: 'sinayun_xyn',
                                    avatarPath: defaultAvatarAsset,
                                    text: _text.text.trim(),
                                    media: List.of(_media),
                                    location: _location,
                                  );
                                  Navigator.pop(context, post);
                                }
                              : null,
                          child: const Text('Post'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ======================= MODELS =======================
enum MediaType { image, video }

class PickedMedia {
  final File file;
  final MediaType type;
  PickedMedia(this.file, this.type);
}

class Post {
  final String userName;
  final String avatarPath;
  final String text;
  final List<PickedMedia> media;
  final String? location;
  final DateTime createdAt;

  Post({
    required this.userName,
    required this.avatarPath,
    required this.text,
    required this.media,
    this.location,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// ======================= FEED TYPES & MOCK =======================
class _FeedMedia {
  final String path; // file path or URL
  final MediaType type;
  final bool isNetwork;
  _FeedMedia({required this.path, required this.type, required this.isNetwork});
}

class _Post {
  final String id;
  final String username;
  final String avatar; // url or asset; empty -> default asset
  final String time;
  final String caption;
  final List<_FeedMedia> media;
  final CardAspect aspect;

  // social counts/state
  int likeCount;
  int commentCount;
  int shareCount; // used as "reposts"
  bool isLiked;
  bool isShared;

  // ✅ stored comments for preview + persistence
  List<reply.Comment> comments;

  _Post({
    required this.id,
    required this.username,
    required this.avatar,
    required this.time,
    required this.caption,
    required this.media,
    this.aspect = CardAspect.auto,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.isShared = false,
    List<reply.Comment>? comments,
  }) : comments = comments ?? <reply.Comment>[];
}

final _names = ["sinayun_xyn", "tyda-one", "kunthear_kh", "back_tow", "dara.kh", "raa.kh"];

final _avatars = [
  "https://i.pravatar.cc/150?img=32",
  "https://i.pravatar.cc/150?img=47",
  "https://i.pravatar.cc/150?img=12",
  "https://i.pravatar.cc/150?img=5",
  "https://i.pravatar.cc/150?img=36",
  "https://i.pravatar.cc/150?img=32",
];

/// ======================= PREVIEW WRAP (upload page) =======================
class _PreviewWrap extends StatelessWidget {
  final List<PickedMedia> media;
  final void Function(int index) onRemove;
  const _PreviewWrap({required this.media, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      const gap = 10.0;
      final maxW = c.maxWidth;
      final itemW = media.length == 1 ? maxW : (maxW - gap) / 2;

      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: List.generate(media.length, (i) {
          final m = media[i];
          final aspect = m.type == MediaType.image ? 4 / 5 : 16 / 9;
          return Stack(
            children: [
              SizedBox(
                width: itemW,
                child: AspectRatio(
                  aspectRatio: aspect,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: m.type == MediaType.image
                        ? Image.file(m.file, fit: BoxFit.cover)
                        : const ColoredBox(color: Colors.black12),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: InkWell(
                  onTap: () => onRemove(i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          );
        }),
      );
    });
  }
}
