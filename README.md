![og](/assets/H4-banner.png)

**A lightweight web framework for dartlang :)**

Inspired by [unjs H(3)'](https://h3.unjs.io) simple, composable API.

Philosophy >> Composable utilities, functional style and meaningful interface.

**This is a new project under active development**.

## Table of Contents

- [Quick setup](#quick-setup)
- [Examples](#examples)
  - [Routes](#routes)
  - [Global Hooks](#global-hooks)
  - [Param Routing](#param-routing)
  - [Wildcard Routing](#wildcard-routing)
- [More Examples](#more-examples)
  - [Multiple Routers with Base Paths](#multiple-routers-with-base-paths)
  - [Request Context & Headers](#request-context--headers)
  - [File Uploads](#file-uploads)
  - [Form Data Processing](#form-data-processing)
  - [Error Handling](#error-handling)
- [Contributing](#contributing)
- [Running tests](#running-tests)
- [Code of Conduct](#code-of-conduct)

## Quick setup

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

### Examples

#### Routes

```dart
void main() {
  var app = createApp(port: 4000);
  var router = createRouter();

  app.use(router);

  // Simply return values from your handlers and H4 handles serialization
  router.get("/", (event) => "Hello world")

  router.post("/post", (event) => {'easy': 'peasy'})
}
```

#### Global Hooks

Register application-wide hooks (middleware pattern):

- `onRequest`: Run when a request is instantiated.
- `onError`: Run when the application breaks due to an error.
- `afterResponse`: Run after the request is handled.

```dart
void main() {
  var app = createApp(
    port: 5173,
    onRequest: (event) {
      // Add request timestamp and logging
      event.context['requestTime'] = DateTime.now();
      print('${event.method} ${event.path}');
    },
    onError: (error, stacktrace, event) {
      // Log errors to your monitoring service
      MyLogger.captureException(error, stacktrace, {
        'path': event.path,
        'method': event.method,
      });
    },
  );
  var router = createRouter();
  app.use(router);
}
```

Example with authentication middleware:

```dart
void main() {
  var app = createApp(
    port: 5173,
    onRequest: (event) {
      // Skip auth for public routes
      if (event.path.startsWith('/public')) return;

      final token = event.headers.value('Authorization')?.replaceAll('Bearer ', '');
      if (token == null) {
        throw CreateError(message: 'Unauthorized', errorCode: 401);
      }

      // Add user to context for route handlers
      event.context['user'] = verifyToken(token);
    },
  );
  var router = createRouter();
  app.use(router);
}
```

#### Param Routing

You can define parameters in your routes using `:` prefix:

```dart
router.get('/users/:id', (event) {
 final userId = event.params['id'];
 return 'User with id: $userId'
});
```

#### Wildcard Routing

```dart
// Matches 'articles/page1' and '/articles/page2' but not 'articles/page1/page2'
router.get('/articles/*', (event) {
 final path = event.path;
 return 'The tea is teaing!!'
});
```

```dart
// Matches 'articles/foo/bar' and 'articles/foo/bar/xen'
router.get('/articles/**', (event) {
 final path = event.path;
 return 'The tea is teaing!!'
});
```

### More Examples

#### Multiple Routers with Base Paths

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

#### Request Context & Headers

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

#### File Uploads

Handle file uploads to your server easily:

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

#### Form Data Processing

Handle multipart form-data:

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

#### Error Handling

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

### Contributing

You can contribute by

- Improving the test coverage of this library,

- Adding a helpful utility, for inspiration see [here](https://h3.unjs.io/utils).

- Sharing benchmarks with other libraries.

### Running tests

In the root directory run

```bash
dart test
```

## Code of Conduct.

Be cool and calm.
