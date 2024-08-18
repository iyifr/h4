# H4.

![og](https://assets.uploadfast.dev/h4-dev.png)

> A **lightweight**, **minimal**, and **incredibly fast** HTTP framework for productive and fun API
> development with dart.

**This is a new project under active development**

**Do not use in production as it could break unexpectedly.**

There's an express-like server framework called `Alfred` in the dart ecosystem.

This is the [H3](https://h3.unjs.io) implementation with similar design goals. Special thanks to
[Pooya Parsa](https://github.com/pi0) and the [Unjs](https://github.com/unjs) community for making a
awesome http library.

## Features

- **Lightweight**: H4 ships with a small core and a set of composable utilities.
- **Middleware**: H4 comes with built-in `onRequest` and `onError` middleware.
- **Generic Handlers**: Specify the return type of your handler functions.

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

### Manual Start

```dart
void main() {
  var app = createApp(port: 4000, autoStart: false);
  var router = createRouter();

  app.use(router);

  router.get("/hi", (event) => "Hi")

  app.start()
}
```

### Generic handlers

Specify the return type of your handlers

```dart
router.get<bool>("/25/**", (event) => true);
```

### Global Hooks

You can register global hooks:

- `onRequest`
- `onError`

These hooks are called for every request and can be used to add global logic to your app such as
logging, error handling, etc.

```dart
// Invoked when a request comes in
app.onRequest((event) {
 print('Incoming request method: ${event.method}');
});

// Global error handler - Called when an error occurs.
app.onError((error) {
 logToSentry("$error");
});
```

### Error Handling

You can throw a create error Exception that will terminate the request and send a 400 - Bad Request
response

```dart
router.get('/error', (event) async {
 try {
  // Code that could fail.
 }
 catch(e) {
   throw CreateError(message: 'Womp Womp', errorCode: 400);
 }
});
```

The client recieves this json payload -

```json
{
 "status": 400,
 "message": "Womp Womp"
}
```

### Param Routing

You can define parameters in your routes using `:` prefix:

```dart
router.get('/users/:id', (event) {
 final userId = event.params['id'];
 return 'User $userId'
});
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

## Utilities

A set of composable utilities that help you add functionality to your server

### `readRequestBody`

Reads the request body as `json` or `text` depending on the `contentType` of the request body.

```dart
router.post("/vamos", (event) async {
 var body = await readRequestBody(event);
 return body;
});
```

### `getHeader`

Get the value of any of the incoming request headers. For convenience you can use the HTTPHeaders
utility to get header strings.

```dart
router.post("/vamos", (event) async {
 var header = getHeader(event, HttpHeaders.userAgentHeader);
 return body;
});
```

### Contributing

A good first PR would be helping me improve the test coverage of this library, or adding one of the
utilities listed [here](https://h3.unjs.io/utils).

### Running tests

In the root directory run

```bash
dart test
```

## Code of Conduct.

Show respect and consideration for others when creating issues and contributing to the library. Only
good vibes!
