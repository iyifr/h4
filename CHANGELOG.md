## 0.0.1

- Initial development release.

## [1.0.0] - 2024-05-29

- Initial Stable Release

#### Breaking Changes

- The createError exception in the http library now expects the error message as a String and the
  error code as an int, instead of a Map<String, dynamic> containing these two values. The signature
  has changed from createError(Map<String, dynamic> errorData) to createError(String message, int?
  errorCode). Where error code defaults to 400.

#### Added

- onError and onRequest middleware.
- Awaiting the result of asynchronous Event Handlers.
