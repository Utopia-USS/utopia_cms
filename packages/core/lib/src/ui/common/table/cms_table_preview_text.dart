import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_widgets/misc/multi_widget.dart';

class CmsTablePreviewText extends StatelessWidget {
  final String? text;

  const CmsTablePreviewText(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final style = context.textStyles.text;
    final snackbarTextStyle = context.textStyles.button;
    final snackbarBackgroundColor = context.colors.accent;
    final screenWidth = MediaQuery.of(context).size.width;
    return Align(
      alignment: Alignment.centerLeft,
      child: MultiWidget(
        [
          if (text != null)
            (child) => Tooltip(
                  message: text!,
                  child: child,
                ),
          (_) => _buildContent(
                style: style,
                snackbarTextStyle: snackbarTextStyle,
                snackbarBackgroundColor: snackbarBackgroundColor,
                screenWidth: screenWidth,
                context: context,
              )
        ],
      ),
    );
  }

  Widget _buildContent({
    required TextStyle style,
    required TextStyle snackbarTextStyle,
    required Color snackbarBackgroundColor,
    required double screenWidth,
    required BuildContext context,
  }) {
    return MouseRegion(
      cursor: text != null ? SystemMouseCursors.copy : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: () async {
          if (text != null) {
            await Clipboard.setData(ClipboardData(text: text!)).then((value) => ScaffoldMessenger.of(context)
                .showSnackBar(_buildSnackBar(snackbarTextStyle, snackbarBackgroundColor, screenWidth)));
          }
        },
        child: Text(
          text ?? '-',
          style: style,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  SnackBar _buildSnackBar(TextStyle style, Color backgroundColor, double screenWidth) {
    const double width = 200;
    final margin = (screenWidth - width) / 2;
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      margin: EdgeInsets.fromLTRB(margin, 0, margin, 36),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      elevation: 20,
      content: Row(
        children: [
          Text("Copied", style: style),
          const Spacer(),
          Icon(Icons.done_all, color: style.color),
        ],
      ),
    );
  }
}
