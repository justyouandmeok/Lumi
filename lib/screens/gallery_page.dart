import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../theme.dart';
import 'compose_page.dart';

enum GalleryPurpose { publish, avatar }

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key, this.purpose = GalleryPurpose.publish});

  final GalleryPurpose purpose;

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final List<AssetEntity> _assets = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final perm = await PhotoManager.requestPermissionExtend();
    if (!perm.isAuth && !perm.hasAccess) {
      setState(() {
        _loading = false;
        _error =
            'Necesitamos permiso para ver tus fotos. Activalo y volvé a intentar.';
      });
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
    if (albums.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'No encontramos fotos en este teléfono.';
      });
      return;
    }

    final recent = albums.first;
    final count = await recent.assetCountAsync;
    final list = await recent.getAssetListRange(
      start: 0,
      end: count.clamp(0, 400),
    );
    list.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

    if (!mounted) return;
    setState(() {
      _assets
        ..clear()
        ..addAll(list);
      _loading = false;
    });
  }

  Future<void> _openSettings() async {
    await PhotoManager.openSetting();
    await _load();
  }

  Future<void> _pick(AssetEntity asset) async {
    final file = await asset.file;
    if (file == null || !mounted) return;
    if (widget.purpose == GalleryPurpose.avatar) {
      Navigator.of(context).pop(file.path);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComposePage(imagePath: file.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexoColors.surface,
      appBar: AppBar(
        title: Text(
          widget.purpose == GalleryPurpose.avatar
              ? 'Elegir foto de perfil'
              : 'Nueva publicación',
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _openSettings,
              child: const Text('Abrir ajustes'),
            ),
          ],
        ),
      );
    }
    if (_assets.isEmpty) {
      return const Center(child: Text('No hay fotos todavía.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            'Lo más reciente primero · solo se publica en 1:1',
            style: TextStyle(color: NexoColors.muted, fontSize: 13),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemCount: _assets.length,
            itemBuilder: (context, i) {
              return _Thumb(
                asset: _assets[i],
                onTap: () => _pick(_assets[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.asset, required this.onTap});

  final AssetEntity asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize.square(300)),
      builder: (context, snap) {
        return GestureDetector(
          onTap: onTap,
          child: ColoredBox(
            color: const Color(0xFFEEEEEE),
            child: snap.data == null
                ? const SizedBox.expand()
                : Image.memory(snap.data!, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}
