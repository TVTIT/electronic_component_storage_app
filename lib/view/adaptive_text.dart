import 'package:flutter/material.dart';

class AdaptiveText extends StatelessWidget {
  final String fullText;
  final String shortText;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;

  const AdaptiveText({
    super.key,
    required this.fullText,
    required this.shortText,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    final TextStyle effectiveStyle = style ?? defaultTextStyle.style;

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: fullText, style: effectiveStyle),
          maxLines: maxLines,
          textDirection: Directionality.of(context),
        );

        //Tính toán layout dựa trên không gian còn lại
        textPainter.layout(maxWidth: constraints.maxWidth);

        //Có bị hết chỗ không
        final bool isOverflowing = textPainter.didExceedMaxLines;

        //Nếu hết thì hiện chữ viết tắt, không thì hiện đầy đủ
        final String textToDisplay = isOverflowing ? shortText : fullText;

        return Text(
          textToDisplay,
          style: effectiveStyle,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}