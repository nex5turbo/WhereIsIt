import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/item.dart';
import '../../data/repositories/item_repository_impl.dart';
import '../../presentation/providers/item_providers.dart';

class CreateItemDialog extends ConsumerStatefulWidget {
  final String spaceId;

  const CreateItemDialog({super.key, required this.spaceId});

  @override
  ConsumerState<CreateItemDialog> createState() => _CreateItemDialogState();
}

class _CreateItemDialogState extends ConsumerState<CreateItemDialog> {
  final _formKey = GlobalKey<FormState>();
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
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final item = Item(
          id: const Uuid().v4(),
          spaceId: widget.spaceId,
          name: _nameController.text,
          category: _categoryController.text.isNotEmpty ? _categoryController.text : null,
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
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category (Optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const CircularProgressIndicator.adaptive() : const Text('Create'),
        ),
      ],
    );
  }
}
