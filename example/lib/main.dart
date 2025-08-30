import 'package:flutter/material.dart';
import 'package:dependents/dependents.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const App());

class App extends StatefulWidget {
  const App({super.key});

  static AppState of(BuildContext context) {
    return context.findAncestorStateOfType<AppState>()!;
  }

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  bool isDark = false;

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const ExampleScreen(
      ),
    );
  }
}

///
///
///
class ExampleScreen extends StatefulWidget {

  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final userValueNotifier = ValueNotifier<User>(User(name: 'Dep', age: 22));
  final notifier1 = ValueNotifier<int>(0);
  final notifier2 = ValueNotifier<int>(100);

  @override
  void dispose() {
    userValueNotifier.dispose();
    notifier1.dispose();
    notifier2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text.rich(
              TextSpan(text: '', children: [
                TextSpan(text: 'dependents', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' package example'),
              ]),
            ),
            TextButton(
                onPressed: () => launchUrl(Uri.parse("https://github.com/dartius-dev/dependents/blob/main/example/lib/main.dart")),
                child: const Text('source'),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    shrinkWrap: false,
                    children: [
                      //
                      // Greeting based on theme and user name
                      //
                      Center(
                        child: DependentBuilder<(bool, String)>(
                          listenable: userValueNotifier,
                          dependency: (context) {
                            final isLight = Theme.of(context).colorScheme.brightness == Brightness.light;
                            final name = userValueNotifier.value.name;
                            return (isLight, name);
                          },
                          builder: (context, _) {
                            final tuple = DependentBuilder.dependencyOf<(bool, String)>(context);
                            final isLight = tuple?.$1 ?? false;
                            final name = tuple?.$2 ?? '';
                            return Text('Good ${isLight ? 'morning' : 'evening'}, $name!', 
                              style: Theme.of(context).textTheme.headlineMedium);
                          },
                        ),
                      ),
                      const SizedBox(height: 36),
                            
                      //
                      // Theme brightness example
                      //
                      Row(
                        children: [
                          Expanded(
                            child: DependentBuilder<bool>(
                            dependency: (context) => Theme.of(context).colorScheme.onPrimary.computeLuminance() > 0.5,
                            builder: (context, _) {
                              final light = DependentBuilder.dependencyOf<bool>(context);
                              return Text(light == true ? 'LIGHT' : 'DARK', style: TextStyle(fontWeight: FontWeight.bold));
                            },
                          ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: App.of(context).toggleTheme,
                              child: DependentBuilder<bool>(
                                dependency: (context) => Theme.of(context).brightness==Brightness.light,
                                builder: (context, _) {
                                  final isLight = DependentBuilder.dependencyOf<bool>(context)!;
                                  return Text(isLight ? 'Switch to Dark Theme' : 'Switch to Light Theme');
                                },
                              ),
                            ),
                          ),
                            
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                        Expanded(
                          child: Text("Theme brightness:"),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DependentBuilder<Brightness>(
                              dependency: (context) => Theme.of(context).colorScheme.brightness,
                              builder: (context, _) => Text(
                                '${DependentBuilder.dependencyOf<Brightness>(context)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                        ),
                        ],
                      ),   
                      const SizedBox(height: 36),
                            
                      //
                      // User name
                      //
                      Row(
                        children: [
                        Expanded(
                          child: DependentBuilder<String>(
                            listenable: userValueNotifier,
                            dependency: (context) => userValueNotifier.value.name,
                            builder: (context, _) => Text(
                              'User: ${userValueNotifier.value.name}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: userValueNotifier.value.name,
                            decoration: const InputDecoration(labelText: 'Change user name', helperText: 'Type "Dracula"'),
                            onChanged: (value) {
                              userValueNotifier.value = User(name: value, age: userValueNotifier.value.age);
                            },
                          ),
                        ),
                        ],
                      ),
                      const SizedBox(height: 16),
                            
                            
                      //
                      // User age
                      //
                      Row(
                        children: [
                          Expanded(
                            child: DependentBuilder<int>(
                              listenable: userValueNotifier,
                              dependency: (context) => userValueNotifier.value.age,
                              builder: (context, _) => Text(
                                'Age: ${userValueNotifier.value.age}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    final user = userValueNotifier.value;
                                    userValueNotifier.value = User(name: user.name, age: user.age - 1);
                                  },
                                  child: const Text('-'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    final user = userValueNotifier.value;
                                    userValueNotifier.value = User(name: user.name, age: user.age + 1);
                                  },
                                  child: const Text('+'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                            
                      //
                      // Multiple dependency: sum of two notifiers
                      //
                      Row(
                        children: [
                        Expanded(
                          child: DependentBuilder<int>(
                            listenableList: [notifier1, notifier2],
                            dependency: (_) => notifier1.value + notifier2.value,
                            builder: (_, _) => Text('Sum: ${notifier1.value + notifier2.value}'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                          children: [
                            ElevatedButton(
                            onPressed: () => notifier1.value++,
                            child: ListenableBuilder(
                                listenable: notifier1,
                                builder: (_, _) => Text('${notifier1.value} ++')
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                            onPressed: () => notifier2.value++,
                            child: ListenableBuilder(
                                listenable: notifier2,
                                builder: (_, _) => Text('${notifier2.value} ++')
                              ),
                            ),
                          ],
                          ),
                        ),
                        ],
                      ),
                            
                      //
                      // Reaction on name and age changes
                      //
                      DependencyListener<bool>(
                        listenable: userValueNotifier,
                        dependency: (context) {
                          return (userValueNotifier.value.name.toLowerCase().contains('dracula') 
                            || userValueNotifier.value.age > 100 || userValueNotifier.value.age < 1
                            ) && Theme.of(context).brightness == Brightness.light;
                        },
                        listener: (toDark) {
                          if (toDark==true) App.of(context).toggleTheme();
                        },
                        child: const SizedBox.shrink(),
                      ),
                            
                  
                      // bottom      
                      const SizedBox(height: 36),                        
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    onPressed: () => launchUrl(Uri.parse("https://pub.dev/packages/dependents")),
                    child: Text.rich(TextSpan(text: '', children: [
                      TextSpan(text: 'dependents', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' on pub.dev'),
                    ])),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


///
/// User model
///
class User {
  final String name;
  final int age;
  const User({required this.name, required this.age});
}
