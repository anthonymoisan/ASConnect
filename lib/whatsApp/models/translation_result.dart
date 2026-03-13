class TranslationResult {
  final String detectedSourceLang;
  final String detectedSourceLangName;
  final String sentence;
  final bool success;
  final String targetLang;
  final String translatedText;

  const TranslationResult({
    required this.detectedSourceLang,
    required this.detectedSourceLangName,
    required this.sentence,
    required this.success,
    required this.targetLang,
    required this.translatedText,
  });

  factory TranslationResult.fromJson(Map<String, dynamic> json) {
    return TranslationResult(
      detectedSourceLang: (json['detected_source_lang'] ?? '') as String,
      detectedSourceLangName:
          (json['detected_source_lang_name'] ?? '') as String,
      sentence: (json['sentence'] ?? '') as String,
      success: (json['success'] ?? false) as bool,
      targetLang: (json['target_lang'] ?? '') as String,
      translatedText: (json['translated_text'] ?? '') as String,
    );
  }
}
