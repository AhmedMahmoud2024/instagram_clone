import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String? description;
  final String? uid;
  final String? username;
  final String? postId;
  final datePublished;
  final String? postUrl;
  final String? profileImage;
  final List<dynamic>? likes;

  const Post(
      {this.description,
      this.uid,
      this.username,
      this.postId,
      this.datePublished,
      this.postUrl,
      this.profileImage,
      this.likes});

  Map<String, dynamic> toJson() => {
        "description": description ?? '',
        "uid": uid ?? '',
        "username": username ?? '',
        "postId": postId ?? '',
        "datePublished": datePublished ?? '',
        "postUrl": postUrl ?? '',
        "profileImage": profileImage ?? '',
        "likes": likes ?? [],
      };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
        description: snapshot["description"] ?? '',
        uid: snapshot["uid"] ?? '',
        username: snapshot["username"] ?? '',
        postId: snapshot["postId"] ?? '',
        datePublished: snapshot["datePublished"] ?? '',
        postUrl: snapshot["postUrl"] ?? '',
        profileImage: snapshot["profileImage"] ?? '',
        likes: snapshot["likes"] ?? []);
  }
}
