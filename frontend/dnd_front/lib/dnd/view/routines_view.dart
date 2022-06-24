import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dnd.dart';

class RoutineView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('DnD App - routines')),
      body: Center(child: BlocBuilder<DnDCubit, String>(
        builder: (context, state) {
          return Text(state, style: textTheme.headline2);
        },
      )),
    );
  }
}
