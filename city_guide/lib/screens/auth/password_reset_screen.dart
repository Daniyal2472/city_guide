




import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool loading = false;
  sendEmailButton(String email)async{
    setState(() {
      loading = true;
    });
    try{
      await auth.sendPasswordResetEmail(email: email);
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email Sent Successfully")));
    }catch(e){
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error Sending Email")));
    }
  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
