import 'package:flutter/material.dart';

void showAuthPlaceholder(BuildContext context, String label) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$label — placeholder')),
  );
}
