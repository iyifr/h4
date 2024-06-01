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

### 0.0.3

- #### New
