import 'package:supabase_flutter/supabase_flutter.dart';

class GarbageScheduleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get today's pickup schedule for the user (READ-ONLY)
  Future<GarbagePickup?> getTodaysPickup() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Get user's location information
      final userResponse = await _supabase
          .from('users')
          .select('province_id, district_id, local_authority_id')
          .eq('id', userId)
          .maybeSingle();

      if (userResponse == null) return null;

      final provinceId = userResponse['province_id'];
      final districtId = userResponse['district_id'];
      final localAuthorityId = userResponse['local_authority_id'];

      if (provinceId == null ||
          districtId == null ||
          localAuthorityId == null) {
        return null; // User hasn't set their location
      }

      // Get today's pickup schedule for the user's location
      final response = await _supabase
          .from('garbage_pickup_schedule')
          .select()
          .eq('province_id', provinceId)
          .eq('district_id', districtId)
          .eq('local_authority_id', localAuthorityId)
          .eq('pickup_date', todayString)
          .eq('status', 'scheduled')
          .maybeSingle();

      if (response == null) return null;

      return GarbagePickup.fromJson(response);
    } catch (e) {
      print('Error getting today\'s pickup: $e');
      return null;
    }
  }

  // Get next pickup schedule for the user (READ-ONLY)
  Future<GarbagePickup?> getNextPickup() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Get user's location information
      final userResponse = await _supabase
          .from('users')
          .select('province_id, district_id, local_authority_id')
          .eq('id', userId)
          .maybeSingle();

      if (userResponse == null) return null;

      final provinceId = userResponse['province_id'];
      final districtId = userResponse['district_id'];
      final localAuthorityId = userResponse['local_authority_id'];

      if (provinceId == null ||
          districtId == null ||
          localAuthorityId == null) {
        return null; // User hasn't set their location
      }

      // Get next pickup schedule for the user's location
      final response = await _supabase
          .from('garbage_pickup_schedule')
          .select()
          .eq('province_id', provinceId)
          .eq('district_id', districtId)
          .eq('local_authority_id', localAuthorityId)
          .gt('pickup_date', todayString)
          .eq('status', 'scheduled')
          .order('pickup_date', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return GarbagePickup.fromJson(response);
    } catch (e) {
      print('Error getting next pickup: $e');
      return null;
    }
  }

  // Get pickup schedule for a specific month (READ-ONLY)
  Future<List<GarbagePickup>> getMonthlySchedule(DateTime month) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      // Get user's location information
      final userResponse = await _supabase
          .from('users')
          .select('province_id, district_id, local_authority_id')
          .eq('id', userId)
          .maybeSingle();

      if (userResponse == null) return [];

      final provinceId = userResponse['province_id'];
      final districtId = userResponse['district_id'];
      final localAuthorityId = userResponse['local_authority_id'];

      if (provinceId == null ||
          districtId == null ||
          localAuthorityId == null) {
        return []; // User hasn't set their location
      }

      // Get first and last day of month
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      final firstDayString =
          '${firstDay.year}-${firstDay.month.toString().padLeft(2, '0')}-${firstDay.day.toString().padLeft(2, '0')}';
      final lastDayString =
          '${lastDay.year}-${lastDay.month.toString().padLeft(2, '0')}-${lastDay.day.toString().padLeft(2, '0')}';

      final response = await _supabase
          .from('garbage_pickup_schedule')
          .select()
          .eq('province_id', provinceId)
          .eq('district_id', districtId)
          .eq('local_authority_id', localAuthorityId)
          .gte('pickup_date', firstDayString)
          .lte('pickup_date', lastDayString)
          .order('pickup_date', ascending: true);

      return (response as List)
          .map((data) => GarbagePickup.fromJson(data))
          .toList();
    } catch (e) {
      print('Error getting monthly schedule: $e');
      return [];
    }
  }

  // Check if user has set their location
  Future<bool> hasUserSetLocation() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('users')
          .select('province_id, district_id, local_authority_id')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return false;

      final provinceId = response['province_id'];
      final districtId = response['district_id'];
      final localAuthorityId = response['local_authority_id'];

      return provinceId != null &&
          districtId != null &&
          localAuthorityId != null;
    } catch (e) {
      print('Error checking user location: $e');
      return false;
    }
  }

  // Get user's location details
  Future<Map<String, dynamic>?> getUserLocation() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('users')
          .select('province_id, district_id, local_authority_id')
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error getting user location: $e');
      return null;
    }
  }
}

class GarbagePickup {
  final String id;
  final int provinceId;
  final int districtId;
  final int localAuthorityId;
  final DateTime pickupDate;
  final String pickupTimeStart;
  final String pickupTimeEnd;
  final String wasteType;
  final String status;
  final bool isRecurring;
  final String recurrenceType;
  final String? createdBy; // Admin who created this schedule
  final String? notes;

  GarbagePickup({
    required this.id,
    required this.provinceId,
    required this.districtId,
    required this.localAuthorityId,
    required this.pickupDate,
    required this.pickupTimeStart,
    required this.pickupTimeEnd,
    required this.wasteType,
    required this.status,
    required this.isRecurring,
    required this.recurrenceType,
    this.createdBy,
    this.notes,
  });

  factory GarbagePickup.fromJson(Map<String, dynamic> json) {
    return GarbagePickup(
      id: json['id'] as String,
      provinceId: json['province_id'] as int,
      districtId: json['district_id'] as int,
      localAuthorityId: json['local_authority_id'] as int,
      pickupDate: DateTime.parse(json['pickup_date'] as String),
      pickupTimeStart: json['pickup_time_start'] as String,
      pickupTimeEnd: json['pickup_time_end'] as String,
      wasteType: json['waste_type'] as String,
      status: json['status'] as String,
      isRecurring: json['is_recurring'] as bool,
      recurrenceType: json['recurrence_type'] as String,
      createdBy: json['created_by'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'province_id': provinceId,
      'district_id': districtId,
      'local_authority_id': localAuthorityId,
      'pickup_date':
          '${pickupDate.year}-${pickupDate.month.toString().padLeft(2, '0')}-${pickupDate.day.toString().padLeft(2, '0')}',
      'pickup_time_start': pickupTimeStart,
      'pickup_time_end': pickupTimeEnd,
      'waste_type': wasteType,
      'status': status,
      'is_recurring': isRecurring,
      'recurrence_type': recurrenceType,
      'created_by': createdBy,
      'notes': notes,
    };
  }

  String get formattedTimeRange {
    return '$pickupTimeStart - $pickupTimeEnd';
  }

  String get formattedTime12Hour {
    final startTime = _parseTime(pickupTimeStart);
    final endTime = _parseTime(pickupTimeEnd);
    return '${_formatTime12Hour(startTime)} - ${_formatTime12Hour(endTime)}';
  }

  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(2000, 1, 1, hour, minute);
  }

  String _formatTime12Hour(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }

  bool get isToday {
    final now = DateTime.now();
    return pickupDate.year == now.year &&
        pickupDate.month == now.month &&
        pickupDate.day == now.day;
  }
}
