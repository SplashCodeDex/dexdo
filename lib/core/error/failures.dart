import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
abstract class Failure extends Equatable {
  final String message;
  final dynamic originalError;

  const Failure(this.message, {this.originalError});

  @override
  List<Object?> get props => [message, originalError];
}

/// Represents a failure related to server/database operations.
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.originalError});
}

/// Represents a failure related to local persistence.
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.originalError});
}

/// Represents a failure related to AI services.
class AIFailure extends Failure {
  const AIFailure(super.message, {super.originalError});
}

/// Represents a failure related to user authentication.
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.originalError});
}

/// Helper to map common exceptions to Failures.
class FailureMapper {
  static Failure map(dynamic error) {
    // This can be expanded as more specific error types are identified
    final message = error.toString();
    
    if (message.contains('firebase') || message.contains('firestore')) {
      return ServerFailure('Cloud sync failed. Please check your connection.', originalError: error);
    }
    
    if (message.contains('isar') || message.contains('SharedPreferences')) {
      return CacheFailure('Local storage error. Some data might be missing.', originalError: error);
    }

    if (message.contains('GoogleGenerativeAI')) {
      return AIFailure('AI is currently unavailable. Please try again later.', originalError: error);
    }
    
    return ServerFailure('An unexpected error occurred.', originalError: error);
  }
}
