import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/space_repository_impl.dart';
import '../../providers/space_providers.dart';
import '../../../utils/image_helper.dart';

class CreateSpaceSheet extends ConsumerStatefulWidget {
  final String? parentId;

  const CreateSpaceSheet({super.key, this.parentId});

  @override
  ConsumerState<CreateSpaceSheet> createState() => _CreateSpaceSheetState();
}

class _CreateSpaceSheetState extends ConsumerState<CreateSpaceSheet> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, // Or camera, could add choice
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle permission or other errors
      debugPrint('Error picking image: $e');
    }
  }



  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      String? savedImageFileName;
      if (_imageFile != null) {
        savedImageFileName = await ImageHelper.saveImage(_imageFile!);
      }

      await ref
          .read(spaceRepositoryProvider)
          .createSpace(
            name: _nameController.text,
            parentId: widget.parentId,
            imagePath: savedImageFileName,
          );

      if (mounted) {
        ref.invalidate(spacesProvider(parentId: widget.parentId));
        context.pop();
      }
    } catch (e) {
      debugPrint('Error creating space: $e');
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
                'New Space',
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
            placeholder: 'Space Name',
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
            ),
            autofocus: true,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                : const Text('Create Space'),
          ),
        ],
      ),
    );
  }
}
