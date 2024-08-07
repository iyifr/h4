## 0.0.1

- Initial development release.

### Retraction Notice

Previous releases and versions 1.0.0, 1.0.1 and 1.1.0 were retracted due to immature development on
the author's part.

Apologies for any distruptions, we are now prioritizing mature and stable development over speed.

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

## 0.1.0

- ### First Minor Release
  - Added new `getQueryParams` utility for extracting query params in the request URL
  - Added new `getHeader` utility to get specific headers from the incoming request
  - Added new `getRequestHeaders` utility to get all defined request headers
  - Added new `setResponseHeaders` utility to manually set response headers

## 0.1.1

- ### Patch Release
  - When the port assigned to server is taken, it now informs you that the port is taken and tries
    to start the server on port - (previousPort + 1).
  - Improved documentation comments for the added utilities in the last release.

## 0.1.2

- ### Patch Release
  - Improved logic for re-assigning localhost port to start server on when designated port is in
    use.
  - Added a naive stream (SSE) implementation.
