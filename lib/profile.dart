import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/fa.dart';
import 'package:iconify_flutter/icons/mdi.dart'; // ✅ added (for Mdi.account_outline)
import 'package:iconify_flutter/icons/majesticons.dart';

class ProfileUserScreen extends StatelessWidget {
  const ProfileUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffbf7f6),
      body: SafeArea(
        child: Column(
          children: [
            // ---------- Header ----------
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App name
                  const Text(
                    'iFeed',
                    style: TextStyle(
                      color: Color(0xff16a34a),
                      fontWeight: FontWeight.w800,
                      fontSize: 48,
                      letterSpacing: .2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Username + actions + avatar
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'sinayun_xyn',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 25,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Software Engineer',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color.fromARGB(137, 19, 16, 16),
                              ),
                            ),
                          ],      
                        ),
                      ),
                      IconButton(icon: const Iconify(Fa.edit, size: 24), onPressed:(){}),
                      IconButton(icon: const Iconify(Ph.heart_bold, size: 28), onPressed:(){}),
                      const CircleAvatar(
                        radius: 38,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=68',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Bio
                  const Text(
                    'Life is Good alway bring you a nice\none way to heaven',
                    style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(134, 0, 0, 0),)
                  ),
                  const SizedBox(height: 8),

                  // Stats
                  Row(
                    children: const [
                      _SmallStat(label: '11k Follower'),
                      SizedBox(width: 18),
                      _SmallStat(label: 'joined 2017'),
                    ],
                    
                  ),

                  const SizedBox(height: 58),
                ],
              ),
            ),

            // ---------- Tabs row ----------
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.black.withOpacity(.06)),
                  bottom: BorderSide(color: Colors.black.withOpacity(.06)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _TabText('iFeed', isActive: true),
                  _TabText('Shuffle'),
                  _TabText('Media'),
                  _TabText('Share'),
                ],
              ),
            ),

            // ---------- Content (Empty state) ----------
            Expanded(
              child: Container(
                color: Colors.white,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Envelope icon
                    Container(
                      width: 128,
                      height: 92,
                      decoration: BoxDecoration(
                        color: const Color(0xffe8edff),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Center(
                        child: Iconify(Fa.envelope, size: 58, color: Color(0xff3d5afe)),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      "Now you're all up here !",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Start new conversation by creating a post',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff3d5afe),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        // TODO: open your UploadPost page
                      },
                      child: const Text('Create post'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ---------- Bottom Bar ----------
      bottomNavigationBar: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black.withOpacity(.06))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _BottomItem(icon: MaterialSymbols.home_outline_rounded, onTap: () {}),
            _BottomItem(icon: Ion.search, onTap: () {}),
            _MiddleAdd(onTap: () {
                                                                                               // TODO: open composer
            }),
            _BottomItem(icon: Ph.heart_bold, onTap: () {}),
            _BottomItem(icon: Mdi.account_outline, onTap: () {}), // ✅ profile icon matches mainfeed
          ],
        ),
      ),
    );
  }
}

// ======= small widgets =======

class IconChip extends StatelessWidget {
  final String icon; 
  final String? tooltip;
  final VoidCallback onTap;
  const IconChip({required this.icon, this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xfff1f5f9),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Tooltip(
            message: tooltip ?? '',
            child: Iconify(icon, size: 20, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String label;
  const _SmallStat({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 11.5, color: Colors.black54),
    );
  }
}

class _TabText extends StatelessWidget {
  final String text;
  final bool isActive;
  const _TabText(this.text, {this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final c = isActive ? Colors.black : Colors.black87;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: c,
          ),
        ),
        const SizedBox(height: 3),
        if (isActive)
          Container(
            width: 25,
            height: 3,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 36, 64, 223),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

class _BottomItem extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _BottomItem({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Iconify(icon, size: 26, color: const Color(0xCC2f2f2f)),
    );
  }
}

class _MiddleAdd extends StatelessWidget {
  final VoidCallback onTap;
  const _MiddleAdd({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xffb7f0c3),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Iconify(Ph.plus, size: 22, color: Color(0xff15803d)),
        ),
      ),
    );
  }
}
