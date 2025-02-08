import 'package:flutter/cupertino.dart';

/// 可折叠流式布局组件
///
class FoldableWrapDelegate extends FlowDelegate {
  FoldableWrapDelegate(
      {required this.foldLine,
      required this.childHeight,
      this.maxLines = 0,
      this.isFold = false,
      this.spacing = 0,
      this.runSpacing = 0,
      this.line = 0,
      this.onLine,
      this.maxChildCountOfLine = 0,
      this.foldWidgetAlwaysSetEnd = false,
      this.showTailFoldWidgetWhenUnFold = true});

  final int foldLine;
  final int maxLines;
  final bool isFold;
  final double spacing;
  final double runSpacing;
  final double childHeight;
  final int line;
  final ValueChanged<int>? onLine;
  final int maxChildCountOfLine;
  final bool foldWidgetAlwaysSetEnd;
  final bool showTailFoldWidgetWhenUnFold;

  @override
  void paintChildren(FlowPaintingContext context) {
    final double screenW = context.size.width;
    double offsetX = 0;
    double offsetY = 0;
    final int foldWidgetIndex = context.childCount - 1;
    int currentLine = 1;
    int childCountOfThisLine = 0;
    bool hasPaintedFoldWidget = false;

    for (int i = 0; i < foldWidgetIndex; i++) {
      if (offsetX + (context.getChildSize(i)?.width ?? 0) <= screenW && hasPassedChildCountLimit(childCountOfThisLine)) {
        if (needPaintFoldWidget(i, offsetX, screenW, currentLine, context)) {
          if (canPaintWithFoldWidget(i, foldWidgetIndex, offsetX, screenW, context)) {
            context.paintChild(i, transform: Matrix4.translationValues(offsetX, offsetY, 0));
            offsetX = offsetX + (context.getChildSize(i)?.width ?? 0) + spacing;
          }
          if (!hasPaintedFoldWidget) {
            context.paintChild(foldWidgetIndex,
                transform:
                    Matrix4.translationValues(getFoldWidgetOffsetX(context.getChildSize(foldWidgetIndex)?.width ?? 0, offsetX, screenW), offsetY, 0));
            offsetX = offsetX + (context.getChildSize(foldWidgetIndex)?.width ?? 0) + spacing;
            hasPaintedFoldWidget = true;
          }
          break;
        } else {
          context.paintChild(i, transform: Matrix4.translationValues(offsetX, offsetY, 0));
          offsetX = offsetX + (context.getChildSize(i)?.width ?? 0) + spacing;
          childCountOfThisLine++;
        }
      } else {
        currentLine++;
        childCountOfThisLine = 0;
        if (isFold && (currentLine > foldLine)) {
          if (!hasPaintedFoldWidget) {
            context.paintChild(foldWidgetIndex,
                transform:
                    Matrix4.translationValues(getFoldWidgetOffsetX(context.getChildSize(foldWidgetIndex)?.width ?? 0, offsetX, screenW), offsetY, 0));
            offsetX = offsetX + (context.getChildSize(foldWidgetIndex)?.width ?? 0) + spacing;
            hasPaintedFoldWidget = true;
          }
          break;
        }
        if (maxLines != 0 && currentLine > maxLines) break;
        offsetX = 0;
        offsetY = offsetY + childHeight + runSpacing;

        if (needPaintFoldWidget(i, offsetX, screenW, currentLine, context)) {
          if (canPaintWithFoldWidget(i, foldWidgetIndex, offsetX, screenW, context)) {
            context.paintChild(i, transform: Matrix4.translationValues(offsetX, offsetY, 0));
            offsetX = offsetX + (context.getChildSize(i)?.width ?? 0) + spacing;
          }
          if (!hasPaintedFoldWidget) {
            context.paintChild(foldWidgetIndex,
                transform:
                    Matrix4.translationValues(getFoldWidgetOffsetX(context.getChildSize(foldWidgetIndex)?.width ?? 0, offsetX, screenW), offsetY, 0));
            offsetX = offsetX + (context.getChildSize(foldWidgetIndex)?.width ?? 0) + spacing;
            hasPaintedFoldWidget = true;
          }
        } else {
          context.paintChild(i, transform: Matrix4.translationValues(offsetX, offsetY, 0));
          childCountOfThisLine++;
        }
        offsetX = offsetX + (context.getChildSize(i)?.width ?? 0) + spacing;
      }
    }

    if (showTailFoldWidgetWhenUnFold && !isFold && !hasPaintedFoldWidget && currentLine > foldLine) {
      if (offsetX + (context.getChildSize(foldWidgetIndex)?.width ?? 0) > screenW) {
        currentLine++;
        childCountOfThisLine = 0;
        offsetX = 0;
        offsetY = offsetY + childHeight + runSpacing;
      }
      context.paintChild(foldWidgetIndex,
          transform:
              Matrix4.translationValues(getFoldWidgetOffsetX(context.getChildSize(foldWidgetIndex)?.width ?? 0, offsetX, screenW), offsetY, 0));
      offsetX = offsetX + (context.getChildSize(foldWidgetIndex)?.width ?? 0) + spacing;
      childCountOfThisLine++;
      hasPaintedFoldWidget = true;
    }

    onLine?.call(currentLine);
  }

  bool hasPassedChildCountLimit(int lineLength) {
    if (maxChildCountOfLine == 0) return true;
    return lineLength < maxChildCountOfLine;
  }

  bool needPaintFoldWidget(int index, double offsetX, double screenW, int currentLine, FlowPaintingContext context) {
    final bool nextChildIsNotFoldWidget = index + 1 < context.childCount - 1;
    final bool currentPlusNextChildWidthWillOverFlow =
        (offsetX + (context.getChildSize(index)?.width ?? 0) + spacing + (context.getChildSize(index + 1)?.width ?? 0)) > screenW;
    final bool nextLineWillOverFoldLine = (currentLine + 1) > foldLine;
    return isFold && nextChildIsNotFoldWidget && currentPlusNextChildWidthWillOverFlow && nextLineWillOverFoldLine;
  }

  bool canPaintWithFoldWidget(int index, int foldWidgetIndex, double offsetX, double screenW, FlowPaintingContext context) {
    return (offsetX + (context.getChildSize(index)?.width ?? 0) + spacing + (context.getChildSize(foldWidgetIndex)?.width ?? 0)) <= screenW;
  }

  double getFoldWidgetOffsetX(double foldWidgetWidth, double offsetX, double screenWidth) {
    if (!foldWidgetAlwaysSetEnd) {
      return offsetX;
    }
    return screenWidth - foldWidgetWidth;
  }

  @override
  Size getSize(BoxConstraints constraints) {
    if (isFold) {
      int kLine = line;
      if (line > foldLine) {
        kLine = foldLine;
      }
      return Size(constraints.maxWidth, childHeight * kLine + runSpacing * (kLine - 1));
    }
    int kLine = line;
    if (maxLines != 0 && line > maxLines) {
      kLine = maxLines;
    }
    return Size(constraints.maxWidth, childHeight * kLine + runSpacing * (kLine - 1));
  }

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints(maxWidth: constraints.maxWidth, minWidth: 0, maxHeight: childHeight, minHeight: 0);
  }

  @override
  bool shouldRepaint(covariant FoldableWrapDelegate oldDelegate) {
    if (isFold != oldDelegate.isFold) {
      return true;
    }
    if (line != oldDelegate.line) {
      return true;
    }
    return false;
  }

  @override
  bool shouldRelayout(covariant FoldableWrapDelegate oldDelegate) {
    return (line != oldDelegate.line);
  }
}
