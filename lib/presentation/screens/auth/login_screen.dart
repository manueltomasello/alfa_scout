import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alfa_scout/presentation/router/path.dart';
import 'package:alfa_scout/presentation/blocs/auth/auth_cubit.dart';
import 'package:alfa_scout/presentation/blocs/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _loading = true);

      try {
        await context.read<AuthCubit>().signIn(_email, _password);
        if (!mounted) return;
        context.go(AppPaths.welcome);
      } catch (e) {
        if (!mounted) return;

        String errorMessage = 'Credenziali errate';

        final message = e.toString().toLowerCase();
        if (message.contains('network-request-failed')) {
          errorMessage = 'Connessione assente';
        } else if (message.contains('invalid-credential')) {
          errorMessage = 'Credenziali errate';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    final state = context.read<AuthCubit>().state;
    if (state is AuthAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppPaths.welcome);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => _email = value!.trim(),
                validator: (value) =>
                    value != null && value.contains('@') ? null : 'Email non valida',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (value) => _password = value!.trim(),
                validator: (value) =>
                    value != null && value.length >= 6 ? null : 'Min. 6 caratteri',
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Accedi'),
                    ),
              TextButton(
                onPressed: () => context.go(AppPaths.registration),
                child: const Text('Non hai un account? Registrati'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


