![og](/assets/H4-banner.png)

**A lightweight web framework for dart**

Inspired by [unjs H3](https://h3.unjs.io), built with familiar API's and a functional style. 

**This is a new project under active development**, there are tests, but it could break in unexpected ways.

The official documentation is a WIP - [link](https://h4-tau.vercel.app)

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

### Hello world

```dart
void main() {
  var app = createApp(port: 4000);
  var router = createRouter();

  app.use(router);

  router.get("/", (event) => "Hello world")
}
```


### Global Hooks
You can register global hooks:

- `onRequest`
- `onError`
- `afterResponse`

These hooks are called for every request and can be used to add global logic to your app such as
logging, error handling, etc.

```dart
 var app = createApp(
   port: 5173,
   onRequest: (event) => {},
   onError: (error, stacktrace, event) => {},
   afterResponse: (event) => {},
 );
 var router = createRouter();
 app.use(router);
```


### Param Routing

You can define parameters in your routes using `:` prefix:

```dart
router.get('/users/:id', (event) {
 final userId = event.params['id'];
 return 'User with id: $userId'
});
```

### Wildcard Routing

```dart
// Matches 'articles/page' and '/articles/otherPage' but not 'articles/page/subPage'
router.get('/articles/*', (event) {
 final path = event.path;
 return 'The tea is teaing!!'
});
```

```dart
// Matches 'articles/foo/bar' and 'articles/page/subPage/subSubPage'
router.get('/articles/**', (event) {
 final path = event.path;
 return 'The tea is teaing!!'
});
```

### Generic handlers

Specify the return type of your handlers

```dart
router.get<bool>("/25/**", (event) => true);
router.get<int>("/42/**", (event) => 42);
router.get<String>("/hello/**", (event) => "Hello world");
```


### Error Handling
A special `CreateError` exception can be called that will terminate the request and send a 400 - Bad Request
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


## Utilities
A set of composable utilities that help you add functionality to your server.

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

There are a few more utilities that have been created which will be documented soon.

### Contributing

A great first PR would be improve the test coverage of this library, or adding a helpful util, for
inspiration see [here](https://h3.unjs.io/utils).

### Running tests

In the root directory run

```bash
dart test
```

## Code of Conduct.

Be cool and calm.
