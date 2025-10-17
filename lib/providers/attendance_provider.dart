import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_model.dart';
import '../services/mock_data_service.dart';

final attendanceProvider = StateNotifierProvider<
  AttendanceNotifier,
  AsyncValue<List<AttendanceModel>>
>((ref) {
  return AttendanceNotifier();
});

class AttendanceNotifier
    extends StateNotifier<AsyncValue<List<AttendanceModel>>> {
  AttendanceNotifier() : super(const AsyncValue.loading()) {
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final attendance = MockDataService.getAttendance();
      state = AsyncValue.data(attendance);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await loadAttendance();
  }
}

// Provider for attendance statistics
final attendanceStatsProvider = Provider<Map<String, int>>((ref) {
  final attendanceState = ref.watch(attendanceProvider);
  return attendanceState.maybeWhen(
    data: (attendance) {
      final present = attendance.where((a) => a.status == 'present').length;
      final absent = attendance.where((a) => a.status == 'absent').length;
      final total = attendance.length;
      return {
        'present': present,
        'absent': absent,
        'total': total,
        'percentage': total > 0 ? ((present / total) * 100).round() : 0,
      };
    },
    orElse: () => {'present': 0, 'absent': 0, 'total': 0, 'percentage': 0},
  );
});
