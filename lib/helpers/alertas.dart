import 'package:flutter/material.dart';

mostrarLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AlertDialog(
      title: Text('Espere'),
      content: LinearProgressIndicator(),
    )
  );
}

mostrarAlerta(BuildContext context, String titulo, String mensaje) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        MaterialButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Ok'),
        )
      ],
    )
  );
}