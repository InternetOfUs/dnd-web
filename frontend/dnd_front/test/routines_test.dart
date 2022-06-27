import 'package:dnd_front/models/routines.dart';
import 'package:test/test.dart';

void main() {
  test('1 is Monday', () {
    final routine = Routine(1, "", "", "");
    final day = routine.toWeekday();

    expect(day, Weekday.monday);
  });
}
