import 'package:dnd_front/models/routines.dart';
import 'package:test/test.dart';

void main() {
  test('1 is Monday', () {
    final routine = Routine(1, "", "", "");
    final day = routine.toWeekday();

    expect(day, Weekday.monday);
  });
  test('2 is Tuesday', () {
    final routine = Routine(2, "", "", "");
    final day = routine.toWeekday();

    expect(day, Weekday.tuesday);
  });
  test('3 is Wednesday', () {
    final routine = Routine(3, "", "", "");
    final day = routine.toWeekday();

    expect(day, Weekday.wednesday);
  });
  test('4 is Thursday', () {
    final routine = Routine(4, "", "", "");
    final day = routine.toWeekday();

    expect(day, Weekday.thursday);
  });
  test('5 is Friday', () {
    final routine = Routine(5, "", "", "");
    final day = routine.toWeekday();

    expect(day, Weekday.friday);
  });
  test('6 is Saturday', () {
    final routine = Routine(6, "", "", "");
    final day = routine.toWeekday();

    expect(day, Weekday.saturday);
  });
  test('7 is Sunday', () {
    final routine = Routine(7, "", "", "");
    final day = routine.toWeekday();

    expect(day, Weekday.sunday);
  });
}
