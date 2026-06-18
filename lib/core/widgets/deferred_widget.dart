import 'package:flutter/material.dart';

class DeferredLibraryHelper {
  static final Map<String, bool> _loadedLibraries = {};

  static bool isLoaded(String key) => _loadedLibraries[key] ?? false;

  static Future<void> load(String key, Future<void> Function() loader) async {
    if (isLoaded(key)) return;
    await loader();
    _loadedLibraries[key] = true;
  }
}

class DeferredWidget extends StatefulWidget {
  const DeferredWidget({
    super.key,
    required this.libraryKey,
    required this.libraryLoader,
    required this.builder,
    this.placeholder,
  });

  final String libraryKey;
  final Future<void> Function() libraryLoader;
  final Widget Function() builder;
  final Widget? placeholder;

  @override
  State<DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    if (!DeferredLibraryHelper.isLoaded(widget.libraryKey)) {
      _loadFuture = DeferredLibraryHelper.load(widget.libraryKey, widget.libraryLoader);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (DeferredLibraryHelper.isLoaded(widget.libraryKey)) {
      return widget.builder();
    }

    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent),
                  const SizedBox(height: 8),
                  Text('Failed to load module', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ),
            );
          }
          return widget.builder();
        }

        return widget.placeholder ??
            const Center(
              child: CircularProgressIndicator(),
            );
      },
    );
  }
}
