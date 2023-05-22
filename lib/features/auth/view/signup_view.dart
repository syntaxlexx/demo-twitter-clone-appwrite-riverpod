import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../../../contants/constants.dart';
import '../../../theme/theme.dart';
import '../controller/auth_controller.dart';
import '../widgets/auth_field.dart';
import 'login_view.dart';

class SignupView extends ConsumerStatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(builder: (context) => const SignupView());

  const SignupView({super.key});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  final appBar = UIConstants.appbar();

  final emailCtl = TextEditingController();
  final passwordCtl = TextEditingController();

  void onSignUp() {
    ref.read(authControllerProvider.notifier).signup(
          email: emailCtl.text,
          password: passwordCtl.text,
          context: context,
        );
  }

  @override
  void dispose() {
    emailCtl.dispose();
    passwordCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: appBar,
      body: isLoading
          ? const Loader()
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      AuthField(
                        controller: emailCtl,
                        hintText: 'Email',
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      AuthField(
                        controller: passwordCtl,
                        hintText: 'Password',
                        obscureText: true,
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: RoundedSmallButton(
                          label: 'Done',
                          onTap: onSignUp,
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Already have an account?',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          children: [
                            const WidgetSpan(
                              child: Padding(
                                padding: EdgeInsets.only(left: 10.0),
                              ),
                            ),
                            TextSpan(
                                text: 'Login',
                                style: const TextStyle(
                                  color: Pallete.blueColor,
                                  fontSize: 16,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(context, LoginView.route());
                                  }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
