abstract class AuthenticationState {}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {
  final String userId;

  AuthenticationAuthenticated(this.userId);
}

class AuthenticationError extends AuthenticationState {
  final String message;

  AuthenticationError(this.message);
}

class AuthenticationUnauthenticated extends AuthenticationState {}
