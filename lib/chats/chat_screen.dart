import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});
  final currentID = 1;

  final messageController = TextEditingController();
  final scrollCtrl = ScrollController();

  void sendMessage({required String message}) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    final ref = firebaseFirestore.collection('messages');

    await ref.add({
      "message": message,
      "timestamps": Timestamp.now(),
      "sender_id": 1,
      "receiver_id": 2
    });

    scrollCtrl.animateTo(scrollCtrl.position.maxScrollExtent,
        duration: Duration(milliseconds: 500), curve: Curves.easeIn);
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        child: TextFormField(
          controller: messageController,
          decoration: InputDecoration(
            hintText: 'type your message',
            suffix: InkWell(
              onTap: () {
                sendMessage(message: messageController.text.trim());
              },
              child: const Text(
                'Send',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('messages')
              .orderBy('timestamps')
              .snapshots(),
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Text("Loading..."),
              );
            }

            if (snapshot.hasError) {
              return Text("Error");
            }

            if (snapshot.hasData) {
              if (snapshot.data!.docs.isEmpty) {
                return Text("Break the ice");
              }
              return Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, right: 8, left: 8, bottom: 100),
                child: ListView.builder(
                    controller: scrollCtrl,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final singleData = snapshot.data!.docs[index];
                      final isCurrentuserMessage =
                          currentID == singleData['sender_id'];
                      return Align(
                        alignment: isCurrentuserMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          height: 40,
                          constraints: BoxConstraints(maxWidth: 230),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isCurrentuserMessage
                                  ? Colors.grey
                                  : Colors.blue[700]),
                          child: Center(
                            child: Text(singleData['message'].toString(),
                                style: TextStyle(
                                  color: isCurrentuserMessage
                                      ? Colors.black
                                      : Colors.white,
                                )),
                          ),
                        ),
                      );
                    }),
              );
            }
            return Text("data");
          })),
    );
  }
}
