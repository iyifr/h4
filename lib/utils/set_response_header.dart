import 'package:h4/src/event.dart';

setResponseHeader(H4Event event,
    {required String header, required String value}) {
  event.node["value"]?.response.headers.add(header, value);
}
