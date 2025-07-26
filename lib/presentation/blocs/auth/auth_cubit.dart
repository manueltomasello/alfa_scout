import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
 final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthCubit() : super(AuthLoading()) {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }
 
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
  UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
  await userCredential.user?.sendEmailVerification();

}
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
