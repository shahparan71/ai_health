import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImagePreviewScreen extends StatefulWidget {
  final List<AssetEntity> assets;
  final int initialIndex;

  const ImagePreviewScreen({
    super.key,
    required this.assets,
    required this.initialIndex,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final List<String> _deletedIds = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  Future<void> _deleteCurrent() async {
    final asset = widget.assets[_currentIndex];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete image?'),
        content: const Text('This will remove the image from your gallery.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final deleted = await PhotoManager.editor.deleteWithIds([asset.id]);
    if (deleted.length > 0) {
      _deletedIds.add(asset.id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image deleted')));
      if (_currentIndex >= widget.assets.length - 1) {
        _currentIndex = (widget.assets.length - 2).clamp(0, widget.assets.length - 2);
      }
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete failed')));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _deletedIds);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${_currentIndex + 1} / ${widget.assets.length}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteCurrent,
            ),
          ],
        ),
        body: PhotoViewGallery.builder(
          itemCount: widget.assets.length,
          pageController: _pageController,
          scrollPhysics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          builder: (context, index) {
            final asset = widget.assets[index];
            return PhotoViewGalleryPageOptions.customChild(
              child: FutureBuilder<Uint8List?>(
                future: asset.originBytes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data;
                  if (data == null || data.isEmpty) {
                    return const Center(child: Icon(Icons.broken_image));
                  }
                  return Image.memory(
                    data,
                    fit: BoxFit.contain,
                  );
                },
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 4,
              heroAttributes: PhotoViewHeroAttributes(tag: asset.id),
            );
          },
        ),
      ),
    );
  }
}


