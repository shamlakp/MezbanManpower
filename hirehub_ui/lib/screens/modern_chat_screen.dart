import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../models/job_application.dart';
import '../providers/application_provider.dart';

/// Entry point: shows a list of all applicants the recruiter can chat with.
class ModernChatScreen extends StatefulWidget {
  // Legacy param kept for backward compatibility; ignored when shown from the hub
  final String? userName;
  const ModernChatScreen({super.key, this.userName});

  @override
  State<ModernChatScreen> createState() => _ModernChatScreenState();
}

class _ModernChatScreenState extends State<ModernChatScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<ApplicationProvider>().fetchApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? NeutralColor.c900 : NeutralColor.c50;
    final cardBg = isDark ? NeutralColor.c800 : Colors.white;
    final textMain = isDark ? NeutralColor.c50 : NeutralColor.c900;
    final textSub = isDark ? NeutralColor.c400 : NeutralColor.c600;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Messages',
          style: TextStyle(
            color: textMain,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<ApplicationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.applications.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: BrandColor.c500));
          }

          if (provider.applications.isEmpty) {
            return _buildEmpty(textMain, textSub);
          }

          // Group by applicant name (deduplicate)
          final seen = <String>{};
          final unique = provider.applications
              .where((a) => seen.add(a.applicantName))
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            itemCount: unique.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final app = unique[i];
              return _buildConversationTile(
                  context, app, cardBg, textMain, textSub);
            },
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    JobApplication app,
    Color cardBg,
    Color textMain,
    Color textSub,
  ) {
    final details = app.applicantDetails ?? {};
    final email = details['email'] as String? ?? '';
    final lastMessage = app.notes.isNotEmpty
        ? app.notes
        : 'Application for ${app.jobPosition}';

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ChatThreadScreen(
            applicantName: app.applicantName,
            applicantEmail: email,
            jobTitle: app.jobPosition,
            applicationId: app.id,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: BrandColor.c500.withOpacity(0.1),
              child: Text(
                app.applicantName.isNotEmpty
                    ? app.applicantName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: BrandColor.c500,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name + preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.applicantName,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: textMain,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: textSub,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            // Status badge + date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  app.appliedAt.isNotEmpty
                      ? app.appliedAt.split('T')[0]
                      : '',
                  style: TextStyle(
                      color: textSub,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                _statusDot(app.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusDot(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'shortlisted':
        color = SuccessColor.c500;
        break;
      case 'rejected':
        color = DangerColor.c500;
        break;
      default:
        color = BrandColor.c500;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildEmpty(Color textMain, Color textSub) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 60, color: textSub.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text('No conversations yet',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: textMain)),
          const SizedBox(height: 8),
          Text('Applicants will appear here once\nthey submit applications.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSub, fontSize: 14)),
        ],
      ),
    );
  }
}

/// Individual chat thread with an applicant.
class _ChatThreadScreen extends StatefulWidget {
  final String applicantName;
  final String applicantEmail;
  final String jobTitle;
  final int applicationId;

  const _ChatThreadScreen({
    required this.applicantName,
    required this.applicantEmail,
    required this.jobTitle,
    required this.applicationId,
  });

  @override
  State<_ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<_ChatThreadScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Pre-seeded with a contextual opening message
  late List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      {
        'text':
            'Hi ${widget.applicantName.split(' ').first}! We reviewed your application for the ${widget.jobTitle} role and would like to connect with you.',
        'isMe': true,
        'time': _timeNow(),
      },
    ];
  }

  String _timeNow() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'text': text, 'isMe': true, 'time': _timeNow()});
      _messageController.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeutralColor.c50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: NeutralColor.c900, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: BrandColor.c100,
              radius: 18,
              child: Text(
                widget.applicantName.isNotEmpty
                    ? widget.applicantName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: BrandColor.c500, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.applicantName,
                    style: const TextStyle(
                        color: NeutralColor.c900,
                        fontSize: 15,
                        fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.applicantEmail.isNotEmpty)
                    Text(
                      widget.applicantEmail,
                      style: const TextStyle(
                          color: NeutralColor.c500,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: NeutralColor.c600),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded,
                color: NeutralColor.c600),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Job context banner
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.work_outline_rounded,
                    size: 14, color: BrandColor.c500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Re: ${widget.jobTitle}',
                    style: const TextStyle(
                        color: BrandColor.c500,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(
                    msg['text'], msg['isMe'], msg['time'] ?? '');
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? BrandColor.c500 : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : NeutralColor.c900,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                  color: NeutralColor.c400,
                  fontSize: 10,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: const TextStyle(color: NeutralColor.c400),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: NeutralColor.c50,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: const BoxDecoration(
                    color: BrandColor.c500, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
