import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'image_preview_screen.dart';

enum GallerySort { newest, oldest, name }

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _loading = true;
  bool _permissionDenied = false;
  List<AssetEntity> _assets = [];
  GallerySort _sort = GallerySort.newest;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoad();
  }

  Future<void> _requestPermissionAndLoad() async {
    setState(() {
      _loading = true;
    });

    final PermissionState result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      await _loadAssets();
      setState(() {
        _permissionDenied = false;
        _loading = false;
      });
    } else {
      setState(() {
        _permissionDenied = true;
        _loading = false;
      });
    }
  }

  Future<void> _loadAssets() async {
    final paths = await PhotoManager.getAssetPathList(type: RequestType.image);
    final List<AssetEntity> all = [];
    for (final path in paths) {
      final assets = await path.getAssetListRange(start: 0, end: await path.assetCountAsync);
      all.addAll(assets);
    }
    _assets = all;
    _applySort();
  }

  void _applySort() {
    _assets.sort((a, b) {
      switch (_sort) {
        case GallerySort.newest:
          return (b.createDateTime).compareTo(a.createDateTime);
        case GallerySort.oldest:
          return (a.createDateTime).compareTo(b.createDateTime);
        case GallerySort.name:
          return (a.title ?? '').toLowerCase().compareTo((b.title ?? '').toLowerCase());
      }
    });
    setState(() {});
  }

  Future<void> _openPreview(int index) async {
    final deletedIds = await Navigator.push<List<String>?>(
      context,
      MaterialPageRoute(
        builder: (_) => ImagePreviewScreen(
          assets: _assets,
          initialIndex: index,
        ),
      ),
    );

    if (deletedIds != null && deletedIds.isNotEmpty) {
      _assets.removeWhere((asset) => deletedIds.contains(asset.id));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        actions: [
          PopupMenuButton<GallerySort>(
            initialValue: _sort,
            onSelected: (value) {
              _sort = value;
              _applySort();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: GallerySort.newest, child: Text('Newest first')),
              const PopupMenuItem(value: GallerySort.oldest, child: Text('Oldest first')),
              const PopupMenuItem(value: GallerySort.name, child: Text('Name A-Z')),
            ],
            icon: const Icon(Icons.sort),
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

    if (_permissionDenied) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Gallery access is denied.\nPlease allow photo permissions.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  PhotoManager.openSetting();
                },
                child: const Text('Open Settings'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _requestPermissionAndLoad,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_library_outlined, size: 72, color: Colors.grey),
            const SizedBox(height: 12),
            Text('No images found', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _requestPermissionAndLoad(),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: _assets.length,
        itemBuilder: (context, index) {
          final asset = _assets[index];
          return GestureDetector(
            onTap: () => _openPreview(index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FutureBuilder<Uint8List?>(
                future: asset.thumbnailDataWithSize(const ThumbnailSize(300, 300)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Container(color: Colors.grey[200]);
                  }
                  final data = snapshot.data;
                  if (data == null) {
                    return const Icon(Icons.broken_image);
                  }
                  return Image.memory(
                    data,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}


