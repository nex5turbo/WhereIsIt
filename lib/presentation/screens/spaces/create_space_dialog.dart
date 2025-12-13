import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/space_repository_impl.dart';
import '../../providers/space_providers.dart';

class CreateSpaceDialog extends ConsumerStatefulWidget {
  final String? parentId;

  const CreateSpaceDialog({super.key, this.parentId});

  @override
  ConsumerState<CreateSpaceDialog> createState() => _CreateSpaceDialogState();
}

class _CreateSpaceDialogState extends ConsumerState<CreateSpaceDialog> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref
          .read(spaceRepositoryProvider)
          .createSpace(name: _nameController.text, parentId: widget.parentId);
      if (mounted) {
        // Invalidate the provider to refresh the list
        ref.invalidate(spacesProvider(parentId: widget.parentId));
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
      title: const Text('Add New Space'),
      content: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: CupertinoTextField(
          controller: _nameController,
          placeholder: 'Space Name',
          autofocus: true,
          onSubmitted: (_) => _submit(),
        ),
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
