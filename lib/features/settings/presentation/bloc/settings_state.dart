part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  @override
  List<Object> get props => [];
}

class SettingsLoadingState extends SettingsState {
  @override
  List<Object?> get props => [];
}

class SettingsLoadedState extends SettingsState {
  final String versionNumber;
  final bool sendAnonymousData;
  final AppThemeEntity appTheme;
  final bool usesImperialUnits;
  final bool showActivityTracking;
  final bool notificationsEnabled;
  final int notificationHour;
  final int notificationMinute;

  const SettingsLoadedState(
    this.versionNumber,
    this.sendAnonymousData,
    this.appTheme,
    this.usesImperialUnits, {
    this.showActivityTracking = true,
    this.notificationsEnabled = false,
    this.notificationHour = 8,
    this.notificationMinute = 0,
  });

  @override
  List<Object?> get props => [
        versionNumber,
        sendAnonymousData,
        appTheme,
        usesImperialUnits,
        showActivityTracking,
        notificationsEnabled,
        notificationHour,
        notificationMinute,
      ];
}
