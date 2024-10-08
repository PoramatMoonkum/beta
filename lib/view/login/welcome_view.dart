import 'package:flutter/material.dart';
import 'package:pettakecare/common/color_extension.dart';
import 'package:pettakecare/common_widget/round_button.dart';
import 'package:pettakecare/view/login/login_view.dart';
import 'package:pettakecare/view/login/sign_up.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.asset(
                  "assets/img/welcome_top_shape.png",
                  width: media.width,
                ),
                Image.asset(
                  "assets/img/app_logo.png",
                  width: media.width * 0.55,
                  height: media.width * 0.55,
                  fit: BoxFit.contain,
                ),
              ],
            ),

            SizedBox(height: media.width * 0.1),

            Text(
          "Discover the PetSitter \nrestaurants and fast delivery to your\ndoorstep",
          style: TextStyle(
              color: TColor.primaryText, fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
        ),

            SizedBox(height: media.width * 0.1),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal:25 ),
              child: RoundButton(title: "Login",
                  onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginView(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(
              height: 20,
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal:25 ),
              child: RoundButton(
                title:"Create an Account", 
                type: RoundButtonType.textPrimary, 
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpView(),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      )
    );
  }
}
          