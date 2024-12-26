import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:instagram_flutter/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLengt = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // get post length
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      postLengt = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(userData['username']),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(userData['photoUrl']
                                //  'https://media.istockphoto.com/id/518739772/photo/mountain-top.jpg?s=1024x1024&w=is&k=20&c=47Xk9gFtkI5EOEcmzTxqWIcqBnYjrcKR-u7SbUXjYqU='
                                ),
                            radius: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStateColumn(postLengt, 'posts'),
                                    buildStateColumn(followers, 'followers'),
                                    buildStateColumn(following, 'following'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        ? FollowButton(
                                            function: () {
                                              // Your follow/unfollow logic here
                                            },
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            borderColor: Colors.grey,
                                            text: 'Edit profile',
                                            textColor: primaryColor,
                                          )
                                        : isFollowing
                                            ? FollowButton(
                                                function: () {
                                                  // Your follow/unfollow logic here
                                                },
                                                backgroundColor: Colors.white,
                                                borderColor: Colors.grey,
                                                text: 'Unfollow',
                                                textColor: Colors.black,
                                              )
                                            : FollowButton(
                                                function: () {
                                                  // Your follow/unfollow logic here
                                                },
                                                backgroundColor: Colors.blue,
                                                borderColor: Colors.black,
                                                text: 'Follow',
                                                textColor: Colors.black,
                                                //   backgroundColor: backgroundColor, borderColor: borderColor, text: text, textColor: textColor
                                              )
                                  ],
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    userData['username'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 1),
                                  child: Text(
                                    userData['bio'],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const Divider(),
              ],
            ),
          );
  }

  Column buildStateColumn(int num, String lable) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
            margin: EdgeInsets.only(top: 4),
            child: Text(
              lable,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey),
            )),
      ],
    );
  }
}
