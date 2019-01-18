import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth.dart';
import 'chat.dart';
import 'inject.dart';

void main() async {
  // Initialize Apollo Connection
  ValueNotifier<Client> client = ValueNotifier(
    Client(
      endPoint: 'https://apollo-chat-epiuse.appspot.com/',
      cache: InMemoryCache(),
      apiToken: 'EPI-USE',
    ),
  );

  // Initialize Service Locator
  final injector = Inject();
  injector.preferences = await SharedPreferences.getInstance();
  injector.userID = injector.preferences.getString('userID') ?? '';

  // Start App
  runApp(ApolloChat(client));
}

class ApolloChat extends StatelessWidget {

  ApolloChat(this.client);

  final ValueNotifier<Client> client;

  @override
  Widget build(BuildContext context) {
    return GraphqlProvider(
        client: client,
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(primarySwatch: Colors.blueGrey),
          home: Inject().userID == '' ? AuthScreen() : ChatScreen(),
          routes: {
            '/chat': (context) => ChatScreen()
          },
        )
    );
  }
}

String chats = '''

query {
  chats {
    title,
    description
  }
}

'''.replaceAll('\n', ' ');

Widget graph() {
  return Query(
    chats,
    builder: ({ bool loading, var data, Exception error }) {
      if (error != null) {
        return Text(error.toString());
      }

      if (loading) {
        return Text('Loading');
      }

      // it can be either Map or List
      List repositories = data['chats'];

      return ListView.builder(
          itemCount: repositories.length,
          itemBuilder: (context, index) {
            final repository = repositories[index];
            return Text(repository['title']);
          });
    },
  );
}