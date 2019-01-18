import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'inject.dart';

// Widget used to compose and send messages. It needs to be a stateful widget,
// as the input should be disabled if it doesn't contain any text.
class TextComposer extends StatefulWidget {

  TextComposer(this.runMutation);

  final dynamic runMutation;

  @override
  State createState() => TextComposerState(runMutation);
}

class TextComposerState extends State<TextComposer> {

  TextComposerState(this.runMutation);

  final TextEditingController _textController = TextEditingController();
  final dynamic runMutation;

  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: SafeArea(
                child: TextField(
                  controller: _textController,
                  onChanged: (String text) {
                    setState(() {
                      _isComposing = text.length > 0;
                    });
                  },
                  onSubmitted: _handleSubmitted,
                  decoration: InputDecoration.collapsed(hintText: "Send a message"),
                ),
              )
            ),
            SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                // Return either a CupertinoButton or an IconButton depending on
                // whether the app is running on Android or on iOS.
                child: Theme.of(context).platform == TargetPlatform.iOS ?
                  CupertinoButton(
                    child: Text("Send"),
                    // If the button is pressed and the the message box isn't empty,
                    // submit its text, otherwise do nothing.
                    onPressed: _isComposing && _textController.text.trim().length != 0 ?
                      () =>  _handleSubmitted(_textController.text) : null
                  ) :
                  IconButton(
                    icon: Icon(Icons.send),
                    // If the button is pressed and the the message box isn't empty,
                    // submit its text, otherwise do nothing.
                    onPressed: _isComposing && _textController.text.trim().length != 0 ?
                      () =>  _handleSubmitted(_textController.text) : null,
                  )
              ),
            )
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();

    setState(() {
      _isComposing = false;
    });

    // Get the current user's ID, and use it to execute the send message mutation.
    String userID = Inject().preferences.getString('userID');
    runMutation({
      'author': userID,
      'text': text,
      'chat': 'JUgEdBM2BFoh5k7TH7cP'
    });
  }
}