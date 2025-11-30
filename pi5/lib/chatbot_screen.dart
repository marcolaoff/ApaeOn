import 'package:flutter/material.dart';
import 'services/gemini_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  // Instância única do serviço do Gemini
  final GeminiService _geminiService = GeminiService();

  static const List<String> _quickReplies = [
    'Como compro ingressos?',
    'Onde vejo meus ingressos?',
    'Como alterar meu perfil?',
    'Estou com problema no login',
    'O que é o ApaeOn?',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text:
            'Olá! 👋\nEu sou o assistente do ApaeOn.\n\nPosso te ajudar com ingressos, eventos, perfil, login e uso do aplicativo.',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ========= ENVIO E EXIBIÇÃO =========

  Future<void> _sendMessage([String? preset]) async {
    final text = preset ?? _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    String resposta;

    try {
      resposta = await _geminiService.ask(text);
    } catch (e) {
      resposta =
          'Tive um problema para falar com a IA agora 😕\n'
          'Verifique sua conexão e tente novamente em instantes.';
    }

    if (!mounted) return;

    setState(() {
      _messages.add(ChatMessage(text: resposta, isUser: false));
      _isTyping = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUser = msg.isUser;

    final bgColor = isUser ? theme.colorScheme.primary : theme.cardColor;

    final textColor = isUser
        ? Colors.white
        : theme.textTheme.bodyMedium?.color ??
            (isDark ? Colors.white70 : Colors.black87);

    final alignment =
        isUser ? Alignment.centerRight : Alignment.centerLeft;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(14),
      topRight: const Radius.circular(14),
      bottomLeft: Radius.circular(isUser ? 14 : 0),
      bottomRight: Radius.circular(isUser ? 0 : 14),
    );

    final avatarBg = isUser
        ? (isDark ? Colors.deepPurpleAccent : theme.colorScheme.primary)
        : (isDark ? Colors.deepPurple : Colors.deepPurple);

    final avatarIcon = isUser ? Icons.person : Icons.support_agent;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser)
              CircleAvatar(
                radius: 16,
                backgroundColor: avatarBg,
                child: Icon(
                  avatarIcon,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            if (!isUser) const SizedBox(width: 6),
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: radius,
                ),
                child: Text(
                  msg.text,
                  style: TextStyle(color: textColor, fontSize: 14),
                ),
              ),
            ),
            if (isUser) const SizedBox(width: 6),
            if (isUser)
              CircleAvatar(
                radius: 16,
                backgroundColor: avatarBg,
                child: Icon(
                  avatarIcon,
                  size: 18,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReplies() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final chipBg = isDark ? theme.cardColor : Colors.white;

    final labelColor =
        theme.textTheme.bodyMedium?.color ?? (isDark ? Colors.white70 : Colors.black87);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: _quickReplies.map((text) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ActionChip(
              backgroundColor: chipBg,
              side: BorderSide(
                color: isDark ? Colors.white24 : Colors.black12,
              ),
              label: Text(
                text,
                style: TextStyle(fontSize: 12, color: labelColor),
              ),
              onPressed: () => _sendMessage(text),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Assistente ApaeOn',
          style: theme.appBarTheme.titleTextStyle,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.deepPurple,
                            child: Icon(
                              Icons.support_agent,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Assistente digitando...',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodySmall?.color ??
                                  Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          const SizedBox(height: 4),

          // Quick replies
          _buildQuickReplies(),

          const Divider(height: 1),

          // Campo de texto + botão enviar
          SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Digite sua dúvida...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () => _sendMessage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
