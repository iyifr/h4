```dart
import 'package:h4/create.dart';

void main() {
  var app = createApp();
  var router = createRouter();

  app.use(router);

  router.get("/", (event) => "Hello world!");
}
```
