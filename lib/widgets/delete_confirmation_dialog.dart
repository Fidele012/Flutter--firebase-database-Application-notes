import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String noteText;

  const DeleteConfirmationDialog({super.key, required this.noteText});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Note'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Are you sure you want to delete this note?'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              noteText.length > 100
                  ? '${noteText.substring(0, 100)}...'
                  : noteText,
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}