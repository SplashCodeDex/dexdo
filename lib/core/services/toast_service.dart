import 'dart:async';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

enum ToastType { success, error, info, warning }

class AppToast {
  AppToast({
    required this.id,
    required this.message,
    this.title,
    required this.type,
    this.duration = const Duration(seconds: 3),
    this.actionLabel,
    this.onAction,
  });

  final String id;
  final String message;
  final String? title;
  final ToastType type;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
}

final toastProvider = NotifierProvider<ToastNotifier, List<AppToast>>(() {
  return ToastNotifier();
});

class ToastNotifier extends Notifier<List<AppToast>> {
  final _uuid = const Uuid();

  @override
  List<AppToast> build() {
    return [];
  }

  void show({
    required String message,
    String? title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final id = _uuid.v4();
    final toast = AppToast(
      id: id,
      message: message,
      title: title,
      type: type,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
    
    state = [...state, toast];

    // Automatically dismiss after duration
    Timer(duration, () {
      dismiss(id);
    });
  }

  void showSuccess(String message, {String? title, Duration? duration, String? actionLabel, VoidCallback? onAction}) {
    show(
      message: message,
      title: title,
      type: ToastType.success,
      duration: duration ?? const Duration(seconds: 3),
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void showError(String message, {String? title, Duration? duration, String? actionLabel, VoidCallback? onAction}) {
    show(
      message: message,
      title: title,
      type: ToastType.error,
      duration: duration ?? const Duration(seconds: 4),
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void showInfo(String message, {String? title, Duration? duration, String? actionLabel, VoidCallback? onAction}) {
    show(
      message: message,
      title: title,
      type: ToastType.info,
      duration: duration ?? const Duration(seconds: 3),
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void showWarning(String message, {String? title, Duration? duration, String? actionLabel, VoidCallback? onAction}) {
    show(
      message: message,
      title: title,
      type: ToastType.warning,
      duration: duration ?? const Duration(seconds: 3),
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void dismiss(String id) {
    state = state.where((toast) => toast.id != id).toList();
  }
}
