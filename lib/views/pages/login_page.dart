import 'package:aide_client/providers/login_provider.dart';
import 'package:aide_client/views/widgets/custom_button.dart';
import 'package:aide_client/views/widgets/custom_textfield.dart';
import 'package:aide_client/views/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          height: 400,
          width: 400,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.grey.shade900, width: 2),
            borderRadius: BorderRadius.circular(0),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Logo(),
              )),

              Center(
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Login to your account',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: CustomTextfield(
                  controller: loginProvider.emailController,
                  hintText: "Email",
                ),
              ),
              const SizedBox(height: 10),

              Center(
                child: CustomTextfield(
                  controller: loginProvider.passwordController,
                  hintText: "Password",
                  isPassword: true,
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: CustomButton(onPressed: ()async{
                  await loginProvider.login(context);
                }, text: "Login",
                isLoading: loginProvider.isLoading,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
