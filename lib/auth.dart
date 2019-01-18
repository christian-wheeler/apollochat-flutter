// Flutter Imports
import 'package:flutter/material.dart';

// Third Party Imports
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// Internal Imports
import 'widgets/gradient.dart';

// Widget used to authenticate a user and get into the app chat room. Note that
// this is not real authentication, but rather an Auth UI, that creates a user
// profile.
class AuthScreen extends StatefulWidget {

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {

  // The current step of the Stepper widget.
  int step = 0;

  // Variables used to store form input.
  String name;
  String surname;
  String username;

  // A mutation string used to POST a user profile to the server.
  String mutation = '''

    mutation AddUser(\$name: String!, \$handle: String!) {
      addUser(name: \$name, handle: \$handle) { 
        id 
      }
    }

  '''.replaceAll('\n', ' ');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: gradientDecoration(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          brightness: Brightness.dark,
        ),
        body: Container(
          // The Mutation widget is provided by the Apollo GraphQL library.
          // It takes a mutation string (defined above) as a parameter, and
          // uses said string to POST data to the server.
          child: Mutation(
            mutation,
            builder: ( runMutation, { bool loading, var data, Exception error }) {
              return Stepper(
                currentStep: this.step,
                type: StepperType.vertical,
                controlsBuilder: controls,
                steps: [
                  stepOne(),
                  stepTwo(runMutation),
                  stepThree()
                ],
              );
            },
            onCompleted: (Map<String, dynamic> data) {
              // This callback indicates that the user profile POST request
              // succeeded. When it does, the user's generated ID is stored
              // using SharedPreferences.
              var id = data['addUser']['id'];
              print('user created successfully $id');
              saveID(id);

              // Navigate to the chat screen, and close this screen.
              navigate();
            }
          ),
        ),
      ),
    );
  }

  Widget controls(BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
    return Container();
  }

  Step stepOne() {
    var validateCode = (String code) {
      if (code.trim().length == 0) return 'Username is required.';
      return null;
    };

    var form = GlobalKey<FormState>();

    return Step(
      title: Text('Authentication', style: TextStyle(color: Color(0xffFFFFFF))),
      content: Form(
        key: form,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 30, top: 8),
              child: TextFormField(
                maxLines: 1,
                style: TextStyle(color: Color(0xffFFFFFF)),
                keyboardType: TextInputType.text,
                validator: validateCode,
                decoration: singleDecoration('Username'),
                // Store the provided username when the form is saved.
                onSaved: (value) => username = value,
              )
            ),
            Container(
              padding: EdgeInsets.only(right: 30, top: 8),
              height: 60,
              child: FlatButton(
                splashColor: Color(0x49FFFFFF),
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Color(0x80FFFFFF)),
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.fingerprint, color: Color(0xffFFFFFF)),
                    Text('SP', style: TextStyle(color: Colors.transparent)),
                    Text('VALIDATE', style: TextStyle(color: Color(0xffFFFFFF)))
                  ],
                ),
                onPressed: () {
                  if (form.currentState.validate()) {
                    form.currentState.save();
                    setState(() {
                      this.step = 1;
                    });
                  }
                },
              ),
            )
          ],
        ),
      ),
      isActive: true
    );
  }

  Step stepTwo(runMutation) {
    var validateName = (String name) {
      if (name.trim().length == 0) return 'First Name is required.';
      return null;
    };

    var validateSurname = (String surname) {
      if (surname.trim().length == 0) return 'Last Name is required.';
      return null;
    };

    var form = GlobalKey<FormState>();

    return Step(
      title: Text('Personal Information', style: TextStyle(color: Color(0xffFFFFFF))),
      content: Form(
        key: form,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 30, top: 8),
              child: TextFormField(
                maxLines: 1,
                style: TextStyle(color: Color(0xffFFFFFF)),
                keyboardType: TextInputType.text,
                validator: validateName,
                decoration: singleDecoration('First Name'),
                // Store the provided name when the form is saved.
                onSaved: (value) => name = value,
              )
            ),
            Container(
              padding: EdgeInsets.only(right: 30, top: 8),
              child: TextFormField(
                maxLines: 1,
                style: TextStyle(color: Color(0xffFFFFFF)),
                keyboardType: TextInputType.text,
                validator: validateSurname,
                decoration: singleDecoration('Last Name'),
                // Store the provided name when the form is saved.
                onSaved: (value) => surname = value,
              )
            ),
            Container(
              padding: EdgeInsets.only(right: 30, top: 8),
              height: 60,
              child: FlatButton(
                splashColor: Color(0x49FFFFFF),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Color(0x80FFFFFF)),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.check, color: Color(0xffFFFFFF)),
                    Text('SP', style: TextStyle(color: Colors.transparent)),
                    Text('CONFIRM', style: TextStyle(color: Color(0xffFFFFFF)))
                  ],
                ),
                onPressed: () {
                  if (form.currentState.validate()) {
                    form.currentState.save();
                    setState(() => this.step = 2);
                    runMutation({
                      'name': '$name $surname',
                      'handle': '$username'
                    });
                  }
                },
              ),
            )
          ],
        )
      ),
      isActive: true
    );
  }

  Step stepThree() {
    return Step(
      title: Text('Signing In', style: TextStyle(color: Color(0xffFFFFFF))),
      content: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 30, top: 8),
            height: 10,
            child: LinearProgressIndicator(value: null)
          ),
        ],
      ),
      isActive: true
    );
  }

  void saveID(String id) async {
    var preferences = await SharedPreferences.getInstance();
    preferences.setString('userID', id);
  }

  void navigate() async {
    Navigator.pushNamedAndRemoveUntil(context, '/chat', (route) => false);
  }
}

// Convenience method to create TextFormField decorations, so the widget tree
// doesn't become too deep.
InputDecoration singleDecoration(String label) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10)
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Color(0x80FFFFFF))
    ),
    hasFloatingPlaceholder: true,
    labelStyle: TextStyle(
      fontSize: 16,
      color: Color(0x80FFFFFF)
    ),
    hintStyle: TextStyle(
      fontSize: 16,
      color: Color(0x80FFFFFF)
    ),
  );
}