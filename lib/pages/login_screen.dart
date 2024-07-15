import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:stock_tracking_firebase/pages/mainPage.dart';
import 'package:stock_tracking_firebase/pages/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  var email = '';
  var password = '';
  var isSending = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         automaticallyImplyLeading: false,
        title: const Text('Lütfen giriş yapınız'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Image.asset('assets/images/app_image.png'),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    maxLength: 30,
                    decoration: const InputDecoration(label: Text('E-mail')),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 1 ||
                          value.trim().length > 30) {
                        return 'Email en fazla 30 karakter olabilir.';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      email = newValue!;
                    },
                  ),
                  TextFormField(
                    maxLength: 15,
                    decoration: InputDecoration(
                      label: const Text('Parola'),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureText,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length < 6 ||
                          value.trim().length > 15) {
                        return 'Parola 6 ile 15 karakter arasında olmalıdır.';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      password = newValue!;
                    },
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ));
                        },
                        child: const Text('Hesap Oluştur'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            try {
                              setState(() {
                                isSending = true;
                              });
                              UserCredential userCredential =
                                  await _firebaseAuth
                                      .signInWithEmailAndPassword(
                                          email: email, password: password);

                              localStorage.setItem("email",
                                  userCredential.user!.email.toString());
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const Mainpage()));
                              setState(() {
                                isSending = false;
                              });
                            } on FirebaseAuthException catch (e) {
                              setState(() {
                                isSending = false;
                              });
                              String errorMessage;
                              switch (e.code) {
                                case 'invalid-credential':
                                  errorMessage = 'Geçersiz kimlik bilgileri.';
                                  break;
                                default:
                                  errorMessage =
                                      'Bir hata oluştu. Bilgilerinizi kontrol ediniz';
                              }

                              // Snackbar mesajını göster
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              
                            }
                          }
                        },
                        child: isSending
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Giriş Yap'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
