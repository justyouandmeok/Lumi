import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/scope.dart';
import '../theme.dart';

class ComposePage extends StatefulWidget {
  const ComposePage({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<ComposePage> createState() => _ComposePageState();
}

class _ComposePageState extends State<ComposePage> {
  final _caption = TextEditingController();
  bool _publishing = false;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_publishing) return;
    setState(() => _publishing = true);
    final store = AppStateScope.of(context);
    await store.publish(
      localImagePath: widget.imagePath,
      caption: _caption.text,
    );
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            SizedBox(height: top),
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  TextButton(
                    onPressed: _publishing ? null : _publish,
                    child: _publishing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Publicar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            ColoredBox(
              color: NexoColors.surface,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: TextField(
                    controller: _caption,
                    maxLines: 4,
                    minLines: 2,
                    maxLength: 2200,
                    decoration: const InputDecoration(
                      hintText: 'Escribí un pie de foto, un tema o un #hashtag',
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
