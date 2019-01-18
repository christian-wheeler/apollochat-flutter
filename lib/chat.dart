// Flutter Imports
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';

// Third Party Imports
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:apollo_chat/particles.dart';

// Internal Imports
import 'widgets/gradient.dart';
import 'text_composer.dart';
import 'inject.dart';

class ChatScreen extends StatefulWidget {
  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {

  // This GraphQL Query tells the app's server in what shape we want to receive
  // and consume data on the client. In this case, we want all chats, their ids,
  // titles, and descriptions, as well as any messages they may contain. Note
  // that each message contains a nested author. For the purpose of this sample,
  // we only want an author's id (so we can differentiate between our own messages
  // and other people's messages), the author's handle (username), and full name.
  String query = '''
    
    query {
      chats {
        id,
        title,
        description,
        messages {
          text,
          created,
          author {
            id,
            handle,
            name
          }
        }
      }
    }
  
  '''.replaceAll('\n', ' ');

  // This GraphQL Mutation is used to POST data, in this case a new messages, to
  // the app's server. The top level SendMessage line allows us to define placeholder
  // values, so that we can provide the app with the correct data at runtime.
  String mutation = '''

    mutation SendMessage(\$author: String!, \$text: String!, \$chat: String!) {
      sendMessage(author: \$author, text: \$text, chat: \$chat) { 
        id 
      }
    }

  '''.replaceAll('\n', ' ');

  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    // The Scaffold Widget implements the basic material design visual layout
    // structure, and is usually a good fit for the root Widget of a screen.
    // The AppBar can be customised very easily, as demonstrated by the blue
    // gradient used as its background.
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: GradientContainer(),
        title: Text('Apollo Chat'),
        // Here we provide a different elevation level for the AppBar, depending
        // on which platform the app is running on.
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0
      ),
        body: Stack(
          children: <Widget>[
            // A simple animation widget that animates the opacity of a child,
            // using a given duration and opacity level. When the opacity is
            // changed using setState, the animation is triggered.
            AnimatedOpacity(
              opacity: _isSending ? 1.0 : 0.0,
              duration: Duration(milliseconds: 800),
              child: ParticleWidget(MediaQuery.of(context).size)
            ),
            Container(
              // A column widget stacks a list of child widgets in just the way,
              // one would expect: a column.
              child: Column(
                children: <Widget>[
                  Flexible(
                    // The Query widget is provided by the Apollo GraphQL library.
                    // It takes a query string (the one defined above) as a parameter.
                    // The pollInterval parameter tells the Query to poll the server
                    // every second. This is done to enable the real time capability
                    // required for chat. A better alternative would be to use an
                    // Apollo Subscription, that makes use of WebSockets and PubSub.
                    child: Query(
                      query,
                      pollInterval: 1,
                      // The builder parameter tells the Query widget what child
                      // widgets to render depending on its state.
                      builder: ({ bool loading, var data, Exception error }) {

                        // If there is an error with the query, show it in the UI,
                        // instead of showing the list of messages.
                        if (error != null) return Text(error.toString());

                        // If the query is still loading, show a message in the UI,
                        // instead of showing the list of messages.
                        if (loading) {
                          return ListView.builder(
                            itemCount: 1,
                            itemBuilder: (context, index) => Text('Loading')
                          );
                        }

                        // If the function gets to this point, then the query has
                        // retrieved some data.
                        List chats = data['chats'];

                        // For the purpose of this sample application, we only want
                        // to read messages from a single chat (so we can talk to
                        // one another). The ID filtered for below corresponds to
                        // the only chat object currently in the remote database.
                        Map<String, dynamic> chat = chats.firstWhere((chat) {
                          return chat['id'] == 'JUgEdBM2BFoh5k7TH7cP';
                        });

                        // Get the chat's nested messages array, sort it, and then
                        // reverse it so that messages stack up from the bottom of
                        // the page.
                        List messages = chat['messages'];
                        messages.sort((a, b) => a['created'].compareTo(b['created']));
                        messages = messages.reversed.toList();

                        // Finally after obtaining and sorting the message data,
                        // a ListView builder is used to generate a Message widget
                        // for each message retrieved from the server.
                        return ListView.builder(
                          padding: EdgeInsets.all(8.0),
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];

                            // Get the current user's ID using the service locator.
                            String userID = Inject().userID;
                            String author = message['author']['id'];

                            // Return a Message widget for the current message.
                            return Message(
                              message['text'],
                              message['author']['handle'],
                              message['author']['name'],
                              // Compare current user's ID with the message author,
                              // and pass it as a constructor argument to the widget.
                              userID == author,
                              // Create a DateTime using the message's created field.
                              DateTime.fromMillisecondsSinceEpoch(message['created'])
                            );
                          }
                        );
                      },
                    ),
                  ),
                  Divider(height: 1.0),
                  Container(
                    decoration: BoxDecoration(color: Theme.of(context).cardColor),
                    // The Mutation widget is provided by the Apollo GraphQL library.
                    // It takes a mutation string (defined above) as a parameter, and
                    // uses said string to POST data to the server.
                    child: Mutation(
                      mutation,
                      // The builder function provides some context about the mutation, as
                      // well as a function we can call to run the mutation.
                      builder: ( runMutation, { bool loading, var data, Exception error }) {
                        // A composer widget is returned and receives the runMutation
                        // function so that it can execute it when necessary.
                        return TextComposer(runMutation);
                      },
                      onCompleted: (Map<String, dynamic> data) {
                        // If a message is successfully sent using the mutation,
                        // trigger the particle effect's fade in animation.
                        setState(() {
                          _isSending = true;
                        });
                      }
                    ),
                  ),
                ],
              ),
              // If the app is running on iOS, return a decoration, otherwise
              // return null (do nothing).
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

// Widget that displays chat messages and authors.
class Message extends StatelessWidget {

  Message(this.text, this.handle, this.name, this.own, this.created);

  // Note that a DateTime and a bool field have been added to the class as well
  // as the constructor. The own field is used to decide which orientation the
  // widget should render.
  final String text;
  final String handle;
  final String name;
  final DateTime created;
  final bool own;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        // If the message is our own, use the self function, otherwise, use
        // the other function.
        children: own ? self(context) : other(context),
      ),
    );
  }

  List<Widget> self(BuildContext context) {
    String hours = '${created.hour}';
    String minutes = '${created.minute}';

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
              Row(
                children: <Widget>[
                  Text(handle, style: TextStyle(color: Colors.white)),
                  Expanded(child: Text('$hours:$minutes', textAlign: TextAlign.end, style: TextStyle(color: Colors.white, fontSize: 13)))
                ],
              ),
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
    String hours = '${created.hour}';
    String minutes = '${created.minute}';

    return <Widget>[
      Expanded(
        child: Container(
          decoration: BoxDecoration(color: Color(0x90607D8B), borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(left: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(handle, style: TextStyle(color: Colors.white)),
                  Expanded(child: Text('$hours:$minutes', textAlign: TextAlign.end, style: TextStyle(color: Colors.white, fontSize: 13)))
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: Text(text, style: TextStyle(color: Colors.white)),
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