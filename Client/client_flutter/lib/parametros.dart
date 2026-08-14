// lib/constants.dart
import 'package:flutter/foundation.dart' show kIsWeb;

const String API_BASE_URL = kIsWeb
    ? "https://fake-news-detector.com/api"
    : "https://fake-news-detector.com";