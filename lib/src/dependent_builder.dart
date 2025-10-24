import 'package:flutter/widgets.dart';
import 'dependency_widget.dart';

/// [DependentBuilder] builds a widget when the result of the dependency expression changes.
/// 
/// This code updates a widget content when the theme brightness is changed:
/// 
/// ```dart
/// DependentBuilder<Brightness>(
///   dependency: (context) => Theme.of(context).colorScheme.brightness,
///   builder: (context, _) => Text("${DependentBuilder.dependencyOf<Brightness>(context)}")
/// )
/// ```
/// 
///
/// The following code updates the widget's content when the result of a dependency expression changes.
///
/// ```dart
/// DependentBuilder<bool>(
///   dependency: (context) => Theme.of(context).colorScheme.onPrimary.computeLuminance() > 0.5,
///   builder: (context, _) {
///     final light = DependentBuilder.dependencyOf<bool>(context);
///     Text(light ? 'light' : 'dark')
///   } 
/// )
/// ```
/// 
/// The `dependency` callback is invoked whenever an inherited widget dependency changes,
/// or when the `listenable` (or any item in `listenableList`) notifies its listeners.
/// 
/// The following code updates the widget's content when the user name changes.
/// 
/// ```dart
/// DependentBuilder<String>(
///   listenable: userValueNotifier,
///   dependency: (context) => userValueNotifier.value.name,
///   builder: (context, _) {
///     final light = DependentBuilder.dependencyOf<bool>(context);
///     Text(light ? 'light' : 'dark')
///   } 
/// )
/// ```
/// 
/// 
class DependentBuilder<T> extends DependencyWidget<T> {
  final Widget? Function(BuildContext context, Widget? child) builder;
  final bool buildOnDependencyOnly;

  const DependentBuilder({
    super.key, 
    super.listenable,
    super.listenableList,
    required super.dependency,
    required this.builder,
    this.buildOnDependencyOnly = false,
    super.child,
  });

  /// Returns the current dependency value from the nearest ancestor [DependentBuilder].
  static T dependencyOf<T>(BuildContext context) => maybeDependencyOf<T>(context)!;

  static T? maybeDependencyOf<T>(BuildContext context) {
    final state = switch(context) {
      StatefulElement(:final _DependentBuilderState<T> state) => state,
      _ => context.findAncestorStateOfType<_DependentBuilderState<T>>()
    };
    return state?.dependency;
  }

  @override
  State<DependentBuilder<T>> createState() => _DependentBuilderState<T>();
}

class _DependentBuilderState<T> extends DependencyState<T, DependentBuilder<T>> {
  Widget? builtWidget;

  @override
  void updateDependency(T? value) {
    builtWidget = null;
    super.updateDependency(value);
  }

  @override
  void didUpdateWidget(covariant DependentBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.child!=oldWidget.child || !widget.buildOnDependencyOnly) {
      builtWidget = null;
    } 
  }

  @override
  Widget buildContent(BuildContext context) {
    builtWidget ??=  widget.builder(context, widget.child);
    return builtWidget!;
  }

}
