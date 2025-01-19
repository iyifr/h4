![og](/assets/H4-banner.png)

**A lightweight web framework for dart**

Heavily inspired by [unjs H(3)'s'](https://h3.unjs.io) API. Composable utilities, functional styles
and simple interface.

**This is a new project under active development**, there are tests, but it could break in
unexpected ways.

Feedback is welcome.

The official documentation is a WIP - [link](https://h4-tau.vercel.app)

## Getting Started

Add H4 to your `pubspec.yaml`:

```yaml
dependencies:
  h4: 0.4.1
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

Register application-wide hooks:

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

### Error Handling

A special `CreateError` exception can be called that will terminate the request and send a 400 - Bad
Request response

## Advanced Examples

Here's an enhanced examples section for the README.md:

## Advanced Examples

### Multiple Routers with Base Paths

Organize your routes by creating multiple routers with different base paths:

```dart
void main() {
  var app = createApp(port: 3000);

  var mainRouter = createRouter();
  var apiRouter = createRouter();

  // Mount routers with different base paths
  app.use(mainRouter, basePath: '/');
  app.use(apiRouter, basePath: '/api');

  // Main routes
  mainRouter.get('/hello', (event) => {'message': 'Hello World'});

  // API routes
  apiRouter.get('/users', (event) => ['user1', 'user2']);
  apiRouter.post('/auth', (event) async {
    var body = await readRequestBody(event);
    return body;
  });
}
```

### Request Context & Headers

Store request-specific data and handle headers:

```dart
void main() {
  var app = createApp(
    port: 3000,
    onRequest: (event) {
      // Store data in request context
      event.context["userId"] = "123";

      // Set CORS headers
      handleCors(event, origin: "https://myapp.com", methods: "GET,POST");
    },
    afterResponse: (event) {
      print("Response sent with status: ${event.statusCode}");
    }
  );
}
```

### File Uploads

Handle file uploads:

```dart
void main() {
  var app = createApp(port: 3000);
  var router = createRouter();
  app.use(router);

  router.post("/upload", (event) async {
    var files = await readFiles(
      event,

      // Formdata field where your files are stored
      fieldName: 'file',

      // Optional: Set custom directory for uploaded files. (defaults to temp dir)
      customFilePath: 'uploads',

      // Optional: Hash filenames for security (defaults to false)
      // When false, files are prefixed with a naive hash.
      hashFileName: true,

      // Optional: Set max file size in MB (defaults to 10MB)
      maxFileSize: 5
    );

    // Returned File obj contains: path, size, originalname, mimeType
    return {
      'message': 'Upload complete',
      'files': files
    };
  });
}
```

### Form Data Processing

Handle multipart form data with ease:

```dart
void main() {
  var app = createApp(port: 3000);
  var router = createRouter();
  app.use(router);

  router.post("/signup", (event) async {
    var formData = await readFormData(event);

    // Access form fields
    var username = formData.get('username');
    var password = formData.get('password');

    // Get multiple values
    var interests = formData.getAll('interests');

    return {
      'user': username,
      'interests': interests
    };
  });
}
```

### Error Handling with Custom Responses

Implement robust error handling:

```dart
void main() {
  var app = createApp(
    port: 3000,
    onError: (error, stacktrace, event) {
      print("Error occurred: $error");
    }
  );
  var router = createRouter();
  app.use(router);

  router.get("/risky-operation", (event) async {
    try {
      // Potentially failing operation
      throw Exception("Something went wrong");
    } catch (e) {
      throw CreateError(
        message: "Operation failed: $e",
        errorCode: 400
      );
    }
  });
}
```

The client will recieve a JSON payload -

```json
{
	"status": 400,
	"message": "Operation failed {error Message}"
}
```

For more detailed implementations and utilities, check out the
[official documentation](https://h4-tau.vercel.app).

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
