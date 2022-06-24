import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dnd.dart';

class DnDView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('DnD App')),
      body: Center(
        child: TextFormField(
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText:
                'Enter the user id (will be replaced by 0auth2 later...)',
          ),
          onFieldSubmitted: (String value) {
            context.read<DnDCubit>().setUser(value);
          },
        ),
      ),
    );
  }
}
