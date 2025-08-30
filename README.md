<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->



# Dependents
![pub version](https://img.shields.io/pub/v/dependents)
[![live demo](https://github.com/dartius-dev/dependents/raw/main/example/livedemo.svg)](https://dartius-dev.github.io/dependents/)
[![example](https://github.com/dartius-dev/dependents/raw/main/example/example.svg)](https://github.com/dartius-dev/dependents/blob/main/example/lib/main.dart)

`dependents` is a Flutter package that simplifies building reactive UIs by providing widgets for managing and responding to changes in dependencies, such as inherited widgets, ValueNotifier, or any Listenable. It helps you avoid boilerplate, reduce coupling, and keep your widget tree clean and maintainable.

## Why use Dependents?

```dart
final messageNotifier = ValueNotifier<String>('Hello!');

DependentBuilder<(String, bool)>(
  listenable: messageNotifier,
  dependency: (context) {
    final enclose = MediaQuery.maybeViewInsetsOf(context).bottom > 0
    return (
      enclose ? "[ ${messageNotifier.value} ]" : messageNotifier.value, 
      MediaQuery.sizeOf(context).width < 300
    );
  },
  builder: (context, _) {
    final (message, isSmall) = DependentBuilder.dependencyOf<(String, bool)>(context);
    return Text(message, softWrap: isSmall);
  },
)
```
This example demonstrates how `DependentBuilder` efficiently manages multiple dependencies.

The `dependency` function is triggered whenever any of the following change:
* `messageNotifier.value`
* `MediaQuery.viewInsets`
* `MediaQuery.size`

The `builder` rebuilds the `Text` widget only when the dependency tuple `(message, isSmall)` changes:
* the message value,
* the zero/non-zero state of `MediaQuery.viewInsets.bottom`,
* or when the screen width crosses the 300-pixel threshold.

By tracking several dependencies together, you ensure that your UI updates only when truly relevant changes occur, minimizing unnecessary rebuilds and improving performance.

> This approach minimizes unnecessary rebuilds and improves performance compared to traditional listeners.

Flutter's widget tree is powerful, but handling dynamic dependencies and rebuilding widgets efficiently can be challenging. Typical problems include:

- **Manual state management**: Tracking dependencies and updating widgets manually leads to verbose and error-prone code.
- **InheritedWidget limitations**: Accessing and reacting to inherited values often requires custom logic and can be hard to scale.
- **Listenable/ValueNotifier boilerplate**: Listening to changes and rebuilding widgets usually involves repetitive code.
- **Unintended rebuilds**: Widgets may rebuild unnecessarily, impacting performance.

`dependents` solves these problems by:

- Automatically rebuilding widgets only when relevant dependencies change.
- Providing a unified API for both inherited widgets and listenable objects.
- Allowing you to react to dependency changes with custom callbacks (side effects).
- Making dependency access and propagation simple and type-safe.

## Features

- **Automatic rebuilds**: Widgets update only when their dependencies change.
- **Unified dependency management**: Works with inherited widgets, ValueNotifier, and any Listenable.
- **Custom listeners**: React to changes with side effects, not just rebuilds.
- **Type-safe dependency access**: Easily get the current value anywhere in the widget subtree.
- **Composable and lightweight**: Integrates with other state management solutions and fits any architecture.

## Getting started

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  dependents: <latest_version>
```

Import the package:

```dart
import 'package:dependents/dependents.dart';
```

## Usage

### Rebuild on InheritedWidget Special Property Change

```dart
DependentBuilder<Brightness>(
  dependency: (context) => Theme.of(context).colorScheme.brightness,
  builder: (context, _) {
    final brightness = DependentBuilder.dependencyOf<Brightness>(context);
    return Text("$brightness"),
)
```

In this example, the builder will only rebuild when the specific property `colorScheme.brightness` of the theme changes, not on every theme update or unrelated widget change.

> **Note:** The value returned from the `dependency` handler can be accessed inside the `builder` using `DependentBuilder.dependencyOf<T>(context)`. This allows you to retrieve the current dependency value anywhere within the builder, ensuring type safety and convenience.


### Rebuild on Listenable Special Property Change

```dart
final userValueNotifier = ValueNotifier<User>(User(name: 'Dep', age: 22));

DependentBuilder<String>(
  listenable: userValueNotifier,
  dependency: (context) => userValueNotifier.value.name,
  builder: (context, _) => Text(userValueNotifier.value.name),
)
```

You can track changes to a specific property (e.g., `name`) rather than the whole object.

The builder will only rebuild when `userValueNotifier.value.name` changes, not when other properties change.


### Rebuild on Expression depending on InheritedWidget

```dart
DependentBuilder<bool>(
  dependency: (context) => Theme.of(context).colorScheme.onPrimary.computeLuminance() > 0.5,
  builder: (context, _) {
    final light = DependentBuilder.dependencyOf<bool>(context);
    return Text(light ? "LIGHT" : "DARK");
  },
)
```

The `dependency` function can return any computed value, not just objects or direct properties from dependencies. This allows you to derive and react to complex conditions or calculations based on multiple sources, making your widgets more flexible and expressive.

### Combined Listenable and Inherited Dependencies

```dart
final userNameNotifier = ValueNotifier<String>('Dep');

DependentBuilder<(bool, String)>(
  listenable: userNameNotifier,
  dependency: (context) {
    final isLight = Theme.of(context).colorScheme.brightness == Brightness.light;
    final name = userNameNotifier.value;
    return (isLight, name);
  },
  builder: (context, _) {
    final (isLight, name) = DependentBuilder.dependencyOf<(bool, String)>(context);
    return Text('Good ${isLight ? 'morning' :'evening'}, $name!');
  },
)
```


This widget will rebuild and update the greeting whenever the theme brightness or the user's name changes, demonstrating how to combine inherited and listenable dependencies.

> **Tip:** If you need to track multiple listenable dependencies (such as several ValueNotifiers), you can use the `listenableList` property:

```dart
DependentBuilder(
  listenableList: [notifier1, notifier2],
  dependency: (context) => computeValue(notifier1.value, notifier2.value),
  builder: (context, _) {
    final computedValue = DependentBuilder.dependencyOf(context);
    return Text("$computedValue"),
  }
)
```

### React to Dependency Changes with Side Effects

```dart
DependencyListener<String>(
  dependency: (context) => Theme.of(context).colorScheme.brightness == Brightness.light;,
  listener: (light) => print('Good ${light ? 'morning' :'evening'}!'),
  child: Container(),
)
```
With `DependencyListener`, you can react to dependency changes and trigger side effects (such as logging, analytics, or navigation) without rebuilding the widget itself. This is useful for handling events or actions that should not affect the UI layout.

> `listenable` and `listenableList` are also available for handling complex dependencies.

## Typical use cases

- **Theme and localization**: Automatically update widgets when theme or locale changes.
- **User/session data**: React to changes in user profile, authentication state, or settings.
- **Custom inherited models**: Simplify access and updates for custom inherited widgets.
- **Form and input state**: Rebuild or react to changes in form fields or validation state.

## Strengths

- **Minimal boilerplate**: Write less code to achieve robust reactivity.
- **Performance**: Only affected widgets rebuild, reducing unnecessary work.
- **Flexibility**: Works with any Listenable, ValueNotifier, or inherited widget.
- **Side effects**: Easily trigger actions (logging, analytics, etc.) on dependency changes.
- **Type safety**: Dependency values are strongly typed and easy to access.

## Additional information

See the `/example` folder to explore practical usage patterns and integration strategies. 

* [Try the live demo here.](https://dartius-dev.github.io/dependents/).
* [Example’s source code](https://github.com/dartius-dev/dependents/blob/main/example/lib/main.dart)

Issues and suggestions are welcome!

## li