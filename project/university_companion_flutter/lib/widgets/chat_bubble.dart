import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:university_companion/models/message.dart';
import 'dart:convert';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildMessageContent(context),
            ),
            
            // Timestamp
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 4, left: 8),
              child: Text(
                DateFormat('h:mm a').format(message.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: message.isUser
                      ? Colors.white.withOpacity(0.7)
                      : Colors.grey.shade600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: message.isUser ? Colors.white : null,
          ),
        );
        
      case MessageType.schedule:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: message.isUser ? Colors.white : null,
              ),
            ),
            if (message.metadata != null) ...[
              const SizedBox(height: 8),
              _buildScheduleCard(context, message.metadata!),
            ],
          ],
        );
        
      case MessageType.map:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: message.isUser ? Colors.white : null,
              ),
            ),
            if (message.metadata != null) ...[
              const SizedBox(height: 8),
              _buildMapCard(context, message.metadata!),
            ],
          ],
        );
        
      case MessageType.link:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: message.isUser ? Colors.white : null,
              ),
            ),
            if (message.metadata != null) ...[
              const SizedBox(height: 8),
              _buildLinkCard(context, message.metadata!),
            ],
          ],
        );
        
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: message.isUser ? Colors.white : null,
              ),
            ),
            if (message.metadata != null && message.metadata!['imageUrl'] != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.metadata!['imageUrl'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 48),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        );
        
      default:
        return Text(
          message.content,
          style: TextStyle(
            color: message.isUser ? Colors.white : null,
          ),
        );
    }
  }
  
  Widget _buildScheduleCard(BuildContext context, Map<String, dynamic> metadata) {
    final classes = metadata['classes'] as List<dynamic>? ?? [];
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              metadata['title'] ?? 'Schedule',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const Divider(height: 1),
          ...classes.map((cls) => ListTile(
            dense: true,
            title: Text(cls['name'] ?? ''),
            subtitle: Text('${cls['time'] ?? ''} • ${cls['location'] ?? ''}'),
            leading: const Icon(Icons.class_, color: Colors.blue),
          )),
        ],
      ),
    );
  }
  
  Widget _buildMapCard(BuildContext context, Map<String, dynamic> metadata) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              metadata['title'] ?? 'Location',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            dense: true,
            title: Text(metadata['name'] ?? ''),
            subtitle: Text(metadata['address'] ?? ''),
            leading: const Icon(Icons.location_on, color: Colors.green),
            trailing: IconButton(
              icon: const Icon(Icons.directions, color: Colors.green),
              onPressed: () {
                // TODO: Open directions
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLinkCard(BuildContext context, Map<String, dynamic> metadata) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        title: Text(metadata['title'] ?? 'Link'),
        subtitle: Text(metadata['url'] ?? ''),
        leading: const Icon(Icons.link, color: Colors.purple),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new, color: Colors.purple),
          onPressed: () {
            // TODO: Open URL
          },
        ),
      ),
    );
  }
}