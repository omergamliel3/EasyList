import 'package:my_app/scoped-models/main.dart';
import 'package:flutter/material.dart';
import 'package:my_app/widgets/ui_elements/adaptive_progress_indicator.dart';
import 'package:my_app/widgets/ui_elements/battery_level.dart';
import 'package:scoped_model/scoped_model.dart';
import '../models/auth.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  // Class Attributes

  // Auto's Form GlobalKey
  final GlobalKey<FormState> _formKeyAuth = GlobalKey<FormState>();
  // Map to store form data
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'acceptTerms': false
  };
  // text editing controller
  final TextEditingController _passwordController = TextEditingController();

  // AuthMode enum default
  AuthMode _authMode = AuthMode.Login;

  // Animation Controller
  AnimationController _controller;
  Animation<Offset> _slideAnimation;

  @override
  void initState() {
    // set animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    // set slide animation for fade out confirm password input
    _slideAnimation = Tween<Offset>(begin: Offset(0.0, -2.0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    super.initState();
  }

  // Background image method
  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
        image: AssetImage('images/background.jpg'),
        fit: BoxFit.cover,
        colorFilter:
            ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop));
  }

  // Email Username text field widget method
  Widget _buildEmailUsernameTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'E-mail',
        hintText: 'E-mail',
      ),
      initialValue: 'omergamliel3@gmail.com',
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

  // Password text field widget method
  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Password',
      ),
      keyboardType: TextInputType.text,
      //initialValue: '123123123',
      controller: _passwordController,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Password is required';
        } else if (value.length < 5)
          return 'Password needs to be greater then 5';
      },
      obscureText: true,
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return FadeTransition(
      // set the animation transition curved
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeIn),
      child: SlideTransition(
        position: _slideAnimation,
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            hintText: 'Confirm Password',
          ),
          keyboardType: TextInputType.text,
          //initialValue: '12312312',
          obscureText: true,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Confirm Password is required';
            } else if (value != _passwordController.text &&
                _authMode == AuthMode.Signup) return 'Passwords do not match';
          },
        ),
      ),
    );
  }

  // Continue with Google ListTile widget
  Container _buildContinueGoogle() {
    return Container(
      child: ListTile(
        leading: Icon(Icons.account_circle),
        title: Text('Continue with Google'),
      ),
      color: Theme.of(context).accentColor,
    );
  }

  // Continue with Facebook ListTile widget
  Container _buildContinueFacebook() {
    return Container(
      child: ListTile(
        leading: Icon(Icons.account_circle),
        title: Text('Continue with Facebook'),
      ),
      color: Theme.of(context).accentColor,
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

  Container _buildLoginButton() {
    // Responsive Design MediaQuery calculations
    final double targetWidth = MediaQuery.of(context).size.width * 0.55;
    return Container(
      width: targetWidth,
      child: ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
          return model.isLoading
              ? Center(
                  child: AdaptiveProgressIndicator(),
                )
              : RaisedButton(
                  child: Text(_authMode == AuthMode.Login ? 'Login' : 'SignUp'),
                  color: Theme.of(context).accentColor,
                  textColor: Colors.white,
                  // submitForm method when button pressed
                  onPressed: () => _submitForm(model.authenticate),
                );
        },
      ),
    );
  }

  // function called every time the form submits
  void _submitForm(Function authenticate) async {
    // if not valid return
    if (!_formKeyAuth.currentState.validate()) {
      return;
    }
    // activate onSaved function in all FormFields
    _formKeyAuth.currentState.save();
    // exit keyboard
    _unFocusScope();
    // user info from the FORM
    final email = _formData['email'];
    final password = _formData['password'];
    // response information
    Map<String, dynamic> info;
    // acceptTerms check
    if (_authMode == AuthMode.Signup) {
      if (!_formData['acceptTerms']) {
        // return if user do not accept terms
        _showDialog(context);
        return;
      }
    }
    // authenticate function
    info =
        await authenticate(email: email, password: password, mode: _authMode);

    if (info['success']) {
      // authenticate succeeded, replace the page
    } else {
      // authenticate failed, show the error message from the http response
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('An Error Occurred!'),
              content: Text(info['message']),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  Container _buildCreateButton() {
    // Responsive Design MediaQuery calculations
    final double targetWidth = MediaQuery.of(context).size.width * 0.55;
    return Container(
      width: targetWidth,
      child: RaisedButton(
        child: Text('Sign-Up'),
        color: Theme.of(context).accentColor,
        textColor: Colors.white,
        onPressed: () {
          print('[Create Account Button] Pressed');
          // Navigate to Create Account Page
          Navigator.pushNamed(context, '/create_account');
        },
      ),
    );
  }

  Widget _buildSwitchModeFlatButton() {
    return FlatButton(
      child: Text(_authMode == AuthMode.Login ? 'Sign Up' : 'Log In'),
      onPressed: () {
        if (_authMode == AuthMode.Login) {
          setState(() {
            _authMode = AuthMode.Signup;
          });
          _controller.forward();
        } else {
          setState(() {
            _authMode = AuthMode.Login;
            _controller.reverse();
          });
        }
      },
    );
  }

  // build floatingActionButton Method
  Widget _buildfloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        print('[floatingActionButton] Pressed');
      },
      label: Text('Developer Version'),
      //child: Icon(Icons.developer_mode),
      backgroundColor: Theme.of(context).accentColor,
      icon: Icon(Icons.developer_mode),
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
      // appBar
      appBar: AppBar(
        title: Text('${_authMode == AuthMode.Login ? 'Log In' : 'Sign Up'}'),
      ),
      // body
      body: GestureDetector(
        onTap: _unFocusScope,
        child: Container(
          decoration: BoxDecoration(
              // adding body image background
              // image: _buildBackgroundImage(),
              ),
          padding: EdgeInsets.all(10.0),
          child: Center(
              child: SingleChildScrollView(
            child: Container(
              width: targetWidth,
              height: targetHeight,
              // Form
              child: Form(
                key: _formKeyAuth,
                child: Column(
                  children: <Widget>[
                    //_buildContinueGoogle(),
                    //SizedBox(
                    //  height: 10.0,
                    //),
                    //_buildContinueFacebook(),
                    //SizedBox(
                    //  height: 10,
                    //),
                    // E-mail / Username Text Field
                    _buildEmailUsernameTextField(),
                    // Password Text Field
                    _buildPasswordTextField(),
                    // adding space
                    SizedBox(height: 10.0),
                    _authMode == AuthMode.Signup
                        ? _buildConfirmPasswordTextField()
                        : Container(),
                    // adding space
                    SizedBox(height: 10.0),
                    _authMode == AuthMode.Signup
                        ? _buildTermsSwitchTile()
                        : Container(),
                    // adding space
                    SizedBox(height: 10.0),
                    // Login Button
                    _buildLoginButton(),
                    // Create Account Button
                    //_buildCreateButton(),
                    // adding space
                    SizedBox(height: 10.0),
                    _buildSwitchModeFlatButton(),
                  ],
                ),
              ),
            ),
          )),
        ),
      ),
      floatingActionButton: _buildfloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
