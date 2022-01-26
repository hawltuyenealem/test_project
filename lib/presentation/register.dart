

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test_project/data_provider/authentication.dart';
import 'package:test_project/constants/color.dart';
import 'package:test_project/presentation/dialog.dart';
import 'package:test_project/presentation/home_page.dart';
import 'package:test_project/presentation/login.dart';
import 'package:test_project/models/user.dart';

class SignUpPage extends StatefulWidget {
  static const String routeName = "/register";



  @override
  _SignUpPage createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  bool _showPassword = false;
  String _email = "";
  String _username = "";
  String _password = "";

  // ignore: non_constant_identifier_names
  String _role_id = "";
  bool _isLoading = false;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late AccountType selectedAccount;
  final _auth = FirebaseAuth.instance;

  // string for displaying the error Message
  String? errorMessage;
  List<AccountType> accountTypes = [
    const AccountType(
        accountIcon: Icon(Icons.person), accountName: 'Job Seeker'),
    const AccountType(accountIcon: Icon(Icons.home), accountName: 'Company'),
  ];

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((value) => {postDetailsToFirestore()})
            .catchError((e) {
          Fluttertoast.showToast(msg: e!.message);
        });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        Fluttertoast.showToast(msg: errorMessage!);
        print(error.code);
      }
    }
  }
  postDetailsToFirestore() async {
    // calling our firestore
    // calling our user model
    // sedning these values

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    // writing all the values
    userModel.email = user.email;
    userModel.uid = user.uid;
    userModel.userName = _usernameController.text.trim();

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());
    Fluttertoast.showToast(msg: "Account created successfully :) ");

    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final signUpButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.redAccent,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            signUp(_emailController.text.trim(),_passwordController.text.trim());
          },
          child: Text(
            "SignUp",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );
    bool isKeyboardShowing = MediaQuery
        .of(context)
        .viewInsets
        .vertical > 0;

    void _showError(String error) {
      // Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text(error),
      //   backgroundColor: Theme.of(context).errorColor,
      // ));
      _scaffoldKey.currentState!.showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme
              .of(context)
              .errorColor,
        ),
      );
    }

    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        body:
        SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  logo(isKeyboardShowing),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        _buildUserNameTextField(),
                        SizedBox(
                          height: 10,
                        ),
                        _buildEmailTextField(),
                        SizedBox(
                          height: 10,
                        ),
                        _buildPasswordTextField(),
                        SizedBox(
                          height: 10,
                        ),
                        //_buildChooseAccountType(),

                       signUpButton,
                       // _submitButton(),
                        SizedBox(
                          height: 10.0,
                        ),
                        _createAccountLabel(),
                        SizedBox(
                          height: 10.0,
                        ),
                      ],
                    ),
                  )
                ],
              )),
        )

    );
  }

  Widget logo(isKeyboardShowing) {
    return ClipPath(
      clipper: BezierClipper(),
      child: Container(
          decoration: BoxDecoration(
              color: Color(0xFF1f40b7),
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    kBrown100,
                    kBrown400,
                  ])),
          width: double.infinity,
          height: isKeyboardShowing
              ? MediaQuery.of(context).size.height * 0.25
              : MediaQuery.of(context).size.height * 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: isKeyboardShowing ? 0.0 : 100.0,
                width: 500,
                // child: Image.asset(
                //   'assets/images/logo.png',
                //   fit: BoxFit.cover,
                // ),
              ),
              SizedBox(
                height: isKeyboardShowing ? 0.0 : 30.0,
              ),
              Text(
                'Register',
                style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          )),
    );
  }

  Widget _buildUserNameTextField() {
    return TextFormField(
      controller: _usernameController,
      validator: (value) =>
      value!.length <= 4 ? "User Name must be at least 4 character" : null,
      onSaved: (value) => _username = value!,
      onChanged: (value) => _username = value,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Username',
        focusColor: Color(0xff4064f3),
        labelStyle: TextStyle(
          color: Color(0xff4064f3),
        ),
        border: InputBorder.none,
        filled: true,
        fillColor: Color(0xfff3f3f4),
        prefixIcon: Icon(Icons.person),
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(5),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Already have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Login',
              style: TextStyle(
                  color: Color(0xff4064f3),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      controller: _emailController,
      onChanged: (value) => _email = value,
      validator: (value) => !isEmail(value!)
          ? "Sorry, we do not recognize this email address"
          : null,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        // alignLabelWithHint: true,
        prefixIcon: Icon(Icons.alternate_email),
        // hintText: 'Enter your email',
        border: InputBorder.none,
        filled: true,
        fillColor: Color(0xfff3f3f4),
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      controller: _passwordController,
      validator: (value) => value!.length <= 6
          ? "Password must be 6 or more characters in length"
          : null,
      obscureText: !this._showPassword,
      onChanged: (value) => _password = value,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Password',
        focusColor: Color(0xff4064f3),
        labelStyle: TextStyle(
          color: Color(0xff4064f3),
        ),
        border: InputBorder.none,
        filled: true,
        fillColor: Color(0xfff3f3f4),
        prefixIcon: Icon(Icons.security),
        suffixIcon: IconButton(
          icon: this._showPassword
              ? FaIcon(FontAwesomeIcons.eye)
              : FaIcon(FontAwesomeIcons.eyeSlash),
          onPressed: () {
            setState(() => this._showPassword = !this._showPassword);
          },
        ),
      ),
    );
  }

  Widget _buildChooseAccountType() {
    return DropdownButton<AccountType>(
      hint: Text('Select Account Type'),
      value: selectedAccount,
     /* onChanged: (AccountType value) {
        if (value.accountName == 'Company') {
          this._role_id = "603a84416090c2311190aead";

          //603ba9a11bd36aa35679ec4c
        } else {
          this._role_id = "603a84396090c2311190aeac";

          //603ba9cf1bd36aa35679ec4d
        }
        setState(() {
          selectedAccount = value;
        });
      },*/
      items: accountTypes.map((AccountType accountType) {
        return DropdownMenuItem(
          value: accountType,
          child: Row(
            children: <Widget>[
              accountType.accountIcon,
              SizedBox(
                width: 20.0,
              ),
              Text(accountType.accountName)
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _submitButton() {
    return RaisedButton(
      onPressed: () {

       /* final form = _formKey.currentState;
        if (form.validate()) {
          form.save();
          BlocProvider.of<RegisterBloc>(context).add(RegisterUser(
              username: _username,
              email: _email,
              password: _password,
              role_id: _role_id));
        }*/
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  kBrown100,
                  kBrown900,
                ])),
        child: _isLoading == true
            ? DialogBox().loading(context)
            : Text('SignUp',
            // style: TextStyle(fontSize: 20, color: Colors.white),
            style: TextStyle(color: Colors.white, fontSize: 18.0)),
      ),
    );
  }

  bool isEmail(String value) {
    String regex =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(regex);

    return value.isNotEmpty && regExp.hasMatch(value);
  }
}

class AccountType {
  const AccountType({ required this.accountIcon, required this.accountName});
  final Icon accountIcon;
  final String accountName;
}
