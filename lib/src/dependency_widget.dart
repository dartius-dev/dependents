import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef DependencyRecognizer<T>=T Function(BuildContext context);

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
    if (forceBuild) setState(() {});
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    if (widget.dependency(context) case final object when !match(dependency,object)) {
      updateDependency(object);
    }
    return buildContent(context);
  }


  Widget buildContent(BuildContext context);

  
  bool Function(Object?, Object?) get match => defaultMatchFunction;

  static bool defaultMatchFunction(Object? a, Object? b) 
    => a.runtimeType==b.runtimeType && switch(a) {
      final List list => listEquals(list, b as List),
      final Map map => mapEquals(map, b as Map),
      final Set set => setEquals(set, b as Set),
      final obj => obj==b,
    };
}
