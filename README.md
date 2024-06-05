# H4.

![og](https://assets.uploadfast.dev/h4-dev.png)

> A **lightweight**, **minimal**, and **incredibly fast** HTTP framework for productive and fun API
> development with dart.

**This is a very new project under active development**

**Do not use in production as it could break unexpectedly.**

You're welcome to try it out, see what breaks and give feedback. 

There's already an express.js implementation called `Alfred` in the dart ecosystem. 

This is the [H3](https://h3.unjs.io) implementation with similar design goals. 
Special thanks to [Pooya Parsa](https://github.com/pi0) and the [Unjs](https://github.com/unjs) community for making a great library.

## Features

- **Lightweight**: H4 ships with a small core and a set of composable utilities.
- **Fast**: H4's trie-based router is incredibly fast, with support for route params and wildcard
  patterns.
- **Middleware**: H4 comes with built-in `onRequest` and `onError` middleware.
- **Generic Handlers**: Specify the return type of your handler functions for increased type safety.

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
var app = createApp(port: 4000, autoStart: false);

app.start().then((h4) => print(h4?.port));

var router = createRouter();

app.use(router);
```

### Generic handlers

Specify the return type of your handlers

```dart
 router.get<bool>("/25/**", (event) => true);
```

### Middleware

H4 provides two middleware functions out of the box.

```dart
// Invoked when a request comes in
app.onRequest((event) {
 print('Incoming request method: ${event.method}');
});

// Global error handler - Called when an error occurs in non-async handlers
app.onError((error) {
 print("$error");
});
```

### Error Handling

You can throw a create error Exception that will terminate the request and send a 400 - Bad Request
response

```dart
router.get('/error', (event) {
  try {
  // Code that could fail.
  }
  catch(e) {
    throw CreateError(message: 'Something went wrong', errorCode: 400);
  }
});
```

The client recieves this json payload -

```json
{
 "status": 400,
 "message": "An error ocurred"
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

This is a design philosophy from [h3](https://h3.unjs.io).

I'm working on adding an exhaustive list of composable utilities for adding functionality to your
server.

Support for more utilities will be added soon along with a guide to creating your own.

### `readRequestBody`

Reads the request body as `json` or `text` depending on the content type of the request body.

```dart
router.post("/vamos", (event) async {
  var body = await readRequestBody(event);
  return body;
});
```

## Contributing

We are looking for contributors!

There's still quite a bit of work to do to get H4 to 1.0.0 and ready for production use.

If you find a bug or have an idea for a new feature, please
[open an issue](https://github.com/iyifr/h4/issues/new) or submit a pull request.

### First Contribution

A good first PR would be helping me improve the test coverage of this library. Or adding one of the
utilities listed [here](https://h3.unjs.io/utils).

## Code of Conduct.

Show respect and consideration for others when creating issues and contributing to the library. Only
good vibes!
