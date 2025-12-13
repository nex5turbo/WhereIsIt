import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/item.dart';
import '../../../data/repositories/item_repository_impl.dart';
import '../../providers/item_providers.dart';

class CreateItemDialog extends ConsumerStatefulWidget {
  final String spaceId;

  const CreateItemDialog({super.key, required this.spaceId});

  @override
  ConsumerState<CreateItemDialog> createState() => _CreateItemDialogState();
}

class _CreateItemDialogState extends ConsumerState<CreateItemDialog> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final item = Item(
        id: const Uuid().v4(),
        spaceId: widget.spaceId,
        name: _nameController.text,
        category: _categoryController.text.isNotEmpty
            ? _categoryController.text
            : null,
        status: ItemStatus.stored,
      );

      await ref.read(itemRepositoryProvider).createItem(item);

      if (mounted) {
        ref.invalidate(itemsInSpaceProvider(widget.spaceId));
        context.pop();
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Add New Item'),
      content: Column(
        children: [
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: _nameController,
            placeholder: 'Item Name',
            autofocus: true,
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: _categoryController,
            placeholder: 'Category (Optional)',
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          onPressed: _isLoading ? null : _submit,
          isDefaultAction: true,
          child: _isLoading
              ? const CupertinoActivityIndicator()
              : const Text('Create'),
        ),
      ],
    );
  }
}
