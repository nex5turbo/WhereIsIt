import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../data/repositories/item_repository_impl.dart';
import '../../providers/item_providers.dart';
import '../../../domain/entities/item.dart';
import '../../../utils/image_helper.dart';

class CreateItemSheet extends ConsumerStatefulWidget {
  final String spaceId;
  final Item? existingItem;

  const CreateItemSheet({
    super.key,
    required this.spaceId,
    this.existingItem,
  });

  @override
  ConsumerState<CreateItemSheet> createState() => _CreateItemSheetState();
}

class _CreateItemSheetState extends ConsumerState<CreateItemSheet> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  bool _isLoading = false;
  bool _trackQuantity = false;
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      _nameController.text = widget.existingItem!.name;
      _categoryController.text = widget.existingItem!.category ?? '';
      if (widget.existingItem!.quantity != null) {
        _trackQuantity = true;
        _quantityController.text = widget.existingItem!.quantity.toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
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



  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      String? savedImageFileName;
      if (_imageFile != null) {
        savedImageFileName = await ImageHelper.saveImage(_imageFile!);
      } else if (widget.existingItem != null) {
        savedImageFileName = widget.existingItem!.imagePath;
      }

      if (widget.existingItem != null) {
        // Update existing item
        final updatedItem = Item(
          id: widget.existingItem!.id,
          spaceId: widget.existingItem!.spaceId,
          name: _nameController.text,
          category: _categoryController.text.isNotEmpty
              ? _categoryController.text
              : null,
          status: widget.existingItem!.status,
          imagePath: savedImageFileName,
          quantity: _trackQuantity ? int.tryParse(_quantityController.text) : null,
          lastUsedAt: widget.existingItem!.lastUsedAt,
        );
        await ref.read(itemRepositoryProvider).updateItem(updatedItem);
      } else {
        // Create new item
        final item = Item(
          id: const Uuid().v4(),
          spaceId: widget.spaceId,
          name: _nameController.text,
          category: _categoryController.text.isNotEmpty
              ? _categoryController.text
              : null,
          status: ItemStatus.stored,
          imagePath: savedImageFileName,
          quantity: _trackQuantity ? int.tryParse(_quantityController.text) : null,
        );
        await ref.read(itemRepositoryProvider).createItem(item);
      }

      if (mounted) {
        ref.invalidate(itemsInSpaceProvider(widget.spaceId));
        context.pop();
      }
    } catch (e) {
      debugPrint('Error saving item: $e');
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
              Text(
                widget.existingItem != null ? 'Edit Item' : 'New Item',
                style: const TextStyle(
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
          const SizedBox(height: 16),
          // Track quantity toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Track quantity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                CupertinoSwitch(
                  value: _trackQuantity,
                  onChanged: (val) => setState(() => _trackQuantity = val),
                ),
              ],
            ),
          ),
          if (_trackQuantity) ...[
            const SizedBox(height: 16),
            // Quantity field with +/- buttons
            Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _quantityController,
                    placeholder: 'Quantity',
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: const EdgeInsets.all(12),
                  onPressed: () {
                    final current = int.tryParse(_quantityController.text) ?? 1;
                    if (current > 1) {
                      _quantityController.text = (current - 1).toString();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      CupertinoIcons.minus,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(12),
                  onPressed: () {
                    final current = int.tryParse(_quantityController.text) ?? 1;
                    _quantityController.text = (current + 1).toString();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      CupertinoIcons.plus,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                : Text(widget.existingItem != null ? 'Update Item' : 'Create Item'),
          ),
        ],
      ),
    );
  }
}
