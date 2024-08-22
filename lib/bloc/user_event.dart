import 'dart:async';

import 'package:formz/formz.dart';
import 'package:uuid/uuid.dart';

import 'package:equatable/equatable.dart';
import 'package:uyishi_94/bloc/user_bloc.dart';
import 'package:uyishi_94/data/model/password.dart';
import 'package:uyishi_94/data/model/username.dart';
import 'package:uyishi_94/data/repository/authenticationStatus.dart';

sealed class AuthenticationEvent {
  const AuthenticationEvent();
}

final class AuthenticationSubscriptionRequested extends AuthenticationEvent {}

final class AuthenticationLogoutPressed extends AuthenticationEvent {}

class UserRepository {
  User? _user;

  Future<User?> getUser() async {
    if (_user != null) return _user;
    return Future.delayed(
      const Duration(milliseconds: 300),
      () => _user = User(const Uuid().v4()),
    );
  }
}

class AuthenticationState extends Equatable {
  const AuthenticationState._({
    this.status = AuthenticationStatus.unknown,
    this.user = User.empty,
  });

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(User user)
      : this._(status: AuthenticationStatus.authenticated, user: user);

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  final AuthenticationStatus status;
  final User user;

  @override
  List<Object> get props => [status, user];
}

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

final class LoginUsernameChanged extends LoginEvent {
  const LoginUsernameChanged(this.username);

  final String username;

  @override
  List<Object> get props => [username];
}

final class LoginPasswordChanged extends LoginEvent {
  const LoginPasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

final class LoginState extends Equatable {
  const LoginState({
    this.status = FormzSubmissionStatus.initial,
    this.username = const Username.pure(),
    this.password = const Password.pure(),
    this.isValid = false,
  });

  final FormzSubmissionStatus status;
  final Username username;
  final Password password;
  final bool isValid;

  LoginState copyWith({
    FormzSubmissionStatus? status,
    Username? username,
    Password? password,
    bool? isValid,
  }) {
    return LoginState(
      status: status ?? this.status,
      username: username ?? this.username,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object> get props => [status, username, password];
}
