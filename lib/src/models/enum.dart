/// Types of messages that can be sent in a discussion.
enum MessageType { 
  /// Plain text message
  text, 
  /// Image/photo message
  image, 
  /// File attachment message
  file, 
  /// Audio message or voice note
  audio, 
  /// Video message
  video 
}

/// Events that can occur with messages in a discussion.
enum DiscussionEvent {
  /// A new message was added
  messageAdded,
  /// An existing message was edited
  messageEdited,
  /// A message was deleted
  messageDeleted,
  /// A reaction was added to a message
  reactionAdded,
  /// A reaction was removed from a message
  reactionRemoved,
}

/// Events related to participants in a discussion.
enum ParticipantEvent { 
  /// A new participant was added
  participantAdded, 
  /// A participant was removed
  participantRemoved 
}
