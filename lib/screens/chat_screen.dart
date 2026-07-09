import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/wordmark.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text;
    if (text.trim().isEmpty) return;
    context.read<AppState>().sendMessage(text);
    _ctrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final messages = state.messages;
    final typing = state.marcusTyping;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: const [
          GlyphLogo(size: 26),
          SizedBox(width: 10),
          Text('Marcus'),
        ]),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text('● online',
                  style: TextStyle(color: Color(0xFF4ADE80), fontSize: 11)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Hi, I'm Marcus. Ask me anything about your score, stress, sleep, or how to feel calmer.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.muted, height: 1.5),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (typing ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == messages.length) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: AppColors.border),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  SizedBox(
                                    width: 13,
                                    height: 13,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.purple),
                                  ),
                                  SizedBox(width: 9),
                                  Text('Marcus is thinking…',
                                      style: TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 12.5)),
                                ]),
                          ),
                        );
                      }
                      final m = messages[i];
                      return Align(
                        alignment: m.fromUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * .78),
                          decoration: BoxDecoration(
                            color: m.fromUser
                                ? AppColors.purple
                                : AppColors.surface,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(14),
                              topRight: const Radius.circular(14),
                              bottomLeft: Radius.circular(m.fromUser ? 14 : 4),
                              bottomRight:
                                  Radius.circular(m.fromUser ? 4 : 14),
                            ),
                            border: m.fromUser
                                ? null
                                : Border.all(color: AppColors.border),
                          ),
                          child: Text(m.text,
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.45,
                                color: m.fromUser
                                    ? Colors.white
                                    : AppColors.ink,
                              )),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Message Marcus…',
                    hintStyle: const TextStyle(
                        color: AppColors.muted, fontSize: 13.5),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 11),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          const BorderSide(color: AppColors.purple),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Container(
                decoration: const BoxDecoration(
                    color: AppColors.purple, shape: BoxShape.circle),
                child: IconButton(
                  onPressed: _send,
                  icon: const Icon(LucideIcons.send,
                      size: 17, color: Colors.white),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
