import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

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
  static T? dependencyOf<T>(BuildContext context) {
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
  Widget build(BuildContext context) {
    builtWidget ??=  widget.builder(context, widget.child);
    return builtWidget!;
  }

}

/// [DependencyListener] calls [listener] callback when the result of the [dependency] expression changes.
/// 
/// The [dependency] callback is invoked whenever an inherited widget dependency changes,
/// or when the [listenable] (or any item in [listenableList]) notifies its listeners.
///
class DependencyListener<T> extends DependencyWidget<T> {
  
  final bool notifyOnInit;
  final void Function(T? dependency) listener;

  const DependencyListener({
    super.key, 
    super.listenable,
    super.listenableList,
    this.notifyOnInit=true, 
    required super.dependency, 
    required this.listener,
    required Widget super.child
  });

  @override
  State<DependencyListener<T>> createState() => _DependencyListenerState<T>();
}

class _DependencyListenerState<T> extends DependencyState<T, DependencyListener<T> > {
  bool? notify;

  @override
  void updateDependency(T? value) {
    if (notify!=null || widget.notifyOnInit) {
      notify = true;
    }
    super.updateDependency(value);
  }

  @override
  Widget build(BuildContext context) {
    // check for notify==null, cuz updateDependency may be not invoked
    if (notify==true || (notify==null && widget.notifyOnInit)) {
      final value = dependency;
      Timer.run(()=>widget.listener(value));
    }
    notify = false;

    return widget.child!;
  }
}


///
///
///
typedef DependencyRecognizer<T>=T? Function(BuildContext context);

///
///
///
abstract class DependencyWidget<T> extends StatefulWidget {

  final Listenable? listenable;
  final List<Listenable>? listenableList;
  final DependencyRecognizer<T> dependency;
  final Widget? child;

  const DependencyWidget({
    super.key, 
    this.listenable,
    this.listenableList,
    required this.dependency,
    this.child
  }) : assert(listenableList==null || listenable==null, 'Either listenable or listenableList can be provided, not both.');

}

///
///
///
abstract class DependencyState<T, W extends DependencyWidget<T>> extends State<W>{

  T? get dependency => _dependency;
  T? _dependency;

  void updateDependency(T? value) => _dependency=value;

  @override
  void initState() {
    super.initState();
    widget.listenable?.addListener(updateState);
    widget.listenableList?.forEach((l) => l.addListener(updateState));
  }

  @override
  void dispose() {
    widget.listenable?.removeListener(updateState);
    widget.listenableList?.forEach((l) => l.removeListener(updateState));
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.listenable!=oldWidget.listenable)){
      oldWidget.listenable?.removeListener(updateState);
      widget.listenable?.addListener(updateState);
    }

    if (!match(widget.listenableList, oldWidget.listenableList)) {
      oldWidget.listenableList?.forEach((l) => l.removeListener(updateState));
      widget.listenableList?.forEach((l) => l.addListener(updateState));
    }

    if (widget.dependency!=oldWidget.dependency) {
      updateState(forceBuild: false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateState(forceBuild: false);
  }

  @protected
  void updateState({bool forceBuild=true}) {
    if (widget.dependency(context) case final T object when !match(dependency,object)) {
      updateDependency(object);
      if(forceBuild) setState(() {});
    }
  }

  
  bool Function(Object?, Object?) get match => defaultMatchFunction;

  static bool defaultMatchFunction(Object? a, Object? b) 
    => a.runtimeType==b.runtimeType && switch(a) {
      final List list => listEquals(list, b as List),
      final Map map => mapEquals(map, b as Map),
      final Set set => setEquals(set, b as Set),
      final obj => obj==b,
    };
}
