# H4 - The Lightweight Dart HTTP Framework

> H4 is a **lightweight**, **modular**, and **blazing fast** Dart HTTP framework that makes building
> servers a breeze. With its composable utils and functional design, you'll write less boilerplate
> and more functionality.

## Features

- **Lightweight**: H4 is designed to be minimal and easy to use, without sacrificing power.
- **Modular**: H4 provides a set of composable utils that you can mix and match to build your
  server's functionality.
- **Blazing Fast**: H4's trie-based router is incredibly fast, with support for route params and
  wildcard patterns.
- **Middleware**: H4 comes with built-in `onRequest` and `onResponse` middleware to handle your
  server's needs.
- **Error Handling**: H4's `createError` function makes it easy to handle and respond to errors.

## Getting Started

Add H4 to your `pubspec.yaml`:

```yaml
dependencies:
  h4: ^1.0.0
```

Import the library and start building your server:

```dart
import 'package:h4/h4.dart';

void main() {
  var app = createApp();
  var router = createRouter();

  app.use(router);

  router.get("/", (event) => "Hello world!");
}
```

## Examples

### Routing with Params

```dart
app.get('/users/:id', (event) {
  final userId = event.params['id'];
  return 'User $userId'
});
```

### Middleware

Do not return anything from middleware.

```dart
 app.onRequest((event) {
  print('Incoming request method: ${event.method}');
 });

  app.onError((e, s) {
    print("$e");
  });
```

### Error Handling

```dart
app.get('/error', (req) {
  throw createError(500, 'Something went wrong');
});
```

### Wildcard Routing

```dart
app.get('/articles/*', (event) {
  final path = event.path;
  return 'The tea is teaing!!'
});
```

## Contributing

We welcome contributions! If you find a bug or have an idea for a new feature, please
[open an issue](https://github.com/iyifr/h4/issues/new) or submit a pull request.
