import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../../data/repositories/item_repository_impl.dart';
import '../../providers/item_providers.dart';
import '../../../domain/entities/item.dart';

class CreateItemSheet extends ConsumerStatefulWidget {
  final String spaceId;

  const CreateItemSheet({super.key, required this.spaceId});

  @override
  ConsumerState<CreateItemSheet> createState() => _CreateItemSheetState();
}

class _CreateItemSheetState extends ConsumerState<CreateItemSheet> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isLoading = false;
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<String?> _saveImageLocally(File image) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';
      final savedImage = await image.copy(p.join(appDir.path, fileName));
      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      String? savedImagePath;
      if (_imageFile != null) {
        savedImagePath = await _saveImageLocally(_imageFile!);
      }

      final item = Item(
        id: const Uuid().v4(),
        spaceId: widget.spaceId,
        name: _nameController.text,
        category: _categoryController.text.isNotEmpty
            ? _categoryController.text
            : null,
        status: ItemStatus.stored,
        imagePath: savedImagePath,
      );

      await ref.read(itemRepositoryProvider).createItem(item);

      if (mounted) {
        ref.invalidate(itemsInSpaceProvider(widget.spaceId));
        context.pop();
      }
    } catch (e) {
      debugPrint('Error creating item: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New Item',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: CupertinoColors.systemGrey,
                ),
                onPressed: () => context.pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(16),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? const Icon(
                        CupertinoIcons.camera_fill,
                        size: 40,
                        color: CupertinoColors.systemGrey,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Add Photo',
              style: TextStyle(color: CupertinoColors.systemBlue, fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          CupertinoTextField(
            controller: _nameController,
            placeholder: 'Item Name',
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: _categoryController,
            placeholder: 'Category (Optional)',
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                : const Text('Create Item'),
          ),
        ],
      ),
    );
  }
}
