// lib/page/login.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/core/utility/notification_widget.dart';
import 'package:flutter_bloc_template/data/auth/bloc/login/login_bloc.dart';
import 'package:flutter_bloc_template/page/widget/custom_button.dart';
import 'package:flutter_bloc_template/page/widget/input_text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _user = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Masuk')),
        body: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginFailure) {
              showAppMessage(context, state.errorMessage, isError: true);
            } else if (state is LoginSuccess) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
          builder: (context, state) {
            final loading = state is LoginLoading;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  InputText(
                      fieldKey: const Key('username'),
                      label: 'Username',
                      controller: _user),
                  const SizedBox(height: 12),
                  InputText(
                      fieldKey: const Key('password'),
                      label: 'Password',
                      controller: _pass,
                      obscure: true),
                  const SizedBox(height: 20),
                  if (loading)
                    const CircularProgressIndicator()
                  else
                    CustomButton(
                      text: 'Masuk',
                      onPressed: () => context.read<LoginBloc>().add(
                          LoginRequested(
                              username: _user.text.trim(),
                              password: _pass.text)),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
