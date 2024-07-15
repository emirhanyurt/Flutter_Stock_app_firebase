import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stock_tracking_firebase/pages/login_screen.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
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
        title: const Text('Kayıt Ekranı'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(label: Text('E-mail')),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
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
                      _obscureText ? Icons.visibility : Icons.visibility_off,
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
                      Navigator.of(context).pop();
                    },
                    child: const Text('Geri'),
                  ),
                  ElevatedButton(
             
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        setState(() {
                          isSending = true;
                        });
                        try {
                          await _firebaseAuth.createUserWithEmailAndPassword(
                              email: email, password: password);
                                 Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
                                 setState(() {
                          isSending = false;
                        });
                        } catch (e) {
                          setState(() {
                          isSending = false;
                        });
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Bir hata ile karşılaşıldı.Lütfen bilgilerinizinin uygun formatda olduğundan emin olunuz."),
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
                              ): const Text('Kayıt Ol'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
