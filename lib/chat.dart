import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:apollo_chat/particles.dart';
import 'text_composer.dart';

class ChatScreen extends StatefulWidget {
  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {

  String query = '''
    
    query {
      chats {
        id,
        title,
        description,
        messages {
          text,
          author {
            handle,
            name
          }
        }
      }
    }
  
  '''.replaceAll('\n', ' ');

  String mutation = '''

    mutation SendMessage(\$author: String!, \$text: String!, \$chat: String!) {
      sendMessage(author: \$author:, text: \$text, chat: \$chat) { 
        id 
      }
    }

  '''.replaceAll('\n', ' ');

  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xff53ACF1),
                    Color(0xff6EEEFE)
                  ]
              )
            ),
          ),
          title: Text('Apollo Chat'),
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0),
          body: Stack(
            children: <Widget>[
              AnimatedOpacity(
                opacity: _isSending ? 1.0 : 0.0,
                duration: Duration(milliseconds: 800),
                child: ParticleWidget(MediaQuery.of(context).size)
              ),
              // ParticleWidget(MediaQuery.of(context).size),
              Container(
                child: Column(
                  children: <Widget>[
                    Flexible(
                      child: Query(
                        query,
                        pollInterval: 1,
                        builder: ({ bool loading, var data, Exception error }) {
                          if (error != null) {
                            return Text(error.toString());
                          }

                          if (loading) {
                            return ListView.builder(
                                itemCount: 1,
                                itemBuilder: (context, index) {
                                  return Text('Loading');
                                }
                            );
                          }

                          // it can be either Map or List
                          List chats = data['chats'];
                          Map<String, dynamic> chat = chats.firstWhere((chat) {
                            return chat['id'] == 'JUgEdBM2BFoh5k7TH7cP';
                          });

                          List messages = chat['messages'];
                          messages = messages.reversed.toList();

                          return ListView.builder(
                              padding: EdgeInsets.all(8.0),
                              reverse: true,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                return Message(message['text'], message['author']['handle'], message['author']['name']);
                              }
                          );
                        },
                      ),
                    ),
                    Divider(height: 1.0),
                    Container(
                      decoration: BoxDecoration(color: Theme.of(context).cardColor),
                      child: Mutation(
                        mutation,
                        builder: ( runMutation, { bool loading, var data, Exception error }) {

                          if (error != null) {
                            // showError(context, error.toString());
                            print('error: ${error.toString()}');
                          }

                          return TextComposer(runMutation);
                        },
                        onCompleted: (Map<String, dynamic> data) {
                          print(data);
                          var id = data['sendMessage']['id'];
                          print('message sent successfully $id');

                          setState(() {
                            _isSending = true;
                          });
                          // saveID(id);
                          // navigate();
                        }
                      ),
                      // _buildTextComposer(),
                    ),
                  ],
                ),
                decoration: Theme.of(context).platform == TargetPlatform.iOS ?
                  BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]),
                    ),
                  ) : null
              )
            ],
          ),
        );
      }

}

class Message extends StatelessWidget {

  Message(this.text, this.handle, this.name);

  final String text;
  final String handle;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: self(context) // own ? self(context) : other(context),
      ),
    );
  }

  List<Widget> self(BuildContext context) {
    return <Widget>[
      Container(
        margin: const EdgeInsets.only(right: 12.0),
        child: CircleAvatar(child: Text(name[0])),
      ),
      Expanded(
        child: Container(
          decoration: BoxDecoration(color: Color(0x90607D8B), borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(handle, style: TextStyle(color: Colors.white)),
              Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: Text(text, style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> other(BuildContext context) {
    return <Widget>[
      Expanded(
        child: Container(
          decoration: BoxDecoration(color: Colors.blueGrey, borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(left: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(handle, style: Theme.of(context).textTheme.subhead),
              Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: Text(text),
              ),
            ],
          ),
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 12.0),
        child: CircleAvatar(child: Text(name[0])),
      ),
    ];
  }
}

showError(BuildContext context, String error) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(error),
          actions: <Widget>[
            SimpleDialogOption(
              child: Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
  );
}