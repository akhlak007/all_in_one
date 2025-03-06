import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_companion/models/message.dart';
import 'package:university_companion/services/ai_service.dart';
import 'package:uuid/uuid.dart';

final aiService = AIService();
final uuid = Uuid();

final chatbotProvider = StateNotifierProvider<ChatbotNotifier, List<Message>>((ref) {
  return ChatbotNotifier(ref);
});

final chatbotTypingProvider = StateProvider<bool>((ref) => false);

class ChatbotNotifier extends StateNotifier<List<Message>> {
  final Ref _ref;
  
  ChatbotNotifier(this._ref) : super([]);
  
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    // Add user message
    final userMessage = Message(
      id: uuid.v4(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    state = [...state, userMessage];
    
    // Set typing indicator
    _ref.read(chatbotTypingProvider.notifier).state = true;
    
    try {
      // Get AI response
      final response = await aiService.getChatbotResponse(content, state);
      
      // Add AI message
      final aiMessage = Message(
        id: uuid.v4(),
        content: response.content,
        isUser: false,
        timestamp: DateTime.now(),
        type: response.type,
        metadata: response.metadata,
      );
      
      state = [...state, aiMessage];
    } catch (e) {
      // Add error message
      final errorMessage = Message(
        id: uuid.v4(),
        content: 'Sorry, I encountered an error. Please try again later.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      state = [...state, errorMessage];
    } finally {
      // Remove typing indicator
      _ref.read(chatbotTypingProvider.notifier).state = false;
    }
  }
  
  void clearChat() {
    state = [];
  }
}