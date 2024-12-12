class FormData {
  final Map<String, List<FormDataEntry>> _data = {};

  void append(String name, dynamic value,
      {String? filename, String? contentType}) {
    _data.putIfAbsent(name, () => []).add(FormDataEntry(
        value: value, filename: filename, contentType: contentType));
  }

  void set(String name, dynamic value,
      {String? filename, String? contentType}) {
    _data[name] = [
      FormDataEntry(value: value, filename: filename, contentType: contentType)
    ];
  }

  bool has(String name) {
    return _data.containsKey(name);
  }

  void delete(String name) {
    _data.remove(name);
  }

  List<String> keys() {
    return _data.keys.toList();
  }

  List<List<FormDataEntry>> values() {
    return _data.values.toList();
  }

  List<MapEntry<String, List<FormDataEntry>>> entries() {
    return _data.entries.toList();
  }

  dynamic get(String name) {
    final values = _data[name];
    if (values?.isNotEmpty == true) {
      return values!.first.value;
    }
    return null;
  }

  List<dynamic>? getAll(String name) {
    return _data[name]?.map((entry) => entry.value).toList();
  }

  @override
  String toString() {
    return _data.toString();
  }
}

class FormDataEntry {
  final dynamic value;
  final String? filename;
  final String? contentType;

  FormDataEntry({required this.value, this.filename, this.contentType});

  @override
  String toString() {
    if (filename != null) {
      return 'File: $filename ($contentType)';
    }
    return value.toString();
  }
}
