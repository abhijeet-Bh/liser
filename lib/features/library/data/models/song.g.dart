// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 1;

  @override
  Song read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Song(
      id: fields[0] as String,
      path: fields[1] as String,
      fileName: fields[2] as String,
      title: fields[3] as String,
      artist: fields[4] as String,
      album: fields[5] as String,
      albumArtist: fields[6] as String,
      genre: fields[7] as String,
      trackNumber: fields[8] as int,
      discNumber: fields[9] as int,
      year: fields[10] as int,
      duration: fields[11] as int,
      fileSize: fields[12] as int,
      lastModified: fields[13] as DateTime,
      favorite: fields[14] as bool,
      playCount: fields[15] as int,
      lastPlayed: fields[16] as DateTime?,
      artworkPath: fields[17] as String?,
      isLossless: fields[18] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.artist)
      ..writeByte(5)
      ..write(obj.album)
      ..writeByte(6)
      ..write(obj.albumArtist)
      ..writeByte(7)
      ..write(obj.genre)
      ..writeByte(8)
      ..write(obj.trackNumber)
      ..writeByte(9)
      ..write(obj.discNumber)
      ..writeByte(10)
      ..write(obj.year)
      ..writeByte(11)
      ..write(obj.duration)
      ..writeByte(12)
      ..write(obj.fileSize)
      ..writeByte(13)
      ..write(obj.lastModified)
      ..writeByte(14)
      ..write(obj.favorite)
      ..writeByte(15)
      ..write(obj.playCount)
      ..writeByte(16)
      ..write(obj.lastPlayed)
      ..writeByte(17)
      ..write(obj.artworkPath)
      ..writeByte(18)
      ..write(obj.isLossless);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
