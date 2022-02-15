import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic>? _userData;
  AccessToken? _accessToken;
  bool _checking = true;
  GoogleSignInAccount? _currentUser;
  String _contactText = '';

  @override
  void initState() {
    super.initState();
    _checkIfIsLogged();

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _checkIfIsLogged() async {
    final accessToken = await FacebookAuth.instance.accessToken;
    setState(() {
      _checking = false;
    });
    if (accessToken != null) {
      print("is Logged:::: ${accessToken.toJson()}");
      final userData = await FacebookAuth.instance.getUserData();

      _accessToken = accessToken;
      setState(() {
        _userData = userData;
      });
    }
  }

  Future<void> _loginFB() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      _accessToken = result.accessToken;
      print(_accessToken);

      final userData = await FacebookAuth.instance.getUserData();

      _userData = userData;
    } else {
      print(result.status);
      print(result.message);
    }

    setState(() {
      _checking = false;
    });
  }

  Future<void> _logOutFB() async {
    await FacebookAuth.instance.logOut();
    _accessToken = null;
    _userData = null;
    setState(() {});
  }

  Future<void> _loginGoogle() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _logoutGoogle() async {
    _googleSignIn.disconnect();
    _currentUser = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Example'),
      ),
      body: _checking
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Text(
                    //   _userData != null
                    //       ? _userData.toString()
                    //       : "NOT LOGGED IN",
                    // ),
                    _userData != null
                        ? ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                _userData!["picture"]["data"]["url"],
                              ),
                            ),
                            title: Text(_userData!["name"]),
                            subtitle: Text(_userData!["email"]),
                          )
                        : Text(
                            'Not logged in',
                          ),
                    const SizedBox(height: 20),
                    TextButton(
                      child: Text(
                        _userData != null
                            ? "Logout Facebook"
                            : "Login via Facebook",
                      ),
                      onPressed: _userData != null ? _logOutFB : _loginFB,
                    ),
                    const SizedBox(height: 50),
                    _currentUser != null
                        ? ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                _currentUser!.photoUrl!,
                              ),
                            ),
                            title: Text(_currentUser!.displayName!),
                            subtitle: Text(_currentUser!.email),
                          )
                        : Text(
                            'Not logged in',
                          ),
                    const SizedBox(height: 20),
                    TextButton(
                      child: Text(
                        _currentUser != null
                            ? "Logout Google"
                            : "Login via Google",
                      ),
                      onPressed:
                          _currentUser != null ? _logoutGoogle : _loginGoogle,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
