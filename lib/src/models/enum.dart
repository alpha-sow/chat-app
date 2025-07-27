enum MessageType { text, image, file, audio, video }

enum DiscussionEvent {
  messageAdded,
  messageEdited,
  messageDeleted,
  reactionAdded,
  reactionRemoved,
}

enum ParticipantEvent { participantAdded, participantRemoved }
