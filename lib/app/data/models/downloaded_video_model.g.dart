// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloaded_video_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadedVideoModelAdapter extends TypeAdapter<DownloadedVideoModel> {
  @override
  final int typeId = 1;

  @override
  DownloadedVideoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadedVideoModel(
      lessonId: fields[0] as int,
      lessonName: fields[1] as String,
      videoUrl: fields[2] as String,
      localPath: fields[3] as String,
      fileSize: fields[4] as int,
      downloadDate: fields[5] as DateTime,
      thumbnailPath: fields[6] as String?,
      userId: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadedVideoModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.lessonId)
      ..writeByte(1)
      ..write(obj.lessonName)
      ..writeByte(2)
      ..write(obj.videoUrl)
      ..writeByte(3)
      ..write(obj.localPath)
      ..writeByte(4)
      ..write(obj.fileSize)
      ..writeByte(5)
      ..write(obj.downloadDate)
      ..writeByte(6)
      ..write(obj.thumbnailPath)
      ..writeByte(7)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadedVideoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
