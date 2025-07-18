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


Dependents is a Flutter package that provides widgets for building and reacting to changes in dependencies, such as inherited widgets or listenable objects, making it easier to manage and respond to dynamic data in the widget tree.


## Features


- Build widgets that automatically rebuild when a dependency changes (e.g., inherited widgets, ValueNotifier, or any Listenable).
- React to dependency changes with custom callbacks.
- Easily access the current dependency value in the widget tree.
- Compose with other widgets and state management solutions.

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


### Example: Rebuild on Theme Change

```dart
DependentBuilder<Brightness>(
  dependency: (context) => Theme.of(context).colorScheme.brightness,
  builder: (context, _) => Text("${DependentBuilder.dependencyOf<Brightness>(context)}"),
)
```

### Example: Rebuild on Special Property change 

```dart
final userValueNotifier = ValueNotifier<User>(User(name: 'Alice', age: 22));

DependentBuilder<String>(
  listenable: userValueNotifier,
  dependency: (context) => userValueNotifier.value.name,
  builder: (context, _) => Text(userValueNotifier.value.name),
)
```

### Example: Use DependencyListener

```dart
DependencyListener<String>(
  listenable: userValueNotifier,
  dependency: (context) => userValueNotifier.value.name,
  listener: (name) => print('User name changed: $name'),
  child: Container(),
)
```

### Example: React on Brightness Change

```dart
DependentBuilder<bool>(
  dependency: (context) => Theme.of(context).colorScheme.onPrimary.computeLuminance() > 0.5,
  listener: (light) => print(light ? "LIGHT" : "DARK"),
)
```

