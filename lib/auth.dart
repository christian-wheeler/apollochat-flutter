import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AuthScreen extends StatefulWidget {

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {

  int step = 0;
  String name;
  String surname;
  String username;

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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          brightness: Brightness.dark,
        ),
        body: Container(
          child: Mutation(
            mutation,
            builder: ( runMutation, { bool loading, var data, Exception error }) {

              if (error != null) {
                showError(context, error.toString());
              }

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
              print(data);
              var id = data['addUser']['id'];
              print('user created successfully $id');
              saveID(id);
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
      // Title of the Step
        title: Text('Authentication', style: TextStyle(color: Color(0xffFFFFFF))),
        // Content, it can be any widget here. Using basic Text for this example
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
                    onSaved: (value) => name = value,
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
      return 'First Name is required.';
    };

    var validateSurname = (String surname) {
      if (surname.trim().length == 0) return 'Last Name is required.';
      return null;
    };

    var form = GlobalKey<FormState>();

    return Step(
      // Title of the Step
        title: Text('Personal Information', style: TextStyle(color: Color(0xffFFFFFF))),
        // Content, it can be any widget here. Using basic Text for this example
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
      // Title of the Step
        title: Text('Signing In', style: TextStyle(color: Color(0xffFFFFFF))),
        // Content, it can be any widget here. Using basic Text for this example
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

  void saveUser(runMutation) {
    /*var user = User('', DateTime.now(), DateTime.now(), name, surname, '', '', '', '', {});
    Repository<User> users = Inject().users;

    users.create(user)
        .listen((u) {
      print('user created successfully ${u.id}');
      saveID(u.id);
      navigate();
    });*/
  }

  void saveID(String id) async {
    var preferences = await SharedPreferences.getInstance();
    preferences.setString('userID', id);
  }

  void navigate() async {
    Navigator.pushNamedAndRemoveUntil(context, '/chat', (route) => false);
  }
}

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