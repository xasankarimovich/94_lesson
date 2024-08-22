import 'package:bloc/bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:uyishi_94/bloc/user_event.dart';
import 'package:uyishi_94/data/repository/authenticationStatus.dart';

class User extends Equatable {
  const User(this.id);

  final String id;

  @override
  List<Object> get props => [id];

  static const empty = User('-');
}

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
    required UserRepository userRepository,
  })  : _authenticationRepository = authenticationRepository,
        _userRepository = userRepository,
        super(const AuthenticationState.unknown()) {
    on<AuthenticationSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthenticationLogoutPressed>(_onLogoutPressed);
  }

  final AuthenticationRepository _authenticationRepository;
  final UserRepository _userRepository;

  Future<void> _onSubscriptionRequested(
    AuthenticationSubscriptionRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    return emit.onEach<AuthenticationStatus>(
      _authenticationRepository.status,
      onData: (status) async {
        switch (status) {
          case AuthenticationStatus.unauthenticated:
            emit(const AuthenticationState.unauthenticated());
            break;
          case AuthenticationStatus.authenticated:
            final user = await _tryGetUser();
            emit(
              user != null
                  ? AuthenticationState.authenticated(user)
                  : const AuthenticationState.unauthenticated(),
            );
            break;
          case AuthenticationStatus.unknown:
            emit(const AuthenticationState.unknown());
            break;
        }
      },
      onError: addError,
    );
  }

  void _onLogoutPressed(
    AuthenticationLogoutPressed event,
    Emitter<AuthenticationState> emit,
  ) {
    _authenticationRepository.logOut();
  }

  Future<User?> _tryGetUser() async {
    try {
      final user = await _userRepository.getUser();
      return user;
    } catch (_) {
      return null;
    }
  }
}
