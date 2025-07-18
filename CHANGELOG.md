## 0.4.6

- Refactored `readRequestBody` utility, making it more efficienct and less error prone.
- Made `readRequestBody` utility generic for better typing, but didn't get very far using native types.
- Added more tests for the `readRequestBody` utility.

## 0.4.5

- **IMPROVED** Response serialization:

  - Replaced string-based content type handling with ContentType objects
  - Added proper handling for null responses
  - Optimized JSON serialization with JsonEncoder.withIndent

- **FIXED** Route handling logic:

  - Improved HTTP method handling for better performance
  - Streamlined 404 and 405 response generation
  - Simplified event context structure

- **REFACTORED** Internal code:
  - Removed unnecessary \_handled flag from event processing
  - Simplified response header management
  - Improved code organization in event.dart

## 0.4.4 (Patch Release)

- **PATCHED** Router implementation:

  - Improved root path ('/') handling
  - Added support for '\*\*' wildcard pattern

- **IMPROVED** Test coverage:

  - Added test for named routes
  - Simplified wildcard route tests by removing redundant assertions
  - Removed unnecessary status code checks

- **REFACTORED** Internal code:
  - Streamlined error handling logic in router
  - Improved code readability with more concise syntax

## 0.4.3 (Patch Release)

- **IMPROVED** CORS handling with new `handleCors` utility:

  - Added support for credentials, max age, and custom headers
  - Better documentation and examples for CORS configuration
  - Default values for common CORS scenarios

- **ENHANCED** IP address detection in `getRequestIp`:

  - Added support for additional IP headers:
    - X-Real-IP
    - CF-Connecting-IP
    - True-Client-IP
  - Improved fallback chain for IP detection

- **OPTIMIZED** Router implementation:

  - Improved param route scanning efficiency
  - Better handling of root path ('/')
  - Removed unused root handler parameter

- **IMPROVED** Documentation:

  - Added comprehensive examples for route parameters
  - Enhanced documentation for request utilities
  - Updated contributing guidelines

- **REFACTORED** Internal utilities:
  - Moved multipart form handling to private methods
  - Better organization of request utilities
  - Improved code readability and maintainability

## 0.4.2 (Patch Release)

- **EXTENDED** `readFiles` utility with new options for file handling:
  - Added `hashFileName` parameter (boolean) to control file name generation
  - Added `maxFileSize` parameter (int, MB) to limit upload sizes
  - Default values: `hashFileName: false`, `maxFileSize: 10`
- **IMPROVED** Documentation for file upload functionality in README
- **UPDATED** Documentation comments for `readFiles` utility with comprehensive examples and return
  type details

## 0.4.1 (Patch Release)

- **PATCHED** Improved error handling in the `readFiles` utility for better file upload management.
- **PATCHED** Updated documentation for the `readFormData` utility to clarify usage and examples.
- **PATCHED** Fixed minor bugs in the router handling for better route matching.
- **UPDATED** Dependencies in `pubspec.yaml` to ensure compatibility with the latest Dart SDK.
- **ADDED** New test cases in `h4_test.dart` to cover edge cases for file uploads and form data
  handling.

## 0.4.0 (Minor release)

- **NEW** `readFiles` utility to handle file uploads.

```dart
var files = await readFiles(event, fieldName: 'file', customFilePath: 'uploads');
// files is a List<Map<String, dynamic>> containing the info of the files uploaded.
// Example:
// [
//   {
//     'path': 'uploads/test.txt',
//     'mimeType': 'text/plain',
//     'originalname': 'test.txt',
//     'fieldName': 'file',
//     'size': 17,
//     'tempFilename': 'test.txt'
//   }
// ]

// EXAMPLE HANDLER.
router.post("/upload", (event) async {
  var files = await readFiles(event, fieldName: 'file', customFilePath: 'uploads');
  return files;
});
```

- **PATCHED** `readFiles` utility to handle file uploads better.

### 0.3.2

- **PATCHED** Fixed bug in `init` script in the Bootstrap CLI.

### 0.3.1 (Patch)

- **EXTENDED** `readFormData` utility to handle undefined formdata fields better.
- **PATCHED** `setResponseHeader` utility to better handle immutable nature of http response
  headers.
- Documented some utilities better.
- Entire library is now accessible from one import.

## 0.3.0 (Minor)

- **NEW** Multiple Routers with `basePath`

```dart

void main() async {
  var app = createApp(
    port: 5173,
    onRequest: (event) {
      // PER REQUEST local state😻
      event.context["user"] = 'Ogunlepon';

      setResponseHeader(event,
          header: HttpHeaders.contentTypeHeader,
          value: 'text/html; charset=utf-8');
    },
    afterResponse: (event) => {},
  );

  var router = createRouter();
  var apiRouter = createRouter();

  app.use(router, basePath: '/');
  app.use(apiRouter, basePath: '/api');

  router.get("/vamos/:id/base/:studentId", (event) {
    return event.params;
  });

  apiRouter.get("/signup", (event) async {
    var formData = await readFormData(event);

    var username = formData.get('username');
    var password = formData.get('password');

    // userService.signup(username, password);
    event.statusCode = 201;

    return 'Hi from /api with $username, $password';
  });
}
```

- **NEW** `readFormData` utility - familiar formdata parsing API

```dart
apiRouter.get("/signup", (event) async  {
  var formData = await readFormData(event);

  var username = formData.get('username');
  var password = formData.get('password');

  // ALSO included..
  var allNames = formdata.getAll('names') // return List<String>

  userService.signup(username, password);
  event.statusCode = 201;

  return 'Hi from /api';
});
```

- **NEW** `getRequestIp` and `getRequestOrigin` utilities
- **PATCHED** `H4Event` params now correctly parses more than one param in the route string. e.g
  `'/user/:userId/profile/:projectId'`
- **PATCHED** all bugs in the behaviour of param routes.

## 0.2.0 (Minor)

- Added the `start` command to the CLI, `H4 start` which starts your app locally.

  ```powershell
  h4 start
  ```

  _or_

  ```powershell
  dart pub global run h4:start
  ```

  #### --dev flag

  - Run the command with the --dev flag to restart the server when you make changes to your files

- ### New Utilities
  - `getQuery`
  - `setResponseHeader`
  - `getHeader`

## 0.1.4

- #### Release

  - Added a basic CLI that bootstraps a H4 app

    - The H4 init command bootstraps a full H4 app.

    ```powershell
    dart pub global activate h4
    ```

    _then run_

    ```powershell
    h4 init
    ```

    _or_

    ```powershell
    dart pub global run h4:init
    ```

## 0.1.3

- ### Release
  - Deprecated app.onRequest() signature for registering middleware.
  - Added new signature for adding middleware to requests.
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
  - Error handling in async handlers has been refactored and improved.
  - Certain edge cases with wildcard routing patterns were addressed.
  - Stream (SSE) implementation removed for now to study StreamSinks.

## 0.1.2

- ### Patch Release
  - Improved logic for re-assigning localhost port to start server on when designated port is in
    use.
  - Added a naive stream (SSE) implementation.

## 0.1.1

- ### Patch Release
  - When the port assigned to server is taken, it now informs you that the port is taken and tries
    to start the server on port - (previousPort + 1).
  - Improved documentation comments for the added utilities in the last release.

## 0.1.0

- ### First Minor Release
  - Added new `getQueryParams` utility for extracting query params in the request URL
  - Added new `getHeader` utility to get specific headers from the incoming request
  - Added new `getRequestHeaders` utility to get all defined request headers
  - Added new `setResponseHeaders` utility to manually set response headers

## 0.0.5

- ### New & Improved

  - Improved internal composition for handling responses of different response types and setting
    content type headers.

  - Improved error handling when `Futures` are returned from handlers.

  - New `readRequestBody` utility - Can only read _json_ and _text_ right now. Support for more body
    types to be added.
    ```dart
    router.post("/vamos", (event) async {
      var body = await readRequestBody(event);
      return body;
    });
    ```

- ### TODO
  - Allow handler to set content type of response with `setResponseHeaders` utility.

## 0.0.4

- #### New

  - Improved error handling for asynchronous event handlers - Throwing an error in an async handler
    won't kill the process. It sends a JSON payload instead.

    ```json
    {
      "message": "Error message",
      "statusMessage": "Internal server error",
      "statusCode": 500
    }
    ```

    TODO - onError handler does not run when errors are thrown async event handlers. (Fix in next
    few patches)

  - Support for extended server configuration : You can now specify if you want to start
    automatically or not. In the future you will be able to pass your own customer server and listen
    to requests with H4.

    ```dart
      void main() async {
        var app = createApp(port: 4000, autoStart: false);
        await app.start().then((h4) => print('App is running on ${h4?.port}'));
        var router = createRouter();
        app.use(router)
      };
    ```

## 0.0.3

- #### New

  - Breaking Changes to **onError** middleware.

    - The function passed to onError Middleware now has access to the error object (in string form),
      the stacktrace of the error (also in string form) and the event that triggered the error.

      ```dart
      h4.onError((String error, String stackTrace, H4Event event) {
        // Log the error to a service like sentry.
        logErrorToService(error, stackTrace, event.path);
      });
      ```

    - Documentation comments for public and internal API's including the H4 Class,
      defineEventHandler, H4Event and H4Router.

## 0.0.2

- #### New

  - requestBody utility: The first H4 utility function (readBody) is underway but not ready for
    production use.

    - Improved implementation of parseRequestBody correctly parses request body in non-binary,
      non-file formats as a string and returns the value.

  - Documentation for **H4 router**

  - Documentation and type definitions **event handler**

    - Renamed **HandlerFunc** type definition to **EventHandler**
    - Added documentation for **Event Handler** functions.

  - Made router[requestMethod] instances generic for increased type safety.

    ```dart
      // This gives an error.
      router.get<String>("/25/**", (event) => true);

      // This is valid
      router.get<bool>("/25/**", (event) => true);
    ```

  - Improved predictability of event handler responses: You can now return more types of values from
    event handlers.

  - Removed unecessary logs.

  - Used logger library when necessary to log.

- #### Improved

  - CreateError Utility : It now uses named parameters for message and errorCode.

  ```dart
   router.get("/vamos", (event) {
   throw CreateError(message: 'Error occured', errorCode: 400);
  });
  ```

## 0.0.1

- Initial development release.

### Retraction Notice

Previous releases and versions 1.0.0, 1.0.1 and 1.1.0 were retracted due to immature development on
the author's part.

Apologies for any distruptions, we are now prioritizing mature and stable development over speed.
