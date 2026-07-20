// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SongsTable extends Songs with TableInfo<$SongsTable, SongData>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$SongsTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _pathMeta = const VerificationMeta('path');
@override
late final GeneratedColumn<String> path = GeneratedColumn<String>('path', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _fileNameMeta = const VerificationMeta('fileName');
@override
late final GeneratedColumn<String> fileName = GeneratedColumn<String>('file_name', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _titleMeta = const VerificationMeta('title');
@override
late final GeneratedColumn<String> title = GeneratedColumn<String>('title', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _artistMeta = const VerificationMeta('artist');
@override
late final GeneratedColumn<String> artist = GeneratedColumn<String>('artist', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _albumMeta = const VerificationMeta('album');
@override
late final GeneratedColumn<String> album = GeneratedColumn<String>('album', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _albumArtistMeta = const VerificationMeta('albumArtist');
@override
late final GeneratedColumn<String> albumArtist = GeneratedColumn<String>('album_artist', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _genreMeta = const VerificationMeta('genre');
@override
late final GeneratedColumn<String> genre = GeneratedColumn<String>('genre', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _trackNumberMeta = const VerificationMeta('trackNumber');
@override
late final GeneratedColumn<int> trackNumber = GeneratedColumn<int>('track_number', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
static const VerificationMeta _discNumberMeta = const VerificationMeta('discNumber');
@override
late final GeneratedColumn<int> discNumber = GeneratedColumn<int>('disc_number', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
static const VerificationMeta _yearMeta = const VerificationMeta('year');
@override
late final GeneratedColumn<int> year = GeneratedColumn<int>('year', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
static const VerificationMeta _durationMeta = const VerificationMeta('duration');
@override
late final GeneratedColumn<int> duration = GeneratedColumn<int>('duration', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
static const VerificationMeta _fileSizeMeta = const VerificationMeta('fileSize');
@override
late final GeneratedColumn<int> fileSize = GeneratedColumn<int>('file_size', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
static const VerificationMeta _lastModifiedMeta = const VerificationMeta('lastModified');
@override
late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>('last_modified', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
static const VerificationMeta _favoriteMeta = const VerificationMeta('favorite');
@override
late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>('favorite', aliasedName, false, type: DriftSqlType.bool, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("favorite" IN (0, 1))'), defaultValue: const Constant(false));
static const VerificationMeta _playCountMeta = const VerificationMeta('playCount');
@override
late final GeneratedColumn<int> playCount = GeneratedColumn<int>('play_count', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(0));
static const VerificationMeta _lastPlayedMeta = const VerificationMeta('lastPlayed');
@override
late final GeneratedColumn<DateTime> lastPlayed = GeneratedColumn<DateTime>('last_played', aliasedName, true, type: DriftSqlType.dateTime, requiredDuringInsert: false);
static const VerificationMeta _artworkPathMeta = const VerificationMeta('artworkPath');
@override
late final GeneratedColumn<String> artworkPath = GeneratedColumn<String>('artwork_path', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
static const VerificationMeta _isLosslessMeta = const VerificationMeta('isLossless');
@override
late final GeneratedColumn<bool> isLossless = GeneratedColumn<bool>('is_lossless', aliasedName, false, type: DriftSqlType.bool, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_lossless" IN (0, 1))'), defaultValue: const Constant(false));
static const VerificationMeta _dateAddedMeta = const VerificationMeta('dateAdded');
@override
late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>('date_added', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: false, defaultValue: currentDateAndTime);
static const VerificationMeta _sourceModeMeta = const VerificationMeta('sourceMode');
@override
late final GeneratedColumn<String> sourceMode = GeneratedColumn<String>('source_mode', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: false, defaultValue: const Constant('local'));
@override
List<GeneratedColumn> get $columns => [id, path, fileName, title, artist, album, albumArtist, genre, trackNumber, discNumber, year, duration, fileSize, lastModified, favorite, playCount, lastPlayed, artworkPath, isLossless, dateAdded, sourceMode];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'songs';
@override
VerificationContext validateIntegrity(Insertable<SongData> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));} else if (isInserting) {
context.missing(_idMeta);
}
if (data.containsKey('path')) {
context.handle(_pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));} else if (isInserting) {
context.missing(_pathMeta);
}
if (data.containsKey('file_name')) {
context.handle(_fileNameMeta, fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));} else if (isInserting) {
context.missing(_fileNameMeta);
}
if (data.containsKey('title')) {
context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));} else if (isInserting) {
context.missing(_titleMeta);
}
if (data.containsKey('artist')) {
context.handle(_artistMeta, artist.isAcceptableOrUnknown(data['artist']!, _artistMeta));} else if (isInserting) {
context.missing(_artistMeta);
}
if (data.containsKey('album')) {
context.handle(_albumMeta, album.isAcceptableOrUnknown(data['album']!, _albumMeta));} else if (isInserting) {
context.missing(_albumMeta);
}
if (data.containsKey('album_artist')) {
context.handle(_albumArtistMeta, albumArtist.isAcceptableOrUnknown(data['album_artist']!, _albumArtistMeta));} else if (isInserting) {
context.missing(_albumArtistMeta);
}
if (data.containsKey('genre')) {
context.handle(_genreMeta, genre.isAcceptableOrUnknown(data['genre']!, _genreMeta));} else if (isInserting) {
context.missing(_genreMeta);
}
if (data.containsKey('track_number')) {
context.handle(_trackNumberMeta, trackNumber.isAcceptableOrUnknown(data['track_number']!, _trackNumberMeta));} else if (isInserting) {
context.missing(_trackNumberMeta);
}
if (data.containsKey('disc_number')) {
context.handle(_discNumberMeta, discNumber.isAcceptableOrUnknown(data['disc_number']!, _discNumberMeta));} else if (isInserting) {
context.missing(_discNumberMeta);
}
if (data.containsKey('year')) {
context.handle(_yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));} else if (isInserting) {
context.missing(_yearMeta);
}
if (data.containsKey('duration')) {
context.handle(_durationMeta, duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));} else if (isInserting) {
context.missing(_durationMeta);
}
if (data.containsKey('file_size')) {
context.handle(_fileSizeMeta, fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));} else if (isInserting) {
context.missing(_fileSizeMeta);
}
if (data.containsKey('last_modified')) {
context.handle(_lastModifiedMeta, lastModified.isAcceptableOrUnknown(data['last_modified']!, _lastModifiedMeta));} else if (isInserting) {
context.missing(_lastModifiedMeta);
}
if (data.containsKey('favorite')) {
context.handle(_favoriteMeta, favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta));}if (data.containsKey('play_count')) {
context.handle(_playCountMeta, playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta));}if (data.containsKey('last_played')) {
context.handle(_lastPlayedMeta, lastPlayed.isAcceptableOrUnknown(data['last_played']!, _lastPlayedMeta));}if (data.containsKey('artwork_path')) {
context.handle(_artworkPathMeta, artworkPath.isAcceptableOrUnknown(data['artwork_path']!, _artworkPathMeta));}if (data.containsKey('is_lossless')) {
context.handle(_isLosslessMeta, isLossless.isAcceptableOrUnknown(data['is_lossless']!, _isLosslessMeta));}if (data.containsKey('date_added')) {
context.handle(_dateAddedMeta, dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta));}if (data.containsKey('source_mode')) {
context.handle(_sourceModeMeta, sourceMode.isAcceptableOrUnknown(data['source_mode']!, _sourceModeMeta));}return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override SongData map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return SongData(id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!, path: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}path'])!, fileName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}file_name'])!, title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!, artist: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}artist'])!, album: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}album'])!, albumArtist: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}album_artist'])!, genre: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}genre'])!, trackNumber: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}track_number'])!, discNumber: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}disc_number'])!, year: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}year'])!, duration: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}duration'])!, fileSize: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}file_size'])!, lastModified: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}last_modified'])!, favorite: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}favorite'])!, playCount: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}play_count'])!, lastPlayed: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}last_played']), artworkPath: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}artwork_path']), isLossless: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_lossless'])!, dateAdded: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}date_added'])!, sourceMode: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}source_mode'])!, );
}
@override
$SongsTable createAlias(String alias) {
return $SongsTable(attachedDatabase, alias);}}class SongData extends DataClass implements Insertable<SongData> 
{
final String id;
final String path;
final String fileName;
final String title;
final String artist;
final String album;
final String albumArtist;
final String genre;
final int trackNumber;
final int discNumber;
final int year;
final int duration;
final int fileSize;
final DateTime lastModified;
final bool favorite;
final int playCount;
final DateTime? lastPlayed;
final String? artworkPath;
final bool isLossless;
final DateTime dateAdded;
final String sourceMode;
const SongData({required this.id, required this.path, required this.fileName, required this.title, required this.artist, required this.album, required this.albumArtist, required this.genre, required this.trackNumber, required this.discNumber, required this.year, required this.duration, required this.fileSize, required this.lastModified, required this.favorite, required this.playCount, this.lastPlayed, this.artworkPath, required this.isLossless, required this.dateAdded, required this.sourceMode});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<String>(id);
map['path'] = Variable<String>(path);
map['file_name'] = Variable<String>(fileName);
map['title'] = Variable<String>(title);
map['artist'] = Variable<String>(artist);
map['album'] = Variable<String>(album);
map['album_artist'] = Variable<String>(albumArtist);
map['genre'] = Variable<String>(genre);
map['track_number'] = Variable<int>(trackNumber);
map['disc_number'] = Variable<int>(discNumber);
map['year'] = Variable<int>(year);
map['duration'] = Variable<int>(duration);
map['file_size'] = Variable<int>(fileSize);
map['last_modified'] = Variable<DateTime>(lastModified);
map['favorite'] = Variable<bool>(favorite);
map['play_count'] = Variable<int>(playCount);
if (!nullToAbsent || lastPlayed != null){map['last_played'] = Variable<DateTime>(lastPlayed);
}if (!nullToAbsent || artworkPath != null){map['artwork_path'] = Variable<String>(artworkPath);
}map['is_lossless'] = Variable<bool>(isLossless);
map['date_added'] = Variable<DateTime>(dateAdded);
map['source_mode'] = Variable<String>(sourceMode);
return map; 
}
SongsCompanion toCompanion(bool nullToAbsent) {
return SongsCompanion(id: Value(id),path: Value(path),fileName: Value(fileName),title: Value(title),artist: Value(artist),album: Value(album),albumArtist: Value(albumArtist),genre: Value(genre),trackNumber: Value(trackNumber),discNumber: Value(discNumber),year: Value(year),duration: Value(duration),fileSize: Value(fileSize),lastModified: Value(lastModified),favorite: Value(favorite),playCount: Value(playCount),lastPlayed: lastPlayed == null && nullToAbsent ? const Value.absent() : Value(lastPlayed),artworkPath: artworkPath == null && nullToAbsent ? const Value.absent() : Value(artworkPath),isLossless: Value(isLossless),dateAdded: Value(dateAdded),sourceMode: Value(sourceMode),);
}
factory SongData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return SongData(id: serializer.fromJson<String>(json['id']),path: serializer.fromJson<String>(json['path']),fileName: serializer.fromJson<String>(json['fileName']),title: serializer.fromJson<String>(json['title']),artist: serializer.fromJson<String>(json['artist']),album: serializer.fromJson<String>(json['album']),albumArtist: serializer.fromJson<String>(json['albumArtist']),genre: serializer.fromJson<String>(json['genre']),trackNumber: serializer.fromJson<int>(json['trackNumber']),discNumber: serializer.fromJson<int>(json['discNumber']),year: serializer.fromJson<int>(json['year']),duration: serializer.fromJson<int>(json['duration']),fileSize: serializer.fromJson<int>(json['fileSize']),lastModified: serializer.fromJson<DateTime>(json['lastModified']),favorite: serializer.fromJson<bool>(json['favorite']),playCount: serializer.fromJson<int>(json['playCount']),lastPlayed: serializer.fromJson<DateTime?>(json['lastPlayed']),artworkPath: serializer.fromJson<String?>(json['artworkPath']),isLossless: serializer.fromJson<bool>(json['isLossless']),dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),sourceMode: serializer.fromJson<String>(json['sourceMode']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<String>(id),'path': serializer.toJson<String>(path),'fileName': serializer.toJson<String>(fileName),'title': serializer.toJson<String>(title),'artist': serializer.toJson<String>(artist),'album': serializer.toJson<String>(album),'albumArtist': serializer.toJson<String>(albumArtist),'genre': serializer.toJson<String>(genre),'trackNumber': serializer.toJson<int>(trackNumber),'discNumber': serializer.toJson<int>(discNumber),'year': serializer.toJson<int>(year),'duration': serializer.toJson<int>(duration),'fileSize': serializer.toJson<int>(fileSize),'lastModified': serializer.toJson<DateTime>(lastModified),'favorite': serializer.toJson<bool>(favorite),'playCount': serializer.toJson<int>(playCount),'lastPlayed': serializer.toJson<DateTime?>(lastPlayed),'artworkPath': serializer.toJson<String?>(artworkPath),'isLossless': serializer.toJson<bool>(isLossless),'dateAdded': serializer.toJson<DateTime>(dateAdded),'sourceMode': serializer.toJson<String>(sourceMode),};}SongData copyWith({String? id,String? path,String? fileName,String? title,String? artist,String? album,String? albumArtist,String? genre,int? trackNumber,int? discNumber,int? year,int? duration,int? fileSize,DateTime? lastModified,bool? favorite,int? playCount,Value<DateTime?> lastPlayed = const Value.absent(),Value<String?> artworkPath = const Value.absent(),bool? isLossless,DateTime? dateAdded,String? sourceMode}) => SongData(id: id ?? this.id,path: path ?? this.path,fileName: fileName ?? this.fileName,title: title ?? this.title,artist: artist ?? this.artist,album: album ?? this.album,albumArtist: albumArtist ?? this.albumArtist,genre: genre ?? this.genre,trackNumber: trackNumber ?? this.trackNumber,discNumber: discNumber ?? this.discNumber,year: year ?? this.year,duration: duration ?? this.duration,fileSize: fileSize ?? this.fileSize,lastModified: lastModified ?? this.lastModified,favorite: favorite ?? this.favorite,playCount: playCount ?? this.playCount,lastPlayed: lastPlayed.present ? lastPlayed.value : this.lastPlayed,artworkPath: artworkPath.present ? artworkPath.value : this.artworkPath,isLossless: isLossless ?? this.isLossless,dateAdded: dateAdded ?? this.dateAdded,sourceMode: sourceMode ?? this.sourceMode,);SongData copyWithCompanion(SongsCompanion data) {
return SongData(
id: data.id.present ? data.id.value : this.id,path: data.path.present ? data.path.value : this.path,fileName: data.fileName.present ? data.fileName.value : this.fileName,title: data.title.present ? data.title.value : this.title,artist: data.artist.present ? data.artist.value : this.artist,album: data.album.present ? data.album.value : this.album,albumArtist: data.albumArtist.present ? data.albumArtist.value : this.albumArtist,genre: data.genre.present ? data.genre.value : this.genre,trackNumber: data.trackNumber.present ? data.trackNumber.value : this.trackNumber,discNumber: data.discNumber.present ? data.discNumber.value : this.discNumber,year: data.year.present ? data.year.value : this.year,duration: data.duration.present ? data.duration.value : this.duration,fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,lastModified: data.lastModified.present ? data.lastModified.value : this.lastModified,favorite: data.favorite.present ? data.favorite.value : this.favorite,playCount: data.playCount.present ? data.playCount.value : this.playCount,lastPlayed: data.lastPlayed.present ? data.lastPlayed.value : this.lastPlayed,artworkPath: data.artworkPath.present ? data.artworkPath.value : this.artworkPath,isLossless: data.isLossless.present ? data.isLossless.value : this.isLossless,dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,sourceMode: data.sourceMode.present ? data.sourceMode.value : this.sourceMode,);
}
@override
String toString() {return (StringBuffer('SongData(')..write('id: $id, ')..write('path: $path, ')..write('fileName: $fileName, ')..write('title: $title, ')..write('artist: $artist, ')..write('album: $album, ')..write('albumArtist: $albumArtist, ')..write('genre: $genre, ')..write('trackNumber: $trackNumber, ')..write('discNumber: $discNumber, ')..write('year: $year, ')..write('duration: $duration, ')..write('fileSize: $fileSize, ')..write('lastModified: $lastModified, ')..write('favorite: $favorite, ')..write('playCount: $playCount, ')..write('lastPlayed: $lastPlayed, ')..write('artworkPath: $artworkPath, ')..write('isLossless: $isLossless, ')..write('dateAdded: $dateAdded, ')..write('sourceMode: $sourceMode')..write(')')).toString();}
@override
 int get hashCode => Object.hashAll([id, path, fileName, title, artist, album, albumArtist, genre, trackNumber, discNumber, year, duration, fileSize, lastModified, favorite, playCount, lastPlayed, artworkPath, isLossless, dateAdded, sourceMode]);@override
bool operator ==(Object other) => identical(this, other) || (other is SongData && other.id == this.id && other.path == this.path && other.fileName == this.fileName && other.title == this.title && other.artist == this.artist && other.album == this.album && other.albumArtist == this.albumArtist && other.genre == this.genre && other.trackNumber == this.trackNumber && other.discNumber == this.discNumber && other.year == this.year && other.duration == this.duration && other.fileSize == this.fileSize && other.lastModified == this.lastModified && other.favorite == this.favorite && other.playCount == this.playCount && other.lastPlayed == this.lastPlayed && other.artworkPath == this.artworkPath && other.isLossless == this.isLossless && other.dateAdded == this.dateAdded && other.sourceMode == this.sourceMode);
}class SongsCompanion extends UpdateCompanion<SongData> {
final Value<String> id;
final Value<String> path;
final Value<String> fileName;
final Value<String> title;
final Value<String> artist;
final Value<String> album;
final Value<String> albumArtist;
final Value<String> genre;
final Value<int> trackNumber;
final Value<int> discNumber;
final Value<int> year;
final Value<int> duration;
final Value<int> fileSize;
final Value<DateTime> lastModified;
final Value<bool> favorite;
final Value<int> playCount;
final Value<DateTime?> lastPlayed;
final Value<String?> artworkPath;
final Value<bool> isLossless;
final Value<DateTime> dateAdded;
final Value<String> sourceMode;
final Value<int> rowid;
const SongsCompanion({this.id = const Value.absent(),this.path = const Value.absent(),this.fileName = const Value.absent(),this.title = const Value.absent(),this.artist = const Value.absent(),this.album = const Value.absent(),this.albumArtist = const Value.absent(),this.genre = const Value.absent(),this.trackNumber = const Value.absent(),this.discNumber = const Value.absent(),this.year = const Value.absent(),this.duration = const Value.absent(),this.fileSize = const Value.absent(),this.lastModified = const Value.absent(),this.favorite = const Value.absent(),this.playCount = const Value.absent(),this.lastPlayed = const Value.absent(),this.artworkPath = const Value.absent(),this.isLossless = const Value.absent(),this.dateAdded = const Value.absent(),this.sourceMode = const Value.absent(),this.rowid = const Value.absent(),});
SongsCompanion.insert({required String id,required String path,required String fileName,required String title,required String artist,required String album,required String albumArtist,required String genre,required int trackNumber,required int discNumber,required int year,required int duration,required int fileSize,required DateTime lastModified,this.favorite = const Value.absent(),this.playCount = const Value.absent(),this.lastPlayed = const Value.absent(),this.artworkPath = const Value.absent(),this.isLossless = const Value.absent(),this.dateAdded = const Value.absent(),this.sourceMode = const Value.absent(),this.rowid = const Value.absent(),}): id = Value(id), path = Value(path), fileName = Value(fileName), title = Value(title), artist = Value(artist), album = Value(album), albumArtist = Value(albumArtist), genre = Value(genre), trackNumber = Value(trackNumber), discNumber = Value(discNumber), year = Value(year), duration = Value(duration), fileSize = Value(fileSize), lastModified = Value(lastModified);
static Insertable<SongData> custom({Expression<String>? id, 
Expression<String>? path, 
Expression<String>? fileName, 
Expression<String>? title, 
Expression<String>? artist, 
Expression<String>? album, 
Expression<String>? albumArtist, 
Expression<String>? genre, 
Expression<int>? trackNumber, 
Expression<int>? discNumber, 
Expression<int>? year, 
Expression<int>? duration, 
Expression<int>? fileSize, 
Expression<DateTime>? lastModified, 
Expression<bool>? favorite, 
Expression<int>? playCount, 
Expression<DateTime>? lastPlayed, 
Expression<String>? artworkPath, 
Expression<bool>? isLossless, 
Expression<DateTime>? dateAdded, 
Expression<String>? sourceMode, 
Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (path != null)'path': path,if (fileName != null)'file_name': fileName,if (title != null)'title': title,if (artist != null)'artist': artist,if (album != null)'album': album,if (albumArtist != null)'album_artist': albumArtist,if (genre != null)'genre': genre,if (trackNumber != null)'track_number': trackNumber,if (discNumber != null)'disc_number': discNumber,if (year != null)'year': year,if (duration != null)'duration': duration,if (fileSize != null)'file_size': fileSize,if (lastModified != null)'last_modified': lastModified,if (favorite != null)'favorite': favorite,if (playCount != null)'play_count': playCount,if (lastPlayed != null)'last_played': lastPlayed,if (artworkPath != null)'artwork_path': artworkPath,if (isLossless != null)'is_lossless': isLossless,if (dateAdded != null)'date_added': dateAdded,if (sourceMode != null)'source_mode': sourceMode,if (rowid != null)'rowid': rowid,});
}SongsCompanion copyWith({Value<String>? id, Value<String>? path, Value<String>? fileName, Value<String>? title, Value<String>? artist, Value<String>? album, Value<String>? albumArtist, Value<String>? genre, Value<int>? trackNumber, Value<int>? discNumber, Value<int>? year, Value<int>? duration, Value<int>? fileSize, Value<DateTime>? lastModified, Value<bool>? favorite, Value<int>? playCount, Value<DateTime?>? lastPlayed, Value<String?>? artworkPath, Value<bool>? isLossless, Value<DateTime>? dateAdded, Value<String>? sourceMode, Value<int>? rowid}) {
return SongsCompanion(id: id ?? this.id,path: path ?? this.path,fileName: fileName ?? this.fileName,title: title ?? this.title,artist: artist ?? this.artist,album: album ?? this.album,albumArtist: albumArtist ?? this.albumArtist,genre: genre ?? this.genre,trackNumber: trackNumber ?? this.trackNumber,discNumber: discNumber ?? this.discNumber,year: year ?? this.year,duration: duration ?? this.duration,fileSize: fileSize ?? this.fileSize,lastModified: lastModified ?? this.lastModified,favorite: favorite ?? this.favorite,playCount: playCount ?? this.playCount,lastPlayed: lastPlayed ?? this.lastPlayed,artworkPath: artworkPath ?? this.artworkPath,isLossless: isLossless ?? this.isLossless,dateAdded: dateAdded ?? this.dateAdded,sourceMode: sourceMode ?? this.sourceMode,rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<String>(id.value);}
if (path.present) {
map['path'] = Variable<String>(path.value);}
if (fileName.present) {
map['file_name'] = Variable<String>(fileName.value);}
if (title.present) {
map['title'] = Variable<String>(title.value);}
if (artist.present) {
map['artist'] = Variable<String>(artist.value);}
if (album.present) {
map['album'] = Variable<String>(album.value);}
if (albumArtist.present) {
map['album_artist'] = Variable<String>(albumArtist.value);}
if (genre.present) {
map['genre'] = Variable<String>(genre.value);}
if (trackNumber.present) {
map['track_number'] = Variable<int>(trackNumber.value);}
if (discNumber.present) {
map['disc_number'] = Variable<int>(discNumber.value);}
if (year.present) {
map['year'] = Variable<int>(year.value);}
if (duration.present) {
map['duration'] = Variable<int>(duration.value);}
if (fileSize.present) {
map['file_size'] = Variable<int>(fileSize.value);}
if (lastModified.present) {
map['last_modified'] = Variable<DateTime>(lastModified.value);}
if (favorite.present) {
map['favorite'] = Variable<bool>(favorite.value);}
if (playCount.present) {
map['play_count'] = Variable<int>(playCount.value);}
if (lastPlayed.present) {
map['last_played'] = Variable<DateTime>(lastPlayed.value);}
if (artworkPath.present) {
map['artwork_path'] = Variable<String>(artworkPath.value);}
if (isLossless.present) {
map['is_lossless'] = Variable<bool>(isLossless.value);}
if (dateAdded.present) {
map['date_added'] = Variable<DateTime>(dateAdded.value);}
if (sourceMode.present) {
map['source_mode'] = Variable<String>(sourceMode.value);}
if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('SongsCompanion(')..write('id: $id, ')..write('path: $path, ')..write('fileName: $fileName, ')..write('title: $title, ')..write('artist: $artist, ')..write('album: $album, ')..write('albumArtist: $albumArtist, ')..write('genre: $genre, ')..write('trackNumber: $trackNumber, ')..write('discNumber: $discNumber, ')..write('year: $year, ')..write('duration: $duration, ')..write('fileSize: $fileSize, ')..write('lastModified: $lastModified, ')..write('favorite: $favorite, ')..write('playCount: $playCount, ')..write('lastPlayed: $lastPlayed, ')..write('artworkPath: $artworkPath, ')..write('isLossless: $isLossless, ')..write('dateAdded: $dateAdded, ')..write('sourceMode: $sourceMode, ')..write('rowid: $rowid')..write(')')).toString();}
}
class $PlaylistsTable extends Playlists with TableInfo<$PlaylistsTable, PlaylistData>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$PlaylistsTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _nameMeta = const VerificationMeta('name');
@override
late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
@override
late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>('created_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
static const VerificationMeta _coverPathMeta = const VerificationMeta('coverPath');
@override
late final GeneratedColumn<String> coverPath = GeneratedColumn<String>('cover_path', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
@override
List<GeneratedColumn> get $columns => [id, name, createdAt, coverPath];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'playlists';
@override
VerificationContext validateIntegrity(Insertable<PlaylistData> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));} else if (isInserting) {
context.missing(_idMeta);
}
if (data.containsKey('name')) {
context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));} else if (isInserting) {
context.missing(_nameMeta);
}
if (data.containsKey('created_at')) {
context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));} else if (isInserting) {
context.missing(_createdAtMeta);
}
if (data.containsKey('cover_path')) {
context.handle(_coverPathMeta, coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta));}return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override PlaylistData map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return PlaylistData(id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!, name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!, createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!, coverPath: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}cover_path']), );
}
@override
$PlaylistsTable createAlias(String alias) {
return $PlaylistsTable(attachedDatabase, alias);}}class PlaylistData extends DataClass implements Insertable<PlaylistData> 
{
final String id;
final String name;
final DateTime createdAt;
final String? coverPath;
const PlaylistData({required this.id, required this.name, required this.createdAt, this.coverPath});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<String>(id);
map['name'] = Variable<String>(name);
map['created_at'] = Variable<DateTime>(createdAt);
if (!nullToAbsent || coverPath != null){map['cover_path'] = Variable<String>(coverPath);
}return map; 
}
PlaylistsCompanion toCompanion(bool nullToAbsent) {
return PlaylistsCompanion(id: Value(id),name: Value(name),createdAt: Value(createdAt),coverPath: coverPath == null && nullToAbsent ? const Value.absent() : Value(coverPath),);
}
factory PlaylistData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return PlaylistData(id: serializer.fromJson<String>(json['id']),name: serializer.fromJson<String>(json['name']),createdAt: serializer.fromJson<DateTime>(json['createdAt']),coverPath: serializer.fromJson<String?>(json['coverPath']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<String>(id),'name': serializer.toJson<String>(name),'createdAt': serializer.toJson<DateTime>(createdAt),'coverPath': serializer.toJson<String?>(coverPath),};}PlaylistData copyWith({String? id,String? name,DateTime? createdAt,Value<String?> coverPath = const Value.absent()}) => PlaylistData(id: id ?? this.id,name: name ?? this.name,createdAt: createdAt ?? this.createdAt,coverPath: coverPath.present ? coverPath.value : this.coverPath,);PlaylistData copyWithCompanion(PlaylistsCompanion data) {
return PlaylistData(
id: data.id.present ? data.id.value : this.id,name: data.name.present ? data.name.value : this.name,createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,);
}
@override
String toString() {return (StringBuffer('PlaylistData(')..write('id: $id, ')..write('name: $name, ')..write('createdAt: $createdAt, ')..write('coverPath: $coverPath')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, name, createdAt, coverPath);@override
bool operator ==(Object other) => identical(this, other) || (other is PlaylistData && other.id == this.id && other.name == this.name && other.createdAt == this.createdAt && other.coverPath == this.coverPath);
}class PlaylistsCompanion extends UpdateCompanion<PlaylistData> {
final Value<String> id;
final Value<String> name;
final Value<DateTime> createdAt;
final Value<String?> coverPath;
final Value<int> rowid;
const PlaylistsCompanion({this.id = const Value.absent(),this.name = const Value.absent(),this.createdAt = const Value.absent(),this.coverPath = const Value.absent(),this.rowid = const Value.absent(),});
PlaylistsCompanion.insert({required String id,required String name,required DateTime createdAt,this.coverPath = const Value.absent(),this.rowid = const Value.absent(),}): id = Value(id), name = Value(name), createdAt = Value(createdAt);
static Insertable<PlaylistData> custom({Expression<String>? id, 
Expression<String>? name, 
Expression<DateTime>? createdAt, 
Expression<String>? coverPath, 
Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (name != null)'name': name,if (createdAt != null)'created_at': createdAt,if (coverPath != null)'cover_path': coverPath,if (rowid != null)'rowid': rowid,});
}PlaylistsCompanion copyWith({Value<String>? id, Value<String>? name, Value<DateTime>? createdAt, Value<String?>? coverPath, Value<int>? rowid}) {
return PlaylistsCompanion(id: id ?? this.id,name: name ?? this.name,createdAt: createdAt ?? this.createdAt,coverPath: coverPath ?? this.coverPath,rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<String>(id.value);}
if (name.present) {
map['name'] = Variable<String>(name.value);}
if (createdAt.present) {
map['created_at'] = Variable<DateTime>(createdAt.value);}
if (coverPath.present) {
map['cover_path'] = Variable<String>(coverPath.value);}
if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('PlaylistsCompanion(')..write('id: $id, ')..write('name: $name, ')..write('createdAt: $createdAt, ')..write('coverPath: $coverPath, ')..write('rowid: $rowid')..write(')')).toString();}
}
class $PlaylistSongsTable extends PlaylistSongs with TableInfo<$PlaylistSongsTable, PlaylistSong>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$PlaylistSongsTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _playlistIdMeta = const VerificationMeta('playlistId');
@override
late final GeneratedColumn<String> playlistId = GeneratedColumn<String>('playlist_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true, defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES playlists (id) ON DELETE CASCADE'));
static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
@override
late final GeneratedColumn<String> songId = GeneratedColumn<String>('song_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true, defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES songs (id) ON DELETE CASCADE'));
static const VerificationMeta _positionMeta = const VerificationMeta('position');
@override
late final GeneratedColumn<int> position = GeneratedColumn<int>('position', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
@override
List<GeneratedColumn> get $columns => [id, playlistId, songId, position];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'playlist_songs';
@override
VerificationContext validateIntegrity(Insertable<PlaylistSong> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('playlist_id')) {
context.handle(_playlistIdMeta, playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta));} else if (isInserting) {
context.missing(_playlistIdMeta);
}
if (data.containsKey('song_id')) {
context.handle(_songIdMeta, songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta));} else if (isInserting) {
context.missing(_songIdMeta);
}
if (data.containsKey('position')) {
context.handle(_positionMeta, position.isAcceptableOrUnknown(data['position']!, _positionMeta));} else if (isInserting) {
context.missing(_positionMeta);
}
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override PlaylistSong map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return PlaylistSong(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, playlistId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}playlist_id'])!, songId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}song_id'])!, position: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}position'])!, );
}
@override
$PlaylistSongsTable createAlias(String alias) {
return $PlaylistSongsTable(attachedDatabase, alias);}}class PlaylistSong extends DataClass implements Insertable<PlaylistSong> 
{
final int id;
final String playlistId;
final String songId;
final int position;
const PlaylistSong({required this.id, required this.playlistId, required this.songId, required this.position});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['playlist_id'] = Variable<String>(playlistId);
map['song_id'] = Variable<String>(songId);
map['position'] = Variable<int>(position);
return map; 
}
PlaylistSongsCompanion toCompanion(bool nullToAbsent) {
return PlaylistSongsCompanion(id: Value(id),playlistId: Value(playlistId),songId: Value(songId),position: Value(position),);
}
factory PlaylistSong.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return PlaylistSong(id: serializer.fromJson<int>(json['id']),playlistId: serializer.fromJson<String>(json['playlistId']),songId: serializer.fromJson<String>(json['songId']),position: serializer.fromJson<int>(json['position']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'playlistId': serializer.toJson<String>(playlistId),'songId': serializer.toJson<String>(songId),'position': serializer.toJson<int>(position),};}PlaylistSong copyWith({int? id,String? playlistId,String? songId,int? position}) => PlaylistSong(id: id ?? this.id,playlistId: playlistId ?? this.playlistId,songId: songId ?? this.songId,position: position ?? this.position,);PlaylistSong copyWithCompanion(PlaylistSongsCompanion data) {
return PlaylistSong(
id: data.id.present ? data.id.value : this.id,playlistId: data.playlistId.present ? data.playlistId.value : this.playlistId,songId: data.songId.present ? data.songId.value : this.songId,position: data.position.present ? data.position.value : this.position,);
}
@override
String toString() {return (StringBuffer('PlaylistSong(')..write('id: $id, ')..write('playlistId: $playlistId, ')..write('songId: $songId, ')..write('position: $position')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, playlistId, songId, position);@override
bool operator ==(Object other) => identical(this, other) || (other is PlaylistSong && other.id == this.id && other.playlistId == this.playlistId && other.songId == this.songId && other.position == this.position);
}class PlaylistSongsCompanion extends UpdateCompanion<PlaylistSong> {
final Value<int> id;
final Value<String> playlistId;
final Value<String> songId;
final Value<int> position;
const PlaylistSongsCompanion({this.id = const Value.absent(),this.playlistId = const Value.absent(),this.songId = const Value.absent(),this.position = const Value.absent(),});
PlaylistSongsCompanion.insert({this.id = const Value.absent(),required String playlistId,required String songId,required int position,}): playlistId = Value(playlistId), songId = Value(songId), position = Value(position);
static Insertable<PlaylistSong> custom({Expression<int>? id, 
Expression<String>? playlistId, 
Expression<String>? songId, 
Expression<int>? position, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (playlistId != null)'playlist_id': playlistId,if (songId != null)'song_id': songId,if (position != null)'position': position,});
}PlaylistSongsCompanion copyWith({Value<int>? id, Value<String>? playlistId, Value<String>? songId, Value<int>? position}) {
return PlaylistSongsCompanion(id: id ?? this.id,playlistId: playlistId ?? this.playlistId,songId: songId ?? this.songId,position: position ?? this.position,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (playlistId.present) {
map['playlist_id'] = Variable<String>(playlistId.value);}
if (songId.present) {
map['song_id'] = Variable<String>(songId.value);}
if (position.present) {
map['position'] = Variable<int>(position.value);}
return map; 
}
@override
String toString() {return (StringBuffer('PlaylistSongsCompanion(')..write('id: $id, ')..write('playlistId: $playlistId, ')..write('songId: $songId, ')..write('position: $position')..write(')')).toString();}
}
abstract class _$AppDatabase extends GeneratedDatabase{
_$AppDatabase(QueryExecutor e): super(e);
$AppDatabaseManager get managers => $AppDatabaseManager(this);
late final $SongsTable songs = $SongsTable(this);
late final $PlaylistsTable playlists = $PlaylistsTable(this);
late final $PlaylistSongsTable playlistSongs = $PlaylistSongsTable(this);
@override
Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
@override
List<DatabaseSchemaEntity> get allSchemaEntities => [songs, playlists, playlistSongs];
@override
StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([WritePropagation(on: TableUpdateQuery.onTableName('playlists' , limitUpdateKind: UpdateKind.delete), result: [TableUpdate('playlist_songs', kind: UpdateKind.delete), ],), WritePropagation(on: TableUpdateQuery.onTableName('songs' , limitUpdateKind: UpdateKind.delete), result: [TableUpdate('playlist_songs', kind: UpdateKind.delete), ],), ],);
}
typedef $$SongsTableCreateCompanionBuilder = SongsCompanion Function({required String id,required String path,required String fileName,required String title,required String artist,required String album,required String albumArtist,required String genre,required int trackNumber,required int discNumber,required int year,required int duration,required int fileSize,required DateTime lastModified,Value<bool> favorite,Value<int> playCount,Value<DateTime?> lastPlayed,Value<String?> artworkPath,Value<bool> isLossless,Value<DateTime> dateAdded,Value<String> sourceMode,Value<int> rowid,});
typedef $$SongsTableUpdateCompanionBuilder = SongsCompanion Function({Value<String> id,Value<String> path,Value<String> fileName,Value<String> title,Value<String> artist,Value<String> album,Value<String> albumArtist,Value<String> genre,Value<int> trackNumber,Value<int> discNumber,Value<int> year,Value<int> duration,Value<int> fileSize,Value<DateTime> lastModified,Value<bool> favorite,Value<int> playCount,Value<DateTime?> lastPlayed,Value<String?> artworkPath,Value<bool> isLossless,Value<DateTime> dateAdded,Value<String> sourceMode,Value<int> rowid,});
      final class $$SongsTableReferences extends BaseReferences<
        _$AppDatabase,
        $SongsTable,
        SongData> {
        $$SongsTableReferences(super.$_db, super.$_table, super.$_typedResult);
        
                  
                  static MultiTypedResultKey<
          $PlaylistSongsTable,
          List<PlaylistSong>
        > _playlistSongsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(
          db.playlistSongs, 
          aliasName: $_aliasNameGenerator(
            db.songs.id,
            db.playlistSongs.songId)
        );

          $$PlaylistSongsTableProcessedTableManager get playlistSongsRefs {
        final manager = $$PlaylistSongsTableTableManager(
            $_db, $_db.playlistSongs
            ).filter(
              (f) => f.songId.id(
              $_item.id
            )
          );

          final cache = $_typedResult.readTableOrNull(_playlistSongsRefsTable($_db));
          return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));


        }
        

      }class $$SongsTableFilterComposer extends Composer<
        _$AppDatabase,
        $SongsTable> {
        $$SongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<String> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get path => $composableBuilder(
      column: $table.path,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get artist => $composableBuilder(
      column: $table.artist,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get album => $composableBuilder(
      column: $table.album,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get albumArtist => $composableBuilder(
      column: $table.albumArtist,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get genre => $composableBuilder(
      column: $table.genre,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get trackNumber => $composableBuilder(
      column: $table.trackNumber,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get discNumber => $composableBuilder(
      column: $table.discNumber,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get year => $composableBuilder(
      column: $table.year,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get duration => $composableBuilder(
      column: $table.duration,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<bool> get favorite => $composableBuilder(
      column: $table.favorite,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get playCount => $composableBuilder(
      column: $table.playCount,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get lastPlayed => $composableBuilder(
      column: $table.lastPlayed,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get artworkPath => $composableBuilder(
      column: $table.artworkPath,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<bool> get isLossless => $composableBuilder(
      column: $table.isLossless,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get dateAdded => $composableBuilder(
      column: $table.dateAdded,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get sourceMode => $composableBuilder(
      column: $table.sourceMode,
      builder: (column) => 
      ColumnFilters(column));
      
        Expression<bool> playlistSongsRefs(
          Expression<bool> Function( $$PlaylistSongsTableFilterComposer f) f
        ) {
                final $$PlaylistSongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongs,
      getReferencedColumn: (t) => t.songId,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$PlaylistSongsTableFilterComposer(
              $db: $db,
              $table: $db.playlistSongs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return f(composer);
        }

        }
      class $$SongsTableOrderingComposer extends Composer<
        _$AppDatabase,
        $SongsTable> {
        $$SongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get artist => $composableBuilder(
      column: $table.artist,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get album => $composableBuilder(
      column: $table.album,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get albumArtist => $composableBuilder(
      column: $table.albumArtist,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get genre => $composableBuilder(
      column: $table.genre,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get trackNumber => $composableBuilder(
      column: $table.trackNumber,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get discNumber => $composableBuilder(
      column: $table.discNumber,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get year => $composableBuilder(
      column: $table.year,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get duration => $composableBuilder(
      column: $table.duration,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<bool> get favorite => $composableBuilder(
      column: $table.favorite,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get playCount => $composableBuilder(
      column: $table.playCount,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get lastPlayed => $composableBuilder(
      column: $table.lastPlayed,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get artworkPath => $composableBuilder(
      column: $table.artworkPath,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<bool> get isLossless => $composableBuilder(
      column: $table.isLossless,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
      column: $table.dateAdded,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get sourceMode => $composableBuilder(
      column: $table.sourceMode,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$SongsTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $SongsTable> {
        $$SongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<String> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get path => $composableBuilder(
      column: $table.path,
      builder: (column) => column);
      
GeneratedColumn<String> get fileName => $composableBuilder(
      column: $table.fileName,
      builder: (column) => column);
      
GeneratedColumn<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => column);
      
GeneratedColumn<String> get artist => $composableBuilder(
      column: $table.artist,
      builder: (column) => column);
      
GeneratedColumn<String> get album => $composableBuilder(
      column: $table.album,
      builder: (column) => column);
      
GeneratedColumn<String> get albumArtist => $composableBuilder(
      column: $table.albumArtist,
      builder: (column) => column);
      
GeneratedColumn<String> get genre => $composableBuilder(
      column: $table.genre,
      builder: (column) => column);
      
GeneratedColumn<int> get trackNumber => $composableBuilder(
      column: $table.trackNumber,
      builder: (column) => column);
      
GeneratedColumn<int> get discNumber => $composableBuilder(
      column: $table.discNumber,
      builder: (column) => column);
      
GeneratedColumn<int> get year => $composableBuilder(
      column: $table.year,
      builder: (column) => column);
      
GeneratedColumn<int> get duration => $composableBuilder(
      column: $table.duration,
      builder: (column) => column);
      
GeneratedColumn<int> get fileSize => $composableBuilder(
      column: $table.fileSize,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified,
      builder: (column) => column);
      
GeneratedColumn<bool> get favorite => $composableBuilder(
      column: $table.favorite,
      builder: (column) => column);
      
GeneratedColumn<int> get playCount => $composableBuilder(
      column: $table.playCount,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get lastPlayed => $composableBuilder(
      column: $table.lastPlayed,
      builder: (column) => column);
      
GeneratedColumn<String> get artworkPath => $composableBuilder(
      column: $table.artworkPath,
      builder: (column) => column);
      
GeneratedColumn<bool> get isLossless => $composableBuilder(
      column: $table.isLossless,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get dateAdded => $composableBuilder(
      column: $table.dateAdded,
      builder: (column) => column);
      
GeneratedColumn<String> get sourceMode => $composableBuilder(
      column: $table.sourceMode,
      builder: (column) => column);
      
        Expression<T> playlistSongsRefs<T extends Object>(
          Expression<T> Function( $$PlaylistSongsTableAnnotationComposer a) f
        ) {
                final $$PlaylistSongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongs,
      getReferencedColumn: (t) => t.songId,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$PlaylistSongsTableAnnotationComposer(
              $db: $db,
              $table: $db.playlistSongs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return f(composer);
        }

        }
      class $$SongsTableTableManager extends RootTableManager    <_$AppDatabase,
    $SongsTable,
    SongData,
    $$SongsTableFilterComposer,
    $$SongsTableOrderingComposer,
    $$SongsTableAnnotationComposer,
    $$SongsTableCreateCompanionBuilder,
    $$SongsTableUpdateCompanionBuilder,
    (SongData,$$SongsTableReferences),
    SongData,
    PrefetchHooks Function({bool playlistSongsRefs})
    > {
    $$SongsTableTableManager(_$AppDatabase db, $SongsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$SongsTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$SongsTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$SongsTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<String> id = const Value.absent(),Value<String> path = const Value.absent(),Value<String> fileName = const Value.absent(),Value<String> title = const Value.absent(),Value<String> artist = const Value.absent(),Value<String> album = const Value.absent(),Value<String> albumArtist = const Value.absent(),Value<String> genre = const Value.absent(),Value<int> trackNumber = const Value.absent(),Value<int> discNumber = const Value.absent(),Value<int> year = const Value.absent(),Value<int> duration = const Value.absent(),Value<int> fileSize = const Value.absent(),Value<DateTime> lastModified = const Value.absent(),Value<bool> favorite = const Value.absent(),Value<int> playCount = const Value.absent(),Value<DateTime?> lastPlayed = const Value.absent(),Value<String?> artworkPath = const Value.absent(),Value<bool> isLossless = const Value.absent(),Value<DateTime> dateAdded = const Value.absent(),Value<String> sourceMode = const Value.absent(),Value<int> rowid = const Value.absent(),})=> SongsCompanion(id: id,path: path,fileName: fileName,title: title,artist: artist,album: album,albumArtist: albumArtist,genre: genre,trackNumber: trackNumber,discNumber: discNumber,year: year,duration: duration,fileSize: fileSize,lastModified: lastModified,favorite: favorite,playCount: playCount,lastPlayed: lastPlayed,artworkPath: artworkPath,isLossless: isLossless,dateAdded: dateAdded,sourceMode: sourceMode,rowid: rowid,),
        createCompanionCallback: ({required String id,required String path,required String fileName,required String title,required String artist,required String album,required String albumArtist,required String genre,required int trackNumber,required int discNumber,required int year,required int duration,required int fileSize,required DateTime lastModified,Value<bool> favorite = const Value.absent(),Value<int> playCount = const Value.absent(),Value<DateTime?> lastPlayed = const Value.absent(),Value<String?> artworkPath = const Value.absent(),Value<bool> isLossless = const Value.absent(),Value<DateTime> dateAdded = const Value.absent(),Value<String> sourceMode = const Value.absent(),Value<int> rowid = const Value.absent(),})=> SongsCompanion.insert(id: id,path: path,fileName: fileName,title: title,artist: artist,album: album,albumArtist: albumArtist,genre: genre,trackNumber: trackNumber,discNumber: discNumber,year: year,duration: duration,fileSize: fileSize,lastModified: lastModified,favorite: favorite,playCount: playCount,lastPlayed: lastPlayed,artworkPath: artworkPath,isLossless: isLossless,dateAdded: dateAdded,sourceMode: sourceMode,rowid: rowid,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), $$SongsTableReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback:         ({playlistSongsRefs = false}){
          return PrefetchHooks(
            db: db,
            explicitlyWatchedTables: [
             if (playlistSongsRefs) db.playlistSongs
            ],
            addJoins: null,
            getPrefetchedDataCallback: (items) async {
            return [
                      if (playlistSongsRefs) await $_getPrefetchedData(
                  currentTable: table,
                  referencedTable:
                      $$SongsTableReferences._playlistSongsRefsTable(db),
                  managerFromTypedResult: (p0) =>
                      $$SongsTableReferences(db, table, p0).playlistSongsRefs,
                  referencedItemsForCurrentItem: (item, referencedItems) =>
                      referencedItems.where((e) => e.songId == item.id),
                  typedResults: items)
            
                ];
              },
          );
        }
,
        ));
        }
    typedef $$SongsTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $SongsTable,
    SongData,
    $$SongsTableFilterComposer,
    $$SongsTableOrderingComposer,
    $$SongsTableAnnotationComposer,
    $$SongsTableCreateCompanionBuilder,
    $$SongsTableUpdateCompanionBuilder,
    (SongData,$$SongsTableReferences),
    SongData,
    PrefetchHooks Function({bool playlistSongsRefs})
    >;typedef $$PlaylistsTableCreateCompanionBuilder = PlaylistsCompanion Function({required String id,required String name,required DateTime createdAt,Value<String?> coverPath,Value<int> rowid,});
typedef $$PlaylistsTableUpdateCompanionBuilder = PlaylistsCompanion Function({Value<String> id,Value<String> name,Value<DateTime> createdAt,Value<String?> coverPath,Value<int> rowid,});
      final class $$PlaylistsTableReferences extends BaseReferences<
        _$AppDatabase,
        $PlaylistsTable,
        PlaylistData> {
        $$PlaylistsTableReferences(super.$_db, super.$_table, super.$_typedResult);
        
                  
                  static MultiTypedResultKey<
          $PlaylistSongsTable,
          List<PlaylistSong>
        > _playlistSongsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(
          db.playlistSongs, 
          aliasName: $_aliasNameGenerator(
            db.playlists.id,
            db.playlistSongs.playlistId)
        );

          $$PlaylistSongsTableProcessedTableManager get playlistSongsRefs {
        final manager = $$PlaylistSongsTableTableManager(
            $_db, $_db.playlistSongs
            ).filter(
              (f) => f.playlistId.id(
              $_item.id
            )
          );

          final cache = $_typedResult.readTableOrNull(_playlistSongsRefsTable($_db));
          return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));


        }
        

      }class $$PlaylistsTableFilterComposer extends Composer<
        _$AppDatabase,
        $PlaylistsTable> {
        $$PlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<String> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get name => $composableBuilder(
      column: $table.name,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get coverPath => $composableBuilder(
      column: $table.coverPath,
      builder: (column) => 
      ColumnFilters(column));
      
        Expression<bool> playlistSongsRefs(
          Expression<bool> Function( $$PlaylistSongsTableFilterComposer f) f
        ) {
                final $$PlaylistSongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongs,
      getReferencedColumn: (t) => t.playlistId,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$PlaylistSongsTableFilterComposer(
              $db: $db,
              $table: $db.playlistSongs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return f(composer);
        }

        }
      class $$PlaylistsTableOrderingComposer extends Composer<
        _$AppDatabase,
        $PlaylistsTable> {
        $$PlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get coverPath => $composableBuilder(
      column: $table.coverPath,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$PlaylistsTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $PlaylistsTable> {
        $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<String> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get name => $composableBuilder(
      column: $table.name,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => column);
      
GeneratedColumn<String> get coverPath => $composableBuilder(
      column: $table.coverPath,
      builder: (column) => column);
      
        Expression<T> playlistSongsRefs<T extends Object>(
          Expression<T> Function( $$PlaylistSongsTableAnnotationComposer a) f
        ) {
                final $$PlaylistSongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongs,
      getReferencedColumn: (t) => t.playlistId,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$PlaylistSongsTableAnnotationComposer(
              $db: $db,
              $table: $db.playlistSongs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return f(composer);
        }

        }
      class $$PlaylistsTableTableManager extends RootTableManager    <_$AppDatabase,
    $PlaylistsTable,
    PlaylistData,
    $$PlaylistsTableFilterComposer,
    $$PlaylistsTableOrderingComposer,
    $$PlaylistsTableAnnotationComposer,
    $$PlaylistsTableCreateCompanionBuilder,
    $$PlaylistsTableUpdateCompanionBuilder,
    (PlaylistData,$$PlaylistsTableReferences),
    PlaylistData,
    PrefetchHooks Function({bool playlistSongsRefs})
    > {
    $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$PlaylistsTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$PlaylistsTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$PlaylistsTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<String> id = const Value.absent(),Value<String> name = const Value.absent(),Value<DateTime> createdAt = const Value.absent(),Value<String?> coverPath = const Value.absent(),Value<int> rowid = const Value.absent(),})=> PlaylistsCompanion(id: id,name: name,createdAt: createdAt,coverPath: coverPath,rowid: rowid,),
        createCompanionCallback: ({required String id,required String name,required DateTime createdAt,Value<String?> coverPath = const Value.absent(),Value<int> rowid = const Value.absent(),})=> PlaylistsCompanion.insert(id: id,name: name,createdAt: createdAt,coverPath: coverPath,rowid: rowid,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), $$PlaylistsTableReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback:         ({playlistSongsRefs = false}){
          return PrefetchHooks(
            db: db,
            explicitlyWatchedTables: [
             if (playlistSongsRefs) db.playlistSongs
            ],
            addJoins: null,
            getPrefetchedDataCallback: (items) async {
            return [
                      if (playlistSongsRefs) await $_getPrefetchedData(
                  currentTable: table,
                  referencedTable:
                      $$PlaylistsTableReferences._playlistSongsRefsTable(db),
                  managerFromTypedResult: (p0) =>
                      $$PlaylistsTableReferences(db, table, p0).playlistSongsRefs,
                  referencedItemsForCurrentItem: (item, referencedItems) =>
                      referencedItems.where((e) => e.playlistId == item.id),
                  typedResults: items)
            
                ];
              },
          );
        }
,
        ));
        }
    typedef $$PlaylistsTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $PlaylistsTable,
    PlaylistData,
    $$PlaylistsTableFilterComposer,
    $$PlaylistsTableOrderingComposer,
    $$PlaylistsTableAnnotationComposer,
    $$PlaylistsTableCreateCompanionBuilder,
    $$PlaylistsTableUpdateCompanionBuilder,
    (PlaylistData,$$PlaylistsTableReferences),
    PlaylistData,
    PrefetchHooks Function({bool playlistSongsRefs})
    >;typedef $$PlaylistSongsTableCreateCompanionBuilder = PlaylistSongsCompanion Function({Value<int> id,required String playlistId,required String songId,required int position,});
typedef $$PlaylistSongsTableUpdateCompanionBuilder = PlaylistSongsCompanion Function({Value<int> id,Value<String> playlistId,Value<String> songId,Value<int> position,});
      final class $$PlaylistSongsTableReferences extends BaseReferences<
        _$AppDatabase,
        $PlaylistSongsTable,
        PlaylistSong> {
        $$PlaylistSongsTableReferences(super.$_db, super.$_table, super.$_typedResult);
        
                          static $PlaylistsTable _playlistIdTable(_$AppDatabase db) => 
            db.playlists.createAlias($_aliasNameGenerator(
            db.playlistSongs.playlistId,
            db.playlists.id));
          

        $$PlaylistsTableProcessedTableManager? get playlistId {
          if ($_item.playlistId == null) return null;
          final manager = $$PlaylistsTableTableManager($_db, $_db.playlists).filter((f) => f.id($_item.playlistId!));
          final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
          if (item == null) return manager;
          return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
        }

                  static $SongsTable _songIdTable(_$AppDatabase db) => 
            db.songs.createAlias($_aliasNameGenerator(
            db.playlistSongs.songId,
            db.songs.id));
          

        $$SongsTableProcessedTableManager? get songId {
          if ($_item.songId == null) return null;
          final manager = $$SongsTableTableManager($_db, $_db.songs).filter((f) => f.id($_item.songId!));
          final item = $_typedResult.readTableOrNull(_songIdTable($_db));
          if (item == null) return manager;
          return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
        }


      }class $$PlaylistSongsTableFilterComposer extends Composer<
        _$AppDatabase,
        $PlaylistSongsTable> {
        $$PlaylistSongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get position => $composableBuilder(
      column: $table.position,
      builder: (column) => 
      ColumnFilters(column));
      
        $$PlaylistsTableFilterComposer get playlistId {
                final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$PlaylistsTableFilterComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return composer;
        }
        $$SongsTableFilterComposer get songId {
                final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$SongsTableFilterComposer(
              $db: $db,
              $table: $db.songs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return composer;
        }
        }
      class $$PlaylistSongsTableOrderingComposer extends Composer<
        _$AppDatabase,
        $PlaylistSongsTable> {
        $$PlaylistSongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position,
      builder: (column) => 
      ColumnOrderings(column));
      
        $$PlaylistsTableOrderingComposer get playlistId {
                final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$PlaylistsTableOrderingComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return composer;
        }
        $$SongsTableOrderingComposer get songId {
                final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$SongsTableOrderingComposer(
              $db: $db,
              $table: $db.songs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return composer;
        }
        }
      class $$PlaylistSongsTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $PlaylistSongsTable> {
        $$PlaylistSongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<int> get position => $composableBuilder(
      column: $table.position,
      builder: (column) => column);
      
        $$PlaylistsTableAnnotationComposer get playlistId {
                final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$PlaylistsTableAnnotationComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return composer;
        }
        $$SongsTableAnnotationComposer get songId {
                final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$SongsTableAnnotationComposer(
              $db: $db,
              $table: $db.songs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return composer;
        }
        }
      class $$PlaylistSongsTableTableManager extends RootTableManager    <_$AppDatabase,
    $PlaylistSongsTable,
    PlaylistSong,
    $$PlaylistSongsTableFilterComposer,
    $$PlaylistSongsTableOrderingComposer,
    $$PlaylistSongsTableAnnotationComposer,
    $$PlaylistSongsTableCreateCompanionBuilder,
    $$PlaylistSongsTableUpdateCompanionBuilder,
    (PlaylistSong,$$PlaylistSongsTableReferences),
    PlaylistSong,
    PrefetchHooks Function({bool playlistId,bool songId})
    > {
    $$PlaylistSongsTableTableManager(_$AppDatabase db, $PlaylistSongsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$PlaylistSongsTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$PlaylistSongsTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$PlaylistSongsTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String> playlistId = const Value.absent(),Value<String> songId = const Value.absent(),Value<int> position = const Value.absent(),})=> PlaylistSongsCompanion(id: id,playlistId: playlistId,songId: songId,position: position,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required String playlistId,required String songId,required int position,})=> PlaylistSongsCompanion.insert(id: id,playlistId: playlistId,songId: songId,position: position,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), $$PlaylistSongsTableReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback:         ({playlistId = false,songId = false}){
          return PrefetchHooks(
            db: db,
            explicitlyWatchedTables: [
             
            ],
            addJoins: <T extends TableManagerState<dynamic,dynamic,dynamic,dynamic,dynamic,dynamic,dynamic,dynamic,dynamic,dynamic,dynamic>>(state) {

                                  if (playlistId){
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.playlistId,
                    referencedTable:
                        $$PlaylistSongsTableReferences._playlistIdTable(db),
                    referencedColumn:
                        $$PlaylistSongsTableReferences._playlistIdTable(db).id,
                  ) as T;
               }
                  if (songId){
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.songId,
                    referencedTable:
                        $$PlaylistSongsTableReferences._songIdTable(db),
                    referencedColumn:
                        $$PlaylistSongsTableReferences._songIdTable(db).id,
                  ) as T;
               }

                return state;
              }
,
            getPrefetchedDataCallback: (items) async {
            return [
            
                ];
              },
          );
        }
,
        ));
        }
    typedef $$PlaylistSongsTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $PlaylistSongsTable,
    PlaylistSong,
    $$PlaylistSongsTableFilterComposer,
    $$PlaylistSongsTableOrderingComposer,
    $$PlaylistSongsTableAnnotationComposer,
    $$PlaylistSongsTableCreateCompanionBuilder,
    $$PlaylistSongsTableUpdateCompanionBuilder,
    (PlaylistSong,$$PlaylistSongsTableReferences),
    PlaylistSong,
    PrefetchHooks Function({bool playlistId,bool songId})
    >;class $AppDatabaseManager {
final _$AppDatabase _db;
$AppDatabaseManager(this._db);
$$SongsTableTableManager get songs => $$SongsTableTableManager(_db, _db.songs);
$$PlaylistsTableTableManager get playlists => $$PlaylistsTableTableManager(_db, _db.playlists);
$$PlaylistSongsTableTableManager get playlistSongs => $$PlaylistSongsTableTableManager(_db, _db.playlistSongs);
}
