import 'package:flutter/material.dart';
import '../utils/validators.dart';

class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({super.key});

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_textController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Note'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _textController,
          maxLines: 5,
          autofocus: true,
          validator: Validators.validateNoteText,
          decoration: const InputDecoration(
            hintText: 'Enter your note here...',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}