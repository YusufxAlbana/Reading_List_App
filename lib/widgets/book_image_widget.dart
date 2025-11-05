import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Widget to show a book image (network or local file) and optionally allow
/// picking a new image from camera or gallery.
///
/// Usage:
/// - Provide [imageUrl] which can be a network URL (starts with http) or a
///   local file path. If null, a placeholder is shown.
/// - Set [editable] to true to allow tapping the image to change it. When a
///   new image is picked it will be copied into the app documents directory
///   and [onImageChanged] will be called with the new local path.
class BookImageWidget extends StatefulWidget {
	final String? imageUrl;
	final double size;
	final bool editable;
	final ValueChanged<String?>? onImageChanged;

	const BookImageWidget({
		super.key,
		this.imageUrl,
		this.size = 96,
		this.editable = true,
		this.onImageChanged,
	});

	@override
	State<BookImageWidget> createState() => _BookImageWidgetState();
}

class _BookImageWidgetState extends State<BookImageWidget> {
	String? _currentPath;
	final ImagePicker _picker = ImagePicker();

	@override
	void initState() {
		super.initState();
		_currentPath = widget.imageUrl;
	}

	@override
	void didUpdateWidget(covariant BookImageWidget oldWidget) {
		super.didUpdateWidget(oldWidget);
		if (oldWidget.imageUrl != widget.imageUrl) {
			_currentPath = widget.imageUrl;
		}
	}

	Future<void> _pick(ImageSource source) async {
		try {
			final picked = await _picker.pickImage(
				source: source,
				maxWidth: 1200,
				maxHeight: 1200,
				imageQuality: 85,
			);
			if (picked == null) return;

			if (kIsWeb) {
				// On web, convert picked file into data URI
				final bytes = await picked.readAsBytes();
				final b64 = base64Encode(bytes);
				final ext = p.extension(picked.name).toLowerCase();
				String mime = 'image/png';
				if (ext == '.jpg' || ext == '.jpeg') mime = 'image/jpeg';
				if (ext == '.gif') mime = 'image/gif';
				final dataUri = 'data:$mime;base64,$b64';
				setState(() => _currentPath = dataUri);
				if (widget.onImageChanged != null) widget.onImageChanged!(_currentPath);
			} else {
				// Copy file into app documents directory for persistence
				final appDir = await getApplicationDocumentsDirectory();
				final fileName = p.basename(picked.path);
				final saved = await File(picked.path).copy('${appDir.path}/$fileName');
				setState(() {
					_currentPath = saved.path;
				});
				if (widget.onImageChanged != null) widget.onImageChanged!(_currentPath);
			}
		} catch (e) {
			// ignore: use_build_context_synchronously
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('Gagal memilih gambar: $e')),
				);
			}
		}
	}

	void _showPickerOptions() {
		showModalBottomSheet(
			context: context,
			builder: (ctx) => SafeArea(
				child: Wrap(
					children: [
						ListTile(
							leading: const Icon(Icons.photo_library),
							title: const Text('Pilih dari Galeri'),
							onTap: () {
								Navigator.of(ctx).pop();
								_pick(ImageSource.gallery);
							},
						),
						ListTile(
							leading: const Icon(Icons.photo_camera),
							title: const Text('Ambil Foto'),
							onTap: () {
								Navigator.of(ctx).pop();
								_pick(ImageSource.camera);
							},
						),
						if (_currentPath != null)
							ListTile(
								leading: const Icon(Icons.delete_forever),
								title: const Text('Hapus Gambar'),
								onTap: () async {
									Navigator.of(ctx).pop();
									// delete file if local
									try {
										if (!_currentPath!.startsWith('http')) {
											// don't try to delete data URI or on web
											if (!(kIsWeb) && !_currentPath!.startsWith('data:')) {
												final f = File(_currentPath!);
												if (await f.exists()) await f.delete();
											}
										}
									} catch (_) {}
									setState(() => _currentPath = null);
									if (widget.onImageChanged != null) widget.onImageChanged!(null);
								},
							),
					],
				),
			),
		);
	}

	Widget _buildImage() {
		final size = widget.size;
		if (_currentPath == null || _currentPath!.isEmpty) {
			return Container(
				width: size,
				height: size,
				decoration: BoxDecoration(
					color: Colors.grey[200],
					borderRadius: BorderRadius.circular(8),
				),
				child: Icon(
					Icons.photo,
					size: size * 0.45,
					color: Colors.grey[600],
				),
			);
		}

		if (_currentPath!.startsWith('http')) {
			return ClipRRect(
				borderRadius: BorderRadius.circular(8),
				child: Image.network(
					_currentPath!,
					width: size,
					height: size,
					fit: BoxFit.cover,
					errorBuilder: (c, o, s) => Container(
						width: size,
						height: size,
						color: Colors.grey[200],
						child: const Icon(Icons.broken_image),
					),
				),
			);
		}

		// Data URI support
		if (_currentPath!.startsWith('data:')) {
			try {
				final uri = _currentPath!;
				final comma = uri.indexOf(',');
				if (comma != -1) {
					final metadata = uri.substring(5, comma);
					final isBase64 = metadata.contains('base64');
					final dataPart = uri.substring(comma + 1);
					Uint8List bytes = isBase64 ? base64Decode(dataPart) : Uint8List.fromList(Uri.decodeFull(dataPart).codeUnits);

					return ClipRRect(
						borderRadius: BorderRadius.circular(8),
						child: Image.memory(
							bytes,
							width: size,
							height: size,
							fit: BoxFit.cover,
							errorBuilder: (c, o, s) => Container(
								width: size,
								height: size,
								color: Colors.grey[200],
								child: const Icon(Icons.broken_image),
							),
						),
					);
				}
			} catch (_) {}
			// fallthrough to placeholder
		}

		// Fallback: local file (non-web)
		if (kIsWeb) {
			return Container(
				width: size,
				height: size,
				decoration: BoxDecoration(
					color: Colors.grey[200],
					borderRadius: BorderRadius.circular(8),
				),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						const Icon(Icons.broken_image),
						const SizedBox(height: 6),
						Text('Gambar lokal tidak didukung di Web', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
					],
				),
			);
		}

		final file = File(_currentPath!);
		return ClipRRect(
			borderRadius: BorderRadius.circular(8),
			child: Image.file(
				file,
				width: size,
				height: size,
				fit: BoxFit.cover,
				errorBuilder: (c, o, s) => Container(
					width: size,
					height: size,
					color: Colors.grey[200],
					child: const Icon(Icons.broken_image),
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: widget.editable ? _showPickerOptions : null,
			child: Stack(
				alignment: Alignment.center,
				children: [
					_buildImage(),
					if (widget.editable)
						Positioned(
							right: 4,
							bottom: 4,
							child: Container(
								decoration: BoxDecoration(
									color: Colors.black45,
									borderRadius: BorderRadius.circular(20),
								),
								padding: const EdgeInsets.all(4),
								child: const Icon(
									Icons.edit,
									size: 16,
									color: Colors.white,
								),
							),
						),
				],
			),
		);
	}
}

