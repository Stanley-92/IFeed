import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/ph.dart';





/// ======================= CHAT SCREEN =======================
class Chat extends StatefulWidget {
  const Chat({
    super.key,
    required this.contactName,
    required this.avatarUrl,
  });

  final String contactName;
  final String avatarUrl;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'm0',
      fromMe: false,
      text: 'When do you arrive ?',
      timestampLabel: 'Today · 5:46 PM',
    ),
    ChatMessage(
      id: 'm1',
      fromMe: true,
      imageUrl:
          '',
    ),
    ChatMessage(
      id: 'm2',
      fromMe: true,
      text: 'When do you arrive ?',
    ),
  ];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(id: UniqueKey().toString(), fromMe: true, text: text));
      _controller.clear();
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Insert a string (emoji/text) at the current caret position in the TextField.
  void _insertAtCursor(String s) {
    final text = _controller.text;
    final sel = _controller.selection;
    final start = sel.start >= 0 ? sel.start : text.length;
    final end = sel.end >= 0 ? sel.end : text.length;

    final newText = text.replaceRange(start, end, s);
    final newPos = start + s.length;

    setState(() {
      _controller.text = newText;
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: newPos));
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: const Color(0xfffff9f7),
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              contactName: widget.contactName,
              avatarUrl: widget.avatarUrl,
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  return Column(
                    children: [
                      if (m.timestampLabel != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          m.timestampLabel!,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Align(
                        alignment: m.fromMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: MessageBubble(message: m),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),

        
            // Composer
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              color: bg,
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xff2ecc71),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xfff1f2f4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xffe4e6eb)),
                      ),
                      child: Row(
                        children: [
                          Expanded( 
                            child: TextField(
                              controller: _controller,
                              minLines: 1,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                hintText: 'Write…',
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _send(),
                            ),
                          ),
                          IconButton(
                            icon: const Iconify(MaterialSymbols.add_photo_alternate_outline),
                            onPressed: () {},
                            tooltip: 'Photo',
                          ),
                          IconButton(
                            icon: const Iconify(Ph.smiley_light),
                            onPressed: () => _insertAtCursor('🙂'),
                            tooltip: 'Emoji',
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_horiz),
                            onPressed: () {},
                            tooltip: 'More',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _send,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xff2ecc71),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ======================= HEADER =======================
class _Header extends StatelessWidget {
  const _Header({required this.contactName, required this.avatarUrl});

  final String contactName;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new),
            splashRadius: 20,
          ),
          CircleAvatar(radius: 30, backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contactName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                const Text('Active 27m ago',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

/// ======================= MESSAGE MODELS =======================
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.fromMe,
    this.text,
    this.imageUrl,
    this.timestampLabel,
  });

  final String id;
  final bool fromMe;
  final String? text;
  final String? imageUrl;
  final String? timestampLabel;
}



/// ======================= BUBBLE =======================
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isMe = message.fromMe;
    final maxBubble = MediaQuery.of(context).size.width * 0.66;

    Widget content;
    if (message.imageUrl != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          message.imageUrl!,
          width: maxBubble,
          fit: BoxFit.cover,
        ),
      );
    } else {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxBubble),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xffeef0f4) : const Color(0xff2f88ff),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(isMe ? 14 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 14),
            ),
          ),
          child: Text(
            message.text ?? '',
            style: TextStyle(
              color: isMe ? Colors.black : Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) ...[
          const _AvatarSmall(url:
              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&q=60&auto=format&fit=crop'),
          const SizedBox(width: 8),
        ],
        content,
        if (isMe) ...[
          const SizedBox(width: 8),
          const _AvatarSmall(url:
              'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=300&q=60&auto=format&fit=crop'),
        ],
      ],
    );
  }
}

class _AvatarSmall extends StatelessWidget {
  const _AvatarSmall({required this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: 18, backgroundImage: NetworkImage(url));
  }
}

/// Clickable reaction chip
class _Reaction extends StatelessWidget {
  const  _Reaction   ({required this.child, required this.onTap, Key? key}) : super(key: key);

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Ink(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xffe8e8e8)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                spreadRadius: -2,
                offset: Offset(0, 2),
                color: Color(0x1A000000),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
