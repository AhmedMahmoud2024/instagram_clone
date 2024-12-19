import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? email;
  final String? uid;
  final String? photoUrl;
  final String? username;
  final String? bio;
  final List<String>? followers;
  final List<String>? following;

  const User({
    this.username,
    this.uid,
    this.photoUrl,
    this.email,
    this.bio,
    this.followers,
    this.following,
  });

  Map<String, dynamic> toJson() => {
        "username": username ?? '',
        "uid": uid ?? '',
        "email": email ?? '',
        "photoUrl": photoUrl ?? '',
        "bio": bio ?? '',
        "followers": followers ?? [],
        "following": following ?? [],
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot["username"] ?? '',
      uid: snapshot["uid"] ?? '',
      email: snapshot["email"] ?? '',
      photoUrl: snapshot["photoUrl"] ?? '',
      bio: snapshot["bio"] ?? '',
      followers: List<String>.from(snapshot["followers"] ?? []),
      following: List<String>.from(snapshot["following"] ?? []),
    );
  }
}
/*
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String bio;
  final List followers;
  final List following;

  const User(
      {required this.email,
      required this.uid,
      required this.photoUrl,
      required this.username,
      required this.bio,
      required this.followers,
      required this.following});

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "bio": bio,
        "followers": followers,
        "following": following
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapShot = snap.data() as Map<String, dynamic>;
    return User(
        username: snapShot['username'],
        uid: snapShot['uid'],
        email: snapShot['email'],
        photoUrl: snapShot['photoUrl'],
        bio: snapShot['bio'],
        followers: snapShot['followers'],
        following: snapShot['following']);
  }
}
*/