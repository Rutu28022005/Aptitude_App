class ApiConfig {
  static const String openAiApiEndpoint =
      'https://api.openai.com/v1/chat/completions';
  static const String openAiModel = 'gpt-3.5-turbo';

  static String? _apiKey;

  static String get openAiApiKey {
    if (_apiKey == null || _apiKey!.trim().isEmpty) {
      throw Exception(
          'OpenAI API key not configured. Please check your .env file.');
    }
    return _apiKey!;
  }

  static void setApiKey(String key) {
    _apiKey = key;
  }
}