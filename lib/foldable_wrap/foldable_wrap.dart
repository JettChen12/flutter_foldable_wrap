import 'package:flutter/material.dart';

import 'foldable_wrap_delegate.dart';

/// 可折叠流式布局组件
///
class FoldableWrap extends StatefulWidget {
  const FoldableWrap(
      {super.key,
        required this.children,
        required this.childHeight,
        required this.foldLine,
        this.foldWidget,
        this.maxLines,
        this.isFold = false,
        this.spacing = 0,
        this.runSpacing = 0,
        this.maxChildCountOfOneLine = 0,
        this.onCallLineCount,
        this.foldWidgetAlwaysSetEnd = false,
        this.showTailFoldWidgetWhenUnFold = true})
      : assert(foldLine >= 0, 'foldLine cannot be negative'),
        assert(maxLines == null || maxLines >= 0, 'maxLines cannot be negative'),
        assert(childHeight >= 0, 'childHeight cannot be negative'),
        assert(spacing >= 0, 'spacing cannot be negative'),
        assert(runSpacing >= 0, 'runSpacing cannot be negative'),
        assert(maxChildCountOfOneLine >= 0, 'maxChildCountOfLine cannot be negative');

  /// 子组件列表，折叠组件不要放在这里面
  /// subcomponent list, the foldWidget can not go in here
  final List<Widget> children;

  /// 折叠组件，当折叠组件不为 “null” 且当前需要折叠子组件时，会在折叠后子组件列表的尾部绘制该组件
  /// 当该组建为"null"时不展示该组件，将以空占位组件[SizedBox.shrink]替代，不会显示。
  /// when the foldWidget is not “null” and currently needs to be folded, it will be drawn at the end of the list of children widgets.
  /// This component will not be displayed when it is “null” and will be replaced by an empty placeholder component [SizedBox.shrink].
  final Widget? foldWidget;

  /// 折叠行数，也就是折叠后显示的行数，[foldLine]不能为负数，[foldLine]为 0 时不会绘制任何子组件
  /// the number of lines displayed after folding, [foldLine] can not be negative, [foldLine] is 0 will not draw any subcomponent
  final int foldLine;

  /// 外部控制是否折叠的参数，需要改变此参数时需要配合[setState]等刷新方法让当前组件重新渲染以达到重新布局的效果
  /// External parameter to control whether to fold or not
  /// you need to cooperate with [setState] and other methods to let the current component re-render to achieve the effect of re-layout.
  final bool isFold;

  /// 只显示多少行，限制行数展示
  /// [maxLines] 为 “null” 或者为 0 时，不限制行数
  /// 需要注意的是，[maxLines] 不为 “null” 或 0 时，当前组件只会显示[maxLines]的长度的子组件
  /// 并且，[maxLines]的展示优先级是大于[foldLine]的，当然，设置完[maxLines]是不会展示折叠组件的
  /// 所以希望展示折叠组件并且拥有折叠效果，需要将[maxLines]置为 “null” 或 0
  /// Show only as many rows as you want, limiting the number of rows to display, If [maxLines] is “null” or 0, the number of lines is not limited.
  /// The display priority of [maxLines] is greater than [foldLine], the foldWidget will not be displayed after setting [maxLines].
  /// So if you want to display a foldWidget and have a folding effect, you need to set [maxLines] to “null” or 0
  final int? maxLines;

  /// 水平间距
  final double spacing;

  /// 垂直间距
  final double runSpacing;

  /// 一行最大可显示多少个子组件
  /// 这个参数的意义是最大可显示多少数量的子组件，也就是每一行不会超过当前参数所设置的数量，
  /// 但是，需要注意的是，并不是说每一行是展示当前的参数的数量
  /// 例如[maxChildCountOfOneLine]为4，但子组件的宽度过于大的话，可能三个子组件便占满了一行，此时当前行只会展示3个组件。
  /// Maximum number of subcomponents in a line
  /// each line will not exceed the number set by the current parameter
  /// For example, if [maxChildCountOfOneLine] is 4, but the width of the child components is too large, three child components may fill up a line,
  /// and then the current line will only display three components.
  final int maxChildCountOfOneLine;

  /// 子组件的固定高度
  /// Fixed height of the subcomponent
  /// TODO(jett): 后续会取消该参数，通过子组件的高度递增获取计算Y值
  final double childHeight;

  /// 返回最终的行数
  /// Returns the final number of lines
  final void Function(int)? onCallLineCount;

  /// 当前参数设置为 "true"，折叠组件永远在行的末尾，不会跟在最后一个组件的后边，
  /// 如果折叠组件与最后一个组件的中间仍然有空隙，则会自动占满位置。
  /// With the current parameter set to “true”, the foldWidget will always be at the end of the line and will not follow the last component
  /// If there is still a gap between the foldWidget and the last component, the position is automatically filled.
  /// will be like：[widgets] [last widget] [spacer] [fold widget]
  final bool foldWidgetAlwaysSetEnd;

  /// 当未折叠状态时，尾部显示折叠组件
  /// When not folded, the tail shows the foldWidget
  final bool showTailFoldWidgetWhenUnFold;

  @override
  FoldableWrapState createState() => FoldableWrapState();
}

class FoldableWrapState extends State<FoldableWrap> {
  int line = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flow(
      delegate: FoldableWrapDelegate(
          foldLine: widget.foldLine,
          childHeight: widget.childHeight,
          maxLines: widget.maxLines ?? 0,
          isFold: widget.isFold,
          spacing: widget.spacing,
          runSpacing: widget.runSpacing,
          line: line,
          maxChildCountOfLine: widget.maxChildCountOfOneLine,
          foldWidgetAlwaysSetEnd: widget.foldWidgetAlwaysSetEnd,
          showTailFoldWidgetWhenUnFold: widget.showTailFoldWidgetWhenUnFold,
          onLine: (int i) {
            WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
              widget.onCallLineCount?.call(i);
              setState(() {
                line = i;
              });
            });
          }),
      children: _getChildren(),
    );
  }

  List<Widget> _getChildren() {
    final List<Widget> children = <Widget>[];
    children.addAll(widget.children);
    children.add(widget.foldWidget ?? const SizedBox.shrink());
    return children;
  }
}
