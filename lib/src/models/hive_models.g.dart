// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveMessageAdapter extends TypeAdapter<HiveMessage> {
  @override
  final int typeId = 0;

  @override
  HiveMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveMessage(
      messageId: fields[0] as String,
      discussionId: fields[1] as String,
      senderId: fields[2] as String,
      content: fields[3] as String,
      typeIndex: fields[4] as int,
      timestamp: fields[5] as DateTime,
      edited: fields[6] as bool,
      editedAt: fields[7] as DateTime?,
      reactionsJson: fields[8] as String?,
      replyToId: fields[9] as String?,
      replyIds: (fields[10] as List).cast<String>(),
      readByIds: (fields[11] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveMessage obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.messageId)
      ..writeByte(1)
      ..write(obj.discussionId)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.typeIndex)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.edited)
      ..writeByte(7)
      ..write(obj.editedAt)
      ..writeByte(8)
      ..write(obj.reactionsJson)
      ..writeByte(9)
      ..write(obj.replyToId)
      ..writeByte(10)
      ..write(obj.replyIds)
      ..writeByte(11)
      ..write(obj.readByIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveDiscussionAdapter extends TypeAdapter<HiveDiscussion> {
  @override
  final int typeId = 1;

  @override
  HiveDiscussion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveDiscussion(
      discussionId: fields[0] as String,
      title: fields[1] as String,
      createdAt: fields[3] as DateTime,
      lastActivity: fields[4] as DateTime,
      participantIds: (fields[2] as List).cast<String>(),
      isActive: fields[5] as bool,
      lastMessageJson: fields[6] as String?,
      typeIndex: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HiveDiscussion obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.discussionId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.participantIds)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.lastActivity)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.lastMessageJson)
      ..writeByte(7)
      ..write(obj.typeIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveDiscussionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveUserAdapter extends TypeAdapter<HiveUser> {
  @override
  final int typeId = 2;

  @override
  HiveUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveUser(
      userId: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String?,
      phoneNumber: fields[3] as String?,
      avatarUrl: fields[4] as String?,
      isOnline: fields[5] as bool,
      status: fields[6] as String,
      lastSeen: fields[7] as DateTime?,
      metadataJson: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveUser obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.avatarUrl)
      ..writeByte(5)
      ..write(obj.isOnline)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.lastSeen)
      ..writeByte(8)
      ..write(obj.metadataJson);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
