import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class DynamicAvatar extends StatelessWidget {

  const DynamicAvatar({
    super.key,
    this.photoUrl,
    this.displayName,
    this.email,
    this.size = 64,
  });
  final String? photoUrl;
  final String? displayName;
  final String? email;
  final double size;

  @override
  Widget build(BuildContext context) {
    final String initial = (displayName?.isNotEmpty == true)
        ? displayName![0].toUpperCase()
        : (email?.isNotEmpty == true)
            ? email![0].toUpperCase()
            : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: photoUrl != null
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallback(initial),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildFallback(initial);
                },
              )
            : _buildFallback(initial),
      ),
    );
  }

  Widget _buildFallback(String initial) {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1), // Indigo
            Color(0xFFA855F7), // Purple
            Color(0xFFEC4899), // Pink
          ],
        ),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

@widgetbook.UseCase(
  name: 'Default',
  type: DynamicAvatar,
)
Widget buildDynamicAvatarUseCase(BuildContext context) {
  return Center(
    child: DynamicAvatar(
      displayName: context.knobs.string(
        label: 'Display Name',
        initialValue: 'John Doe',
      ),
      email: context.knobs.string(
        label: 'Email',
        initialValue: 'john@example.com',
      ),
      size: context.knobs.double.slider(
        label: 'Size',
        initialValue: 64,
        min: 24,
        max: 200,
      ),
      photoUrl: context.knobs.stringOrNull(
        label: 'Photo URL',
        initialValue: null,
      ),
    ),
  );
}
