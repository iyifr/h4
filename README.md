# H4.

![og](https://assets.uploadfast.dev/h4-dev.png)

> H4 is a **lightweight**, **minimal**, and **blazing fast** HTTP framework for productive and fun
> API development with dart.

**H4 is a very new framework under very active development. It's not advised to for production
use.**

## Features

- **Lightweight**: H4 is designed to be minimal and easy to get started with.
- **Fast**: H4's trie-based router is incredibly fast, with support for route params and wildcard
  patterns.
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

## Examples

### Routing with Params

You can define parameters in your routes using : prefix:

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
response

```dart
router.get('/error', (event) {
 throw CreateError(message: 'Something went wrong', errorCode: 400);
});
```
The client recieves this json payload - 
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

We are looking for contributors!

There's still quite a bit of work to do on to get H4 to 1.0.

If you find a bug or have an idea for a new feature, please
[open an issue](https://github.com/iyifr/h4/issues/new) or submit a pull request.

## Code of Conduct.
Everyone is welcome here! Good vibes are of paramount importance. Please be kind and respectful when
opening an issue or suggesting ideas. This makes the author feel good and everyone else feel good
vibes. It's never that serious.
