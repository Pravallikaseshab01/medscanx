import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChatExplanationWidget extends StatefulWidget {
  const ChatExplanationWidget({Key? key}) : super(key: key);

  @override
  State<ChatExplanationWidget> createState() => _ChatExplanationWidgetState();
}

class _ChatExplanationWidgetState extends State<ChatExplanationWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'message':
          'Hi! I\'m here to help explain your diagnostic results. Feel free to ask me any questions about your analysis.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 2)),
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    setState(() {
      _messages.add({
        'isUser': true,
        'message': userMessage,
        'timestamp': DateTime.now(),
      });
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          'isUser': false,
          'message': _generateAIResponse(userMessage),
          'timestamp': DateTime.now(),
        });
      });
      _scrollToBottom();
    });
  }

  String _generateAIResponse(String userMessage) {
    final responses = [
      'Based on your scan, the AI analysis shows normal tissue patterns with no concerning abnormalities detected.',
      'The confidence level indicates high accuracy in the diagnostic assessment. This suggests reliable results.',
      'Your results show healthy tissue structure. Regular monitoring is recommended as part of preventive care.',
      'The analysis combines both image and text data to provide comprehensive diagnostic insights.',
      'If you have specific concerns about any findings, I recommend discussing them with your healthcare provider.',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppTheme.animationDurationMedium,
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
    return Container(
      width: double.infinity,
      height: 40.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.borderRadiusMedium),
                topRight: Radius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: CustomIconWidget(
                    iconName: 'smart_toy',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Ask AI Assistant',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(3.w),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['isUser'] as bool;

                return Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  child: Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        Container(
                          padding: EdgeInsets.all(1.5.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.primaryColor,
                            borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusSmall),
                          ),
                          child: CustomIconWidget(
                            iconName: 'psychology',
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 2.w),
                      ],
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: isUser
                                ? AppTheme.lightTheme.primaryColor
                                : AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusMedium),
                            border: isUser
                                ? null
                                : Border.all(color: AppTheme.dividerLight),
                          ),
                          child: Text(
                            message['message'] as String,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: isUser
                                  ? AppTheme.lightTheme.colorScheme.onPrimary
                                  : AppTheme.textHighEmphasisLight,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      if (isUser) ...[
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.all(1.5.w),
                          decoration: BoxDecoration(
                            color: AppTheme.textMediumEmphasisLight,
                            borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusSmall),
                          ),
                          child: CustomIconWidget(
                            iconName: 'person',
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            size: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: AppTheme.dividerLight),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask about your results...',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusLarge),
                        borderSide: BorderSide(color: AppTheme.dividerLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusLarge),
                        borderSide: BorderSide(color: AppTheme.dividerLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusLarge),
                        borderSide:
                            BorderSide(color: AppTheme.lightTheme.primaryColor),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 1.5.h),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 2.w),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusLarge),
                    ),
                    child: CustomIconWidget(
                      iconName: 'send',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
