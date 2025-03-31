import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../../data/models/user_model.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthenticationEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String pin;
  final UserRole role;

  const LoginEvent({required this.pin, required this.role});

  @override
  List<Object?> get props => [pin, role];
}

class LogoutEvent extends AuthEvent {}

class VerifyAdminPinEvent extends AuthEvent {
  final String pin;

  const VerifyAdminPinEvent({required this.pin});

  @override
  List<Object?> get props => [pin];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AdminVerified extends AuthState {}

class AdminVerificationFailed extends AuthState {
  final String message;

  const AdminVerificationFailed({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthenticationError extends AuthState {
  final String message;

  const AuthenticationError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUseCases authUseCases;

  AuthBloc({required this.authUseCases}) : super(AuthInitial()) {
    on<CheckAuthenticationEvent>(_onCheckAuthentication);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<VerifyAdminPinEvent>(_onVerifyAdminPin);
  }

  Future<void> _onCheckAuthentication(
    CheckAuthenticationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authUseCases.checkAuthentication();
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthenticationError(message: e.toString()));
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final success = await authUseCases.loginUser(event.pin, event.role);
      if (success) {
        final user = await authUseCases.checkAuthentication();
        if (user != null) {
          emit(Authenticated(user: user));
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(const AuthenticationError(message: 'Invalid PIN'));
      }
    } catch (e) {
      emit(AuthenticationError(message: e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authUseCases.logoutUser();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthenticationError(message: e.toString()));
    }
  }

  Future<void> _onVerifyAdminPin(
    VerifyAdminPinEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isValid = await authUseCases.verifyAdminPin(event.pin);
      if (isValid) {
        emit(AdminVerified());
      } else {
        emit(const AdminVerificationFailed(message: 'Invalid admin PIN'));
      }
    } catch (e) {
      emit(AdminVerificationFailed(message: e.toString()));
    }
  }
}
