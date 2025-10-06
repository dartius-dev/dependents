import 'dart:async';
import 'package:flutter/widgets.dart';
import 'dependency_widget.dart';

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
  Widget buildContent(BuildContext context) {
    // check for notify==null, cuz updateDependency may be not invoked
    if (notify==true || (notify==null && widget.notifyOnInit)) {
      final value = dependency;
      Timer.run(()=>widget.listener(value));
    }
    notify = false;

    return widget.child!;
  }
}
