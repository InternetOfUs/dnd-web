import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dnd.dart';
import 'dnd_view.dart';

class DnDPage extends StatelessWidget {
  const DnDPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DnDCubit(),
      child: DnDView(),
    );
  }
}
