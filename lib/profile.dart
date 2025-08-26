// profile_user.dart
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/ph.dart';

// Uses UploadPostPage from your mainfeed.dart
import 'mainfeed.dart' show UploadPostPage;

class ProfileUserScreen extends StatelessWidget {
  const ProfileUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: SafeArea(child: _ProfileBody()),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // Brand row
            Row(
              children: [
                Text(
                  'iFeed',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Code',
                  onPressed: () {},
                  icon: const Icon(Icons.code),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Profile card
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text side
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'sinayun_xyn',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const _VerifiedBadge(),
                                  const Spacer(),
                                  _CircleIcon(
                                    icon: Icons.border_color_rounded,
                                    onTap: () {},
                                  ),
                                  const SizedBox(width: 6),
                                  _CircleIcon(
                                    icon: Icons.favorite_border_rounded,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Software Engineer',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Life is Good alway bring you a nice\none way to heaven',
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text('11k Follower',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(color: Colors.grey[600])),
                                  const SizedBox(width: 12),
                                  const _Dot(),
                                  const SizedBox(width: 12),
                                  Text('joined 2017',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(color: Colors.grey[600])),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const _Avatar(imageUrl: 'https://i.pravatar.cc/150?img=68'),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Create Post
            const _SectionHeader(title: 'Create Post'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionSquare(
                    icon: Icons.add,
                    label: 'New Post',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UploadPostPage()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionSquare(
                    icon: Icons.group_add_rounded,
                    label: 'Invite Friends',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invite Friends tapped')),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Library
            const _SectionHeader(title: 'Library'),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _MiniLabel('Replies'),
                  _MiniLabel('Repost'),
                  _MiniLabel('Media'),
                  _MiniLabel('Share'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                _LibraryTile(icon: Icons.verified_rounded, label: 'Verify'),
                SizedBox(width: 12),
                _LibraryTile(icon: Icons.send_rounded, label: 'Promote'),
                SizedBox(width: 12),
                _LibraryTile(icon: Icons.star_border_rounded, label: 'Feature'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ————— small widgets —————

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        shape: BoxShape.circle,
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1DA1F2),
      ),
      padding: const EdgeInsets.all(2),
      child: const Icon(Icons.check, size: 12, color: Colors.white),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CircleIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade100,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: Colors.grey.shade800),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String imageUrl;
  const _Avatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(
            imageUrl,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  color: Colors.black.withOpacity(.08),
                )
              ],
            ),
            child: const _VerifiedBadge(),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionSquare extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap; // <-- added
  const _ActionSquare({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.25,
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF8E8E93).withOpacity(.35),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap, // <-- use callback
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  final String text;
  const _MiniLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .labelSmall
          ?.copyWith(color: Colors.grey[600]),
    );
  }
}

class _LibraryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _LibraryTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 16,                                              
                  offset: const Offset(0, 2),
                  color: Colors.black.withOpacity(.04),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},                              
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
                child: Icon(icon, size: 26), // <-- use the passed icon
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(                                            
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
