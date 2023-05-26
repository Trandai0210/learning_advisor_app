import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:edubot/components/text_component.dart';
import 'package:flutter/material.dart';
import 'package:edubot/constants/constants.dart';

class ChatComponent extends StatelessWidget {
  final String message;
  final int chatIndex;

  const ChatComponent({Key? key, required this.message, required this.chatIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: chatIndex == 0 ? BACKGROUND_COLOR : CART_COLOR,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: Image.asset(
                    chatIndex == 0 ? USER_IMAGE : BOT_IMAGE,
                    height: 40,
                    width: 40,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: chatIndex == 0
                      ? TextComponent(
                        label: message
                      )
                      : DefaultTextStyle(
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          child: AnimatedTextKit(
                            isRepeatingAnimation: false,
                            repeatForever: false,
                            displayFullTextOnTap: true,
                            totalRepeatCount: 1,
                            animatedTexts: [
                              TyperAnimatedText(
                                message.trim(),
                              )
                            ],
                          )
                        )
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
