import 'package:bloc/bloc.dart';

class DnDCubit extends Cubit<String> {
  /// {@macro counter_cubit}
  DnDCubit() : super("");

  void setUser(String user) => emit(user);
}
