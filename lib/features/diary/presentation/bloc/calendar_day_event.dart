part of 'calendar_day_bloc.dart';

abstract class CalendarDayEvent extends Equatable {
  const CalendarDayEvent();
}

class LoadCalendarDayEvent extends CalendarDayEvent {
  final DateTime day;

  const LoadCalendarDayEvent(this.day);

  @override
  List<Object?> get props => [];
}

class RefreshCalendarDayEvent extends CalendarDayEvent {
  final DateTime? dayToRefresh;

  const RefreshCalendarDayEvent({this.dayToRefresh});

  @override
  List<Object?> get props => [dayToRefresh];
}
