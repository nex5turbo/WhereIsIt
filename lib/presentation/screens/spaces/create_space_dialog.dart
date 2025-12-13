import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/space_repository_impl.dart';
import '../../presentation/providers/space_providers.dart';

class CreateSpaceDialog extends ConsumerStatefulWidget {
  final String? parentId;

  const CreateSpaceDialog({super.key, this.parentId});

  @override
  ConsumerState<CreateSpaceDialog> createState() => _CreateSpaceDialogState();
}

class _CreateSpaceDialogState extends ConsumerState<CreateSpaceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref.read(spaceRepositoryProvider).createSpace(
          name: _nameController.text,
          parentId: widget.parentId,
        );
        if (mounted) {
           // Invalidate the provider to refresh the list
           ref.invalidate(spacesProvider(parentId: widget.parentId));
           context.pop();
        }
      } catch (e) {
        if (mounted) { // Handle error }
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Space'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Space Name'),
          validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
          autofocus: true,
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
