import 'package:supabase_flutter/supabase_flutter.dart';
import 'garbage_schedule_service.dart';

class AdminGarbageScheduleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Check if current user is admin
  Future<bool> isAdmin() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .single();

      return response['role'] == 'admin';
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Create a new pickup schedule (Admin only)
  Future<bool> createPickupSchedule({
    required String areaId,
    required DateTime pickupDate,
    required String pickupTimeStart,
    required String pickupTimeEnd,
    required String wasteType,
    String status = 'scheduled',
    bool isRecurring = false,
    String recurrenceType = 'weekly',
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null || !await isAdmin()) {
        throw Exception('Unauthorized: Admin access required');
      }

      final dateString =
          '${pickupDate.year}-${pickupDate.month.toString().padLeft(2, '0')}-${pickupDate.day.toString().padLeft(2, '0')}';

      await _supabase.from('garbage_pickup_schedule').insert({
        'area_id': areaId,
        'pickup_date': dateString,
        'pickup_time_start': pickupTimeStart,
        'pickup_time_end': pickupTimeEnd,
        'waste_type': wasteType,
        'status': status,
        'is_recurring': isRecurring,
        'recurrence_type': recurrenceType,
        'created_by': userId,
      });

      return true;
    } catch (e) {
      print('Error creating pickup schedule: $e');
      return false;
    }
  }

  // Update pickup schedule (Admin only)
  Future<bool> updatePickupSchedule({
    required String scheduleId,
    String? areaId,
    DateTime? pickupDate,
    String? pickupTimeStart,
    String? pickupTimeEnd,
    String? wasteType,
    String? status,
    bool? isRecurring,
    String? recurrenceType,
  }) async {
    try {
      if (!await isAdmin()) {
        throw Exception('Unauthorized: Admin access required');
      }

      final Map<String, dynamic> updates = {};

      if (areaId != null) updates['area_id'] = areaId;
      if (pickupDate != null) {
        updates['pickup_date'] =
            '${pickupDate.year}-${pickupDate.month.toString().padLeft(2, '0')}-${pickupDate.day.toString().padLeft(2, '0')}';
      }
      if (pickupTimeStart != null)
        updates['pickup_time_start'] = pickupTimeStart;
      if (pickupTimeEnd != null) updates['pickup_time_end'] = pickupTimeEnd;
      if (wasteType != null) updates['waste_type'] = wasteType;
      if (status != null) updates['status'] = status;
      if (isRecurring != null) updates['is_recurring'] = isRecurring;
      if (recurrenceType != null) updates['recurrence_type'] = recurrenceType;

      if (updates.isEmpty) return true;

      await _supabase
          .from('garbage_pickup_schedule')
          .update(updates)
          .eq('id', scheduleId);

      return true;
    } catch (e) {
      print('Error updating pickup schedule: $e');
      return false;
    }
  }

  // Delete pickup schedule (Admin only)
  Future<bool> deletePickupSchedule(String scheduleId) async {
    try {
      if (!await isAdmin()) {
        throw Exception('Unauthorized: Admin access required');
      }

      await _supabase
          .from('garbage_pickup_schedule')
          .delete()
          .eq('id', scheduleId);

      return true;
    } catch (e) {
      print('Error deleting pickup schedule: $e');
      return false;
    }
  }

  // Get all schedules for an area (Admin only)
  Future<List<GarbagePickup>> getAreaSchedules(String areaId) async {
    try {
      if (!await isAdmin()) {
        throw Exception('Unauthorized: Admin access required');
      }

      final response = await _supabase
          .from('garbage_pickup_schedule')
          .select()
          .eq('area_id', areaId)
          .order('pickup_date', ascending: true);

      return (response as List)
          .map((data) => GarbagePickup.fromJson(data))
          .toList();
    } catch (e) {
      print('Error getting area schedules: $e');
      return [];
    }
  }

  // Get all schedules (Admin only)
  Future<List<GarbagePickup>> getAllSchedules({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? areaId,
  }) async {
    try {
      if (!await isAdmin()) {
        throw Exception('Unauthorized: Admin access required');
      }

      var query = _supabase.from('garbage_pickup_schedule').select();

      if (startDate != null) {
        final startDateString =
            '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
        query = query.gte('pickup_date', startDateString);
      }

      if (endDate != null) {
        final endDateString =
            '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
        query = query.lte('pickup_date', endDateString);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      if (areaId != null) {
        query = query.eq('area_id', areaId);
      }

      final response = await query.order('pickup_date', ascending: true);

      return (response as List)
          .map((data) => GarbagePickup.fromJson(data))
          .toList();
    } catch (e) {
      print('Error getting all schedules: $e');
      return [];
    }
  }

  // Create area template (Admin only)
  Future<bool> createAreaTemplate({
    required String areaId,
    required int dayOfWeek, // 1=Monday, 7=Sunday
    required String pickupTimeStart,
    required String pickupTimeEnd,
    required String wasteType,
  }) async {
    try {
      if (!await isAdmin()) {
        throw Exception('Unauthorized: Admin access required');
      }

      await _supabase.from('area_schedule_templates').insert({
        'area_id': areaId,
        'day_of_week': dayOfWeek,
        'pickup_time_start': pickupTimeStart,
        'pickup_time_end': pickupTimeEnd,
        'waste_type': wasteType,
        'is_active': true,
      });

      return true;
    } catch (e) {
      print('Error creating area template: $e');
      return false;
    }
  }

  // Generate schedules from templates (Admin only)
  Future<bool> generateSchedulesFromTemplates() async {
    try {
      if (!await isAdmin()) {
        throw Exception('Unauthorized: Admin access required');
      }

      await _supabase.rpc('generate_schedules_from_templates');
      return true;
    } catch (e) {
      print('Error generating schedules from templates: $e');
      return false;
    }
  }

  // Bulk update schedule status (Admin only)
  Future<bool> bulkUpdateStatus({
    required List<String> scheduleIds,
    required String newStatus,
  }) async {
    try {
      if (!await isAdmin()) {
        throw Exception('Unauthorized: Admin access required');
      }

      await _supabase
          .from('garbage_pickup_schedule')
          .update({'status': newStatus}).inFilter('id', scheduleIds);

      return true;
    } catch (e) {
      print('Error bulk updating status: $e');
      return false;
    }
  }
}
