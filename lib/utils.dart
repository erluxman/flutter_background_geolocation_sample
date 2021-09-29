import 'package:pretty_json/pretty_json.dart';

extension PrettyString on String {
  String get pretty {
    return prettyJson(this, indent: 2);
  }
}
