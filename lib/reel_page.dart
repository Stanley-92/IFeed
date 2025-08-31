// reel_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:iconify_flutter/icons/uil.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// --------------------------- MODEL ---------------------------
class ReelItem {
  final String id;
  final String videoUrl;   // URL (or switch to file://path when you add local support)
  final String caption;
  final String music;
  final String avatarUrl;
  final String authorName;
  final int likes;
  final int comments;
  final bool isFollowing;

  const ReelItem({
    required this.id,
    required this.videoUrl,
    required this.caption,
    required this.music,
    required this.avatarUrl,
    required this.authorName,
    this.likes = 0,
    this.comments = 0,
    this.isFollowing = false,
  });
}

/// --------------------------- PAGE ---------------------------
class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key, this.items});
  final List<ReelItem>? items;

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  late final PageController _pageController;
  late final List<ReelItem> _items;
  final Map<int, VideoPlayerController> _controllers = {};
  int _currentIndex = 0;
  bool _muted = true;
  bool _heartBurst = false;

  @override
  void initState() {
    super.initState();
    _items = widget.items ?? _demoItems;
    _pageController = PageController();
    _initControllerFor(0);
    if (_items.length > 1) _initControllerFor(1);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initControllerFor(int index) async {
    if (index < 0 || index >= _items.length) return;
    if (_controllers[index] != null) return;

    final item = _items[index];
    final c = VideoPlayerController.networkUrl(Uri.parse(item.videoUrl));
    _controllers[index] = c;

    await c.initialize();
    c
      ..setLooping(true)
      ..setVolume(_muted ? 0 : 1);

    if (!mounted) return;

    if (index == _currentIndex) {
      c.play();
      setState(() {});
    }

    if (index + 1 < _items.length) {
      // Preload next quietly
      unawaited(_initControllerFor(index + 1));
    }
  }

  void _playOnly(int index) {
    _controllers.forEach((i, c) {
      if (!c.value.isInitialized) return;
      i == index ? c.play() : c.pause();
    });
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    final c = _controllers[_currentIndex];
    if (c != null && c.value.isInitialized) {
      c.setVolume(_muted ? 0 : 1);
    }
  }

  Future<void> _burstHeart() async {
    setState(() => _heartBurst = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _heartBurst = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _items.length,
            onPageChanged: (i) async {
              setState(() => _currentIndex = i);
              await _initControllerFor(i);
              _playOnly(i);
              // warm preload
              unawaited(_initControllerFor(i + 1));
            },
            itemBuilder: (context, index) {
              return _ReelTile(
                key: ValueKey(_items[index].id),
                item: _items[index],
                controller: _controllers[index],
                muted: _muted,
                overlayHeart: _heartBurst && index == _currentIndex,
                // Taps
                onTapVideo: () {
                  final c = _controllers[index];
                  if (c == null || !c.value.isInitialized) return;
                  c.value.isPlaying ? c.pause() : c.play();
                  setState(() {}); // refresh play/pause icon
                },
                onDoubleTapVideo: _burstHeart,
                // Actions
                onComment: () {}, // wire to your comments route if you want
                onShare: () {},
              );
            },
          ),

          // Top bar: back + mute
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(_muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      color: Colors.white),
                  onPressed: _toggleMute,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// --------------------------- REEL TILE ---------------------------
class _ReelTile extends StatefulWidget {
  const _ReelTile({
    super.key,
    required this.item,
    required this.controller,
    required this.muted,
    required this.overlayHeart,
    required this.onTapVideo,
    required this.onDoubleTapVideo,
    required this.onComment,
    required this.onShare,
  });

  final ReelItem item;
  final VideoPlayerController? controller;
  final bool muted;
  final bool overlayHeart;

  final VoidCallback onTapVideo;
  final VoidCallback onDoubleTapVideo;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  State<_ReelTile> createState() => _ReelTileState();
}

class _ReelTileState extends State<_ReelTile> {
  late int _likeCount;
  late int _commentCount;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.item.likes;
    _commentCount = widget.item.comments;
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _liked ? _likeCount++ : _likeCount--;
      if (_likeCount < 0) _likeCount = 0;
    });
  }

  String _k(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final initialized = widget.controller?.value.isInitialized == true;

    return VisibilityDetector(
      key: Key('reel-${widget.item.id}'),
      onVisibilityChanged: (info) {
        final visible = info.visibleFraction > 0.6;
        final c = widget.controller;
        if (c != null && c.value.isInitialized) {
          visible ? c.play() : c.pause();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video
          GestureDetector(
            onTap: widget.onTapVideo,
            onDoubleTap: () {
              if (!_liked) _toggleLike();
              widget.onDoubleTapVideo();
            },
            child: ColoredBox(
              color: Colors.black,
              child: initialized
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: widget.controller!.value.size.width,
                        height: widget.controller!.value.size.height,
                        child: VideoPlayer(widget.controller!),
                      ),
                    )
                  : const Center(
                      child: SizedBox(
                        height: 44,
                        width: 44,
                        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                      ),
                    ),
            ),
          ),

          // Heart burst
          if (widget.overlayHeart)
            const Center(child: Icon(Icons.favorite, color: Colors.white70, size: 120)),

          // Subtle bottom gradient
          const _BottomGradient(),

          // Left-bottom meta + progress
          _BottomMeta(
            item: widget.item,
            controller: widget.controller,
            muted: widget.muted,
          ),

          // Bottom action bar (like screenshot)
          _BottomActionBar(
            isPlaying: widget.controller?.value.isPlaying == true,
            likesLabel: _k(_likeCount),
            commentsLabel: _k(_commentCount),
            onLike: _toggleLike,
            onComment: widget.onComment,
            onTogglePlay: widget.onTapVideo,
            onRemix: () {},
            onShare: widget.onShare,
          ),
        ],
      ),
    );
  }
}

/// Bottom meta (avatar + follow + caption + music + progress)
class _BottomMeta extends StatelessWidget {
  const _BottomMeta({
    required this.item,
    required this.controller,
    required this.muted,
  });

  final ReelItem item;
  final VideoPlayerController? controller;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final initialized = controller?.value.isInitialized == true;

    return Positioned(
      left: 12,
      right: 12,
      bottom: 86, // space for the action bar below
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 16, backgroundImage: NetworkImage(item.avatarUrl)),
              const SizedBox(width: 8),
              Text('@${item.authorName}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.shade400,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Follow',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.music_note_rounded, size: 18, color: Colors.white70),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.music,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Icon(muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white70, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          if (initialized)
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: VideoProgressIndicator(
                controller!,
                allowScrubbing: true,
                padding: EdgeInsets.zero,
                colors: const VideoProgressColors(
                  playedColor: Colors.white,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bottom action bar like your screenshot
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.isPlaying,
    required this.likesLabel,
    required this.commentsLabel,
    required this.onLike,
    required this.onComment,
    required this.onTogglePlay,
    required this.onRemix,
    required this.onShare,
  });

  final bool isPlaying;
  final String likesLabel;
  final String commentsLabel;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onTogglePlay;
  final VoidCallback onRemix;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('1:20', style: TextStyle(color: Colors.white70, fontSize: 10)),
          Row(
            children: [
              _chip(
                icon: Iconify(Ph.heart_bold, size: 20, color: Colors.white),
                label: likesLabel,
                onTap: onLike,
              ),
              const SizedBox(width: 14),
              _chip(
                icon: const Iconify(Uil.comment, size: 20, color: Colors.white),
                label: commentsLabel,
                onTap: onComment,
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: onTogglePlay,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black38,
                    border: Border.all(color: Colors.white38),
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              _circle(
                icon: const Iconify(Ph.shuffle_fill, size: 20, color: Colors.white),
                onTap: onRemix,
              ),
              const SizedBox(width: 14),
              _circle(
                icon: const Iconify(Ph.paper_plane_tilt, size: 20, color: Colors.white),
                onTap: onShare,
              ),
            ],
          ),
          const Text('-2:20', style: TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _chip({required Widget icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          _circle(icon: icon, onTap: onTap),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _circle({required Widget icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black38),
        child: icon,
      ),
    );
  }
}

/// Subtle bottom gradient
class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.45),
              ],
              stops: const [0.5, 0.8, 1],
            ),
          ),
        ),
      ),
    );
  }
}

/// Demo items
const _demoItems = <ReelItem>[
  ReelItem(
    id: '1',
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    caption: 'Morning vibes in Phnom Penh',
    music: 'Original Audio  @sinayun',
    avatarUrl: 'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?w=200',
    authorName: 'sinayun',
    likes: 12900,
    comments: 340,
  ),
  ReelItem(
    id: '2',
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    caption: 'Tech vlog: iFeed update #3',
    music: 'Track — iFeed Beats',
    avatarUrl: 'https://images.unsplash.com/photo-1545996124-0501ebae84d5?w=200',
    authorName: 'techsquad',
    likes: 0,
    comments: 0,
  ),
];

