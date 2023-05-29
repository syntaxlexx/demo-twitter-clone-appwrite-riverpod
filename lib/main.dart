import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

import 'common/common.dart';
import 'features/auth/controller/auth_controller.dart';
import 'features/auth/home/view/home_view.dart';
import 'features/auth/view/signup_view.dart';
import 'theme/theme.dart';

var logger = Logger();

void main() {
  runApp(const ProviderScope(child: MyApp()));

  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Twitter Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: ref.watch(currentUserAccountProvider).when(
            data: (user) {
              logger.d(user);
              return user != null ? const HomeView() : const SignupView();
            },
            error: (error, stackTrace) => ErrorPage(error: error.toString()),
            loading: () => const LoadingPage(),
          ),
    );
  }
}
