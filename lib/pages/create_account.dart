import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  @override
  // Create State Method
  State<StatefulWidget> createState() {
    return _CreateAccountState();
  }
}

class _CreateAccountState extends State<CreateAccount> {
  // Class Attributes
  // Auto's Form GlobalKey
  final GlobalKey<FormState> _formKeyCreate = GlobalKey<FormState>();
  // text editing controller
  final TextEditingController _passwordController = TextEditingController();
  // Map to store form data
  final Map<String, dynamic> _formData = {
    'username': null,
    'email': null,
    'password': null,
    'phone': null,
    'acceptTerms': false
  };

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: (int value) =>
          print('[BottomNavigationBar] Pressed Bottom $value'),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).accentColor,
      // Bottom List Items
      items: <BottomNavigationBarItem>[
        // Bottom 1
        BottomNavigationBarItem(
            title: Text('About Us',
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.white)),
            icon: Icon(Icons.accessibility, color: Colors.black45)),
        // Bottom 2
        BottomNavigationBarItem(
            title: Text('Our Community',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            icon: Icon(Icons.public, color: Colors.black45)),
      ],
    );
  }

  Widget _buildUsernameTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Username',
        hintText: 'Enter Username',
      ),
      keyboardType: TextInputType.text,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Username is required';
        }
      },
      onSaved: (String value) {
        _formData['username'] = value;
      },
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'E-mail',
        hintText: 'Enter E-mail',
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty) {
          return 'E-mail is required';
        }
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter Password',
      ),
      keyboardType: TextInputType.text,
      controller: _passwordController,
      obscureText: true,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Password is required';
        }
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Confirm Password',
      ),
      keyboardType: TextInputType.text,
      obscureText: true,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Confirm Password is required';
        } else if (value != _passwordController.text)
        return 'Passwords do not match';
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildPhoneTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Phone',
        hintText: 'Enter Phone Number',
      ),
      keyboardType: TextInputType.phone,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Phone is required';
        } else if (!RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return 'Phone should be a number';
        }
      },
      onSaved: (String value) {
        _formData['phone'] = int.parse(value);
      },
    );
  }

  Widget _buildTermsSwitchTile() {
    return SwitchListTile(
      value: _formData['acceptTerms'],
      onChanged: (bool value) {
        setState(() {
          _formData['acceptTerms'] = value;
        });
      },
      title: Text('Accept Terms'),
    );
  }

  // show Dialog for users that does not accept terms
  _showDialog(BuildContext context) {
    // set the Dialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Text(
            'You must Accept Terms!',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold),
          ));
        });
  }

  void _submitForm() {
    bool formValidate = _formKeyCreate.currentState.validate();
    bool acceptTerms = _formData['acceptTerms'];
    // if form is not valid - return.
    if (!formValidate) {
      return;
    }
    // user did not accept terms
    if (!acceptTerms) {
      // show alert
      _showDialog(context);
      return;
    }
    // activate onSaved function in all FormFields
    _formKeyCreate.currentState.save();
    // exit keyboard
    _unFocusScope();
    // print the data for debugging
    print('[Create Account Button] Pressed');
    print('New Account Has Been Created: ');
    print('Username: ${_formData['username']}');
    print('E-mail: ${_formData['email']}');
    print('Password: ${_formData['password']}');
    print('Phone Num: ${_formData['phone']}');
    print('Accept Terms: ${_formData['acceptTerms']}');
    // Back to login page
    Navigator.pop(context);
  }

  Container _buildContinueButton() {
    // Responsive Design MediaQuery calculations
    final double targetWidth = MediaQuery.of(context).size.width * 0.55;

    return Container(
      width: targetWidth,
      child: RaisedButton(
        child: Text('Continue'),
        color: Theme.of(context).accentColor,
        textColor: Colors.white,
        onPressed: _submitForm,
      ),
    );
  }

// UnFocusScope Method
  void _unFocusScope() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    // Responsive Design MediaQuery calculations
    final double deviceWidth = MediaQuery.of(context).size.width;
    final targetWidth = deviceWidth > 768.0 ? 500.0 : deviceWidth * 0.95;
    final targetHeight = MediaQuery.of(context).size.height * 0.95;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sign-Up'),
      ),
      body: GestureDetector(
        onTap: _unFocusScope,
        child: Container(
            padding: EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Container(
                  width: targetWidth,
                  height: targetHeight,
                  child: Form(
                    key: _formKeyCreate,
                    child: Column(children: <Widget>[
                      // Username
                      _buildUsernameTextField(),
                      // E-mail
                      _buildEmailTextField(),
                      // Password
                      _buildPasswordTextField(),
                      // Confirm password
                      _buildConfirmPasswordTextField(),
                      // Phone
                      _buildPhoneTextField(),
                      // Accept Terms Switch List Tile
                      _buildTermsSwitchTile(),
                      // adding space
                      SizedBox(height: 10.0),
                      // Create Account Button
                      _buildContinueButton(),
                    ]),
                  )),
            )),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
