import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:padel_punilla/domain/enums/paddle_category.dart';
import 'package:padel_punilla/domain/enums/player_gender.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    required this.discriminator,
    required this.createdAt,
    this.photoUrl,
    this.category,
    this.gender,
    this.locality,
    this.followers = const [],
    this.following = const [],
    this.favoriteClubIds = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: (map['id'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      username: (map['username'] as String?) ?? '',
      displayName: (map['displayName'] as String?) ?? '',
      discriminator: (map['discriminator'] as String?) ?? '0000',
      photoUrl: map['photoUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      category:
          map['category'] != null
              ? PaddleCategory.values.firstWhere(
                (e) => e.name == map['category'],
              )
              : null,
      gender:
          map['gender'] != null
              ? PlayerGender.values.firstWhere((e) => e.name == map['gender'])
              : null,
      locality:
          map['locality'] != null
              ? Locality.values.firstWhere((e) => e.name == map['locality'])
              : null,
      followers: List<String>.from((map['followers'] as List<dynamic>?) ?? []),
      following: List<String>.from((map['following'] as List<dynamic>?) ?? []),
      favoriteClubIds: List<String>.from(
        (map['favoriteClubIds'] as List<dynamic>?) ?? [],
      ),
    );
  }
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String discriminator;
  final String? photoUrl;
  final DateTime createdAt;
  final PaddleCategory? category;
  final PlayerGender? gender;
  final Locality? locality;

  final List<String> followers;
  final List<String> following;

  /// Lista de IDs de clubes favoritos del usuario (máximo 10)
  final List<String> favoriteClubIds;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'displayName': displayName,
      'discriminator': discriminator,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'category': category?.name,
      'gender': gender?.name,
      'locality': locality?.name,
      'followers': followers,
      'following': following,
      'favoriteClubIds': favoriteClubIds,
    };
  }

  /// Sentinel value to represent "not provided" for nullable fields
  static const Object _sentinel = Object();

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? discriminator,
    Object? photoUrl = _sentinel,
    DateTime? createdAt,
    Object? category = _sentinel,
    Object? gender = _sentinel,
    Object? locality = _sentinel,
    List<String>? followers,
    List<String>? following,
    List<String>? favoriteClubIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      discriminator: discriminator ?? this.discriminator,
      photoUrl: photoUrl == _sentinel ? this.photoUrl : photoUrl as String?,
      createdAt: createdAt ?? this.createdAt,
      category:
          category == _sentinel ? this.category : category as PaddleCategory?,
      gender: gender == _sentinel ? this.gender : gender as PlayerGender?,
      locality: locality == _sentinel ? this.locality : locality as Locality?,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      favoriteClubIds: favoriteClubIds ?? this.favoriteClubIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.username == username &&
        other.displayName == displayName &&
        other.discriminator == discriminator &&
        other.photoUrl == photoUrl &&
        other.createdAt == createdAt &&
        other.category == category &&
        other.gender == gender &&
        other.locality == locality &&
        other.followers.length == followers.length &&
        other.followers.every(followers.contains) &&
        other.following.length == following.length &&
        other.following.every(following.contains) &&
        other.favoriteClubIds.length == favoriteClubIds.length &&
        other.favoriteClubIds.every(favoriteClubIds.contains);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        username.hashCode ^
        displayName.hashCode ^
        discriminator.hashCode ^
        photoUrl.hashCode ^
        createdAt.hashCode ^
        category.hashCode ^
        gender.hashCode ^
        locality.hashCode ^
        Object.hashAll(followers) ^
        Object.hashAll(following) ^
        Object.hashAll(favoriteClubIds);
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, username: $username, displayName: $displayName, discriminator: $discriminator, photoUrl: $photoUrl, createdAt: $createdAt, category: $category, gender: $gender, locality: $locality, followers: $followers, following: $following, favoriteClubIds: $favoriteClubIds)';
  }
}
