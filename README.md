# H4.

![og](https://assets.uploadfast.dev/banner2.png)

> H4 is a **lightweight**, **modular**, and **blazing fast** Dart HTTP library for productive and
> fun API development. With its composable utils and functional design, you'll write less
> boilerplate and more functionality.

## Features

- **Lightweight**: H4 is designed to be minimal and easy to use, without sacrificing power and
  speed.
- **Modular**: H4 provides a set of composable utils that you can mix and match to build your
  server's functionality.
- **Blazing Fast**: H4's trie-based router is incredibly fast, with support for route params and
  wildcard patterns.
- **Middleware**: H4 comes with built-in `onRequest` and `onError` middleware.
- **Error Handling**: H4's `createError` exception makes it easy to handle and respond to errors.

## Getting Started

Add H4 to your `pubspec.yaml`:

```yaml
dependencies:
  h4: ^1.0.0
```

Or install with dart pub get

```powershell
dart pub add h4
```

Import the library and start building your server:

```dart
import 'package:h4/create.dart';

void main() {
  var app = createApp();
  var router = createRouter();

  app.use(router);

  router.get("/", (event) => "Hello world!");
}
```

Yes it's that easy!

## Examples

### Routing with Params

```dart
router.get('/users/:id', (event) {
  final userId = event.params['id'];
  return 'User $userId'
});
```

### Middleware

H4 provides two middleware functions. Do not return anything from middleware as this will terminate
the request.

```dart
 app.onRequest((event) {
  print('Incoming request method: ${event.method}');
 });

 app.onError((error) {
    print("$error");
  });
```

### Error Handling

You can throw a create error Exception that will terminate the request and send a 400 - Bad Request
response to the client with a json payload.

```dart
router.get('/error', (event) {
  throw CreateError('Something went wrong');
});
```

```json
{
 "status": 400,
 "message": "An error ocurred"
}
```

### Wildcard Routing

```dart
// Matches 'articles/page' and '/articles/otherPage' but not 'articles/page/otherPage'
router.get('/articles/*', (event) {
 final path = event.path;
 return 'The tea is teaing!!'

});
```

```dart
// Matches 'articles/foo/bar' and 'articles/rice/eba/beans'
router.get('/articles/**', (event) {
 final path = event.path;
 return 'The tea is teaing!!'

});
```

## Contributing

We welcome contributions! If you find a bug or have an idea for a new feature, please
[open an issue](https://github.com/iyifr/h4/issues/new) or submit a pull request.
