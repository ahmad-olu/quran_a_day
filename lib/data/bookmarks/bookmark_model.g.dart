// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookmarkModelAdapter extends TypeAdapter<BookmarkModel> {
  @override
  final typeId = 0;

  @override
  BookmarkModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookmarkModel(
      pageNumber: (fields[0] as num).toInt(),
      surahNameLatin: fields[1] as String,
      surahNameArabic: fields[2] as String,
      ayahRange: fields[3] as String,
      savedAt: fields[4] as DateTime,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BookmarkModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.pageNumber)
      ..writeByte(1)
      ..write(obj.surahNameLatin)
      ..writeByte(2)
      ..write(obj.surahNameArabic)
      ..writeByte(3)
      ..write(obj.ayahRange)
      ..writeByte(4)
      ..write(obj.savedAt)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
