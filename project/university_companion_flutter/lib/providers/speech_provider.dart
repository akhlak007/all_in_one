import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

final speechProvider = StateNotifierProvider<SpeechNotifier, bool>((ref) {
  return SpeechNotifier();
});

class SpeechNotifier extends StateNotifier<bool> {
  final SpeechToText _speech = SpeechToText();
  String _recognizedText = '';
  
  SpeechNotifier() : super(false) {
    _initSpeech();
  }
  
  Future<void> _initSpeech() async {
    state = await _speech.initialize();
  }
  
  Future<void> startListening() async {
    _recognizedText = '';
    
    if (state) {
      await _speech.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: 'en_US',
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    }
  }
  
  Future<String?> stopListening() async {
    await _speech.stop();
    return _recognizedText.isNotEmpty ? _recognizedText : null;
  }
  
  bool get isAvailable => state;
}