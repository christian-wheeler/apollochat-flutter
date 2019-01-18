import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'inject.dart';

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
                child: Theme.of(context).platform == TargetPlatform.iOS ?
                CupertinoButton(
                  child: Text("Send"),
                  onPressed: _isComposing && _textController.text.trim().length != 0 ?
                    () =>  _handleSubmitted(_textController.text) : null
                ) :
                IconButton(
                  icon: Icon(Icons.send),
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
      // _isSending = true;
    });

    String userID = Inject().preferences.getString('userID');

    runMutation({
      'author': '$userID',
      'text': '$text',
      'chat': 'JUgEdBM2BFoh5k7TH7cP'
    });
  }
}