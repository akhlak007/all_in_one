/*import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:university_companion/models/message.dart';
import 'package:university_companion/models/event.dart';

class AIService {
  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: 'AIzaSyCK-MwuasrOOrrczlE8mOrFxgJIR0-aooA', // Replace with actual API key in production
  );
  
  Future<ChatbotResponse> getChatbotResponse(String query, List<Message> history) async {
    try {
      // Convert chat history to format expected by Gemini
      final chatHistory = history.map((message) {
        final role = message.isUser ? 'user' : 'model';
        final content = message.content;
        return Content.text(role == 'user' ? content : content);
      }).toList();
      
      // Create chat session
      final chat = _model.startChat(history: chatHistory);
      
      // Send query and get response
      final response = await chat.sendMessage(Content.text(query));
      final responseText = response.text ?? 'I couldn\'t generate a response.';
      
      // Check if response contains special formatting
      if (responseText.contains('[SCHEDULE]')) {
        // Extract schedule data
        final scheduleData = _extractScheduleData(responseText);
        return ChatbotResponse(
          content: scheduleData['message'] ?? responseText,
          type: MessageType.schedule,
          metadata: scheduleData['data'],
        );
      } else if (responseText.contains('[MAP]')) {
        // Extract map data
        final mapData = _extractMapData(responseText);
        return ChatbotResponse(
          content: mapData['message'] ?? responseText,
          type: MessageType.map,
          metadata: mapData['data'],
        );
      } else if (responseText.contains('[LINK]')) {
        // Extract link data
        final linkData = _extractLinkData(responseText);
        return ChatbotResponse(
          content: linkData['message'] ?? responseText,
          type: MessageType.link,
          metadata: linkData['data'],
        );
      }
      
      // Regular text response
      return ChatbotResponse(
        content: responseText,
        type: MessageType.text,
      );
    } catch (e) {
      return ChatbotResponse(
        content: 'Sorry, I encountered an error: $e',
        type: MessageType.text,
      );
    }
  }
  
  Future<List<Event>> getRecommendedEvents({
    required List<Event> events,
    required Map<String, dynamic> userPreferences,
  }) async {
    try {
      // Prepare events data for the AI
      final eventsData = events.map((event) => {
        'id': event.id,
        'title': event.title,
        'category': event.category,
        'tags': event.tags,
        'date': event.date.toIso8601String(),
      }).toList();
      
      // Create prompt for event recommendations
      final prompt = '''
        Based on the user preferences and the list of events, recommend the top 5 events that would be most relevant to the user.
        User preferences: ${userPreferences.toString()}
        Events: ${eventsData.toString()}
        Return only the IDs of the recommended events as a JSON array.
      ''';
      
      // Get recommendations from AI
      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '[]';
      
      // Extract event IDs from response
      final List<dynamic> recommendedIds = _extractJsonArray(responseText);
      
      // Filter events based on recommended IDs
      return events.where((event) => recommendedIds.contains(event.id)).toList();
    } catch (e) {
      // If recommendation fails, return upcoming events as fallback
      final now = DateTime.now();
      return events
          .where((event) => event.date.isAfter(now))
          .take(5)
          .toList();
    }
  }
  
  Map<String, dynamic> _extractScheduleData(String text) {
    // Extract schedule data between [SCHEDULE] and [/SCHEDULE] tags
    final regex = RegExp(r'\[SCHEDULE\](.*?)\[\/SCHEDULE\]', dotAll: true);
    final match = regex.firstMatch(text);
    
    if (match != null) {
      try {
        final jsonStr = match.group(1)?.trim();
        final data = jsonDecode(jsonStr!);
        final message = text.replaceAll(regex, '').trim();
        
        return {
          'message': message,
          'data': data,
        };
      } catch (e) {
        return {'message': text};
      }
    }
    
    return {'message': text};
  }
  
  Map<String, dynamic> _extractMapData(String text) {
    // Extract map data between [MAP] and [/MAP] tags
    final regex = RegExp(r'\[MAP\](.*?)\[\/MAP\]', dotAll: true);
    final match = regex.firstMatch(text);
    
    if (match != null) {
      try {
        final jsonStr = match.group(1)?.trim();
        final data = jsonDecode(jsonStr!);
        final message = text.replaceAll(regex, '').trim();
        
        return {
          'message': message,
          'data': data,
        };
      } catch (e) {
        return {'message': text};
      }
    }
    
    return {'message': text};
  }
  
  Map<String, dynamic> _extractLinkData(String text) {
    // Extract link data between [LINK] and [/LINK] tags
    final regex = RegExp(r'\[LINK\](.*?)\[\/LINK\]', dotAll: true);
    final match = regex.firstMatch(text);
    
    if (match != null) {
      try {
        final jsonStr = match.group(1)?.trim();
        final data = jsonDecode(jsonStr!);
        final message = text.replaceAll(regex, '').trim();
        
        return {
          'message': message,
          'data': data,
        };
      } catch (e) {
        return {'message': text};
      }
    }
    
    return {'message': text};
  }
  
  List<dynamic> _extractJsonArray(String text) {
    try {
      // Find JSON array in text
      final regex = RegExp(r'\[.*?\]', dotAll: true);
      final match = regex.firstMatch(text);
      
      if (match != null) {
        final jsonStr = match.group(0);
        return jsonDecode(jsonStr!);
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
}

class ChatbotResponse {
  final String content;
  final MessageType type;
  final Map<String, dynamic>? metadata;
  
  ChatbotResponse({
    required this.content,
    required this.type,
    this.metadata,
  });
}*/
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For securing API key
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:university_companion/models/message.dart';
import 'package:university_companion/models/event.dart';

class AIService {
  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: dotenv.env['GEMINI_API_KEY'] ?? '', // Secure API key from .env
  );

  Future<ChatbotResponse> getChatbotResponse(String query, List<Message> history) async {
    try {
      final chatHistory = history.map((message) {
        return Content.text(message.isUser ? message.content : message.content);
      }).toList();

      final chat = _model.startChat(history: chatHistory);
      final response = await chat.sendMessage(Content.text(query));
      final responseText = response.text?.trim() ?? 'I couldn\'t generate a response.';

      return _parseResponse(responseText);
    } catch (e) {
      return ChatbotResponse(
        content: 'Sorry, I encountered an error: ${e.toString()}',
        type: MessageType.text,
      );
    }
  }

  Future<List<Event>> getRecommendedEvents({
    required List<Event> events,
    required Map<String, dynamic> userPreferences,
  }) async {
    try {
      final eventsData = events.map((event) => {
        'id': event.id,
        'title': event.title,
        'category': event.category,
        'tags': event.tags,
        'date': event.date.toIso8601String(),
      }).toList();

      final prompt = '''
        Recommend the top 5 events most relevant to the user.
        User preferences: ${jsonEncode(userPreferences)}
        Events: ${jsonEncode(eventsData)}
        Return only the IDs of the recommended events in a JSON array.
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final recommendedIds = _extractJsonArray(response.text ?? '[]');

      return events.where((event) => recommendedIds.contains(event.id)).toList();
    } catch (e) {
      return events.where((event) => event.date.isAfter(DateTime.now())).take(5).toList();
    }
  }

  ChatbotResponse _parseResponse(String responseText) {
    if (responseText.contains('[SCHEDULE]')) {
      return _parseStructuredResponse(responseText, 'SCHEDULE', MessageType.schedule);
    } else if (responseText.contains('[MAP]')) {
      return _parseStructuredResponse(responseText, 'MAP', MessageType.map);
    } else if (responseText.contains('[LINK]')) {
      return _parseStructuredResponse(responseText, 'LINK', MessageType.link);
    } else {
      return ChatbotResponse(content: responseText, type: MessageType.text);
    }
  }

  ChatbotResponse _parseStructuredResponse(String text, String tag, MessageType type) {
    final regex = RegExp(r'\[' + tag + r'\](.*?)\[\/' + tag + r'\]', dotAll: true);
    final match = regex.firstMatch(text);

    if (match != null) {
      try {
        final data = jsonDecode(match.group(1)!.trim());
        final message = text.replaceAll(regex, '').trim();
        return ChatbotResponse(content: message, type: type, metadata: data);
      } catch (_) {
        return ChatbotResponse(content: text, type: MessageType.text);
      }
    }
    return ChatbotResponse(content: text, type: MessageType.text);
  }

  List<dynamic> _extractJsonArray(String text) {
    try {
      final regex = RegExp(r'\[.*?\]', dotAll: true);
      final match = regex.firstMatch(text);
      return match != null ? jsonDecode(match.group(0)!) : [];
    } catch (_) {
      return [];
    }
  }
}

class ChatbotResponse {
  final String content;
  final MessageType type;
  final Map<String, dynamic>? metadata;

  ChatbotResponse({
    required this.content,
    required this.type,
    this.metadata,
  });
}
