import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:skinner/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

// ── slot model ──────────────────────────────────────────────────────────────
class _Slot {
  String start; // "09:00"
  String end;   // "09:30"
  int    durationMin; // 30
  _Slot({this.start = '09:00', this.end = '09:30', this.durationMin = 30});
}

// ── helpers ──────────────────────────────────────────────────────────────────
List<String> _hours() {
  return List.generate(24 * 2, (i) {
    final h = (i ~/ 2).toString().padLeft(2, '0');
    final m = i.isOdd ? '30' : '00';
    return '$h:$m';
  });
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Profile
  bool   _profileLoading = true;
  String _name = '', _id = '', _email = '', _phone = '', _address = '';
  double _fee  = 0;

  // Calendar
  DateTime _focusedDay  = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Slots for selected day
  List<_Slot> _slots       = [];
  List<dynamic> _serverAvailability = [];
  bool _availabilityLoading = true;

  // Upcoming appointments (from reviewed cases / appointments)
  List<dynamic> _upcoming      = [];
  bool          _upcomingLoading = true;

  // Controllers for edit dialog
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _feeCtrl     = TextEditingController();

  String? _token;
  Future<String> _getToken() async {
    if (_token != null) return _token!;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? adminToken ?? '';
    return _token!;
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchAvailability();
    _fetchUpcoming();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _addressCtrl.dispose(); _feeCtrl.dispose();
    super.dispose();
  }

  // ── network ─────────────────────────────────────────────────────────────────

  Future<void> _fetchProfile() async {
    try {
      final token = await _getToken();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.skinnerai.site'));
      final res = await dio.get('/api/profile/me',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final d = res.data['data'] ?? res.data;
      if (mounted) setState(() {
        _name    = d['name'] ?? '';
        _id      = d['medical_syndicate_id_card'] ?? d['id']?.toString() ?? '';
        _email   = d['email'] ?? '';
        _phone   = d['phone'] ?? '';
        _address = d['clinic_address'] ?? '';
        _fee     = (d['consultation_fee'] as num?)?.toDouble() ?? 0;
        _profileLoading = false;
      });
    } catch (e) {
      debugPrint('Profile fetch failed: $e');
      if (mounted) setState(() => _profileLoading = false);
    }
  }

  Future<void> _fetchAvailability() async {
    try {
      final token = await _getToken();
      final now = DateTime.now();
      final res = await AuthService().getAvailability(
        token: token,
        startDate: '${now.year}-${now.month.toString().padLeft(2,'0')}-01',
        endDate:   '${now.year}-${now.month.toString().padLeft(2,'0')}-30',
      );
      if (mounted) setState(() {
        _serverAvailability = res.data['data'] ?? [];
        _availabilityLoading = false;
        _loadSlotsForDay(_selectedDay);
      });
    } catch (e) {
      debugPrint('Availability fetch failed: $e');
      if (mounted) setState(() => _availabilityLoading = false);
    }
  }

  Future<void> _fetchUpcoming() async {
    try {
      final token = await _getToken();
      final res = await AuthService().getPendingCases(token: token);
      if (mounted) setState(() {
        _upcoming = res.data['data'] ?? [];
        _upcomingLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _upcomingLoading = false);
    }
  }

  Future<void> _saveSlots() async {
    if (_slots.isEmpty) return;
    try {
      final token = await _getToken();
      final dateStr = _selectedDay.toIso8601String().substring(0, 10);
      await AuthService().setAvailability(
        token:     token,
        date:      dateStr,
        startTime: _slots.first.start,
        endTime:   _slots.last.end,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability saved')));
        _fetchAvailability();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')));
    }
  }

  Future<void> _removeDay() async {
    final dateStr = _selectedDay.toIso8601String().substring(0, 10);
    try {
      final token = await _getToken();
      await AuthService().deleteAvailability(token: token, date: dateStr);
      if (mounted) {
        setState(() { _slots = []; });
        _fetchAvailability();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove: $e')));
    }
  }

  Future<void> _updateProfile() async {
    Navigator.pop(context); // close dialog first
    final overlay = OverlayEntry(builder: (_) =>
        const Material(color: Colors.black26,
          child: Center(child: CircularProgressIndicator())));
    Overlay.of(context).insert(overlay);
    try {
      final token = await _getToken();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.skinnerai.site'));
      await dio.put('/api/profile/update',
        data: {
          'name': _nameCtrl.text,
          'phone': _phoneCtrl.text,
          'clinic_address': _addressCtrl.text,
          'consultation_fee': double.tryParse(_feeCtrl.text) ?? _fee,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (mounted) setState(() {
        _name    = _nameCtrl.text;
        _phone   = _phoneCtrl.text;
        _address = _addressCtrl.text;
        _fee     = double.tryParse(_feeCtrl.text) ?? _fee;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')));
    } finally {
      overlay.remove();
    }
  }

  // ── helpers ──────────────────────────────────────────────────────────────────

  void _loadSlotsForDay(DateTime day) {
    final dateStr = day.toIso8601String().substring(0, 10);
    final entry = _serverAvailability.firstWhere(
      (a) => a['available_date']?.toString().startsWith(dateStr) == true,
      orElse: () => null,
    );
    if (entry != null) {
      _slots = [_Slot(
        start: (entry['start_time'] ?? '09:00').toString().substring(0, 5),
        end:   (entry['end_time']   ?? '09:30').toString().substring(0, 5),
      )];
    } else {
      _slots = [];
    }
  }

  bool _dayHasAvailability(DateTime day) {
    final ds = day.toIso8601String().substring(0, 10);
    return _serverAvailability.any(
        (a) => a['available_date']?.toString().startsWith(ds) == true);
  }

  String _formatDayHeader(DateTime d) {
    const days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    const months = ['January','February','March','April','May','June',
                    'July','August','September','October','November','December'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  // ── build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_profileLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _buildDoctorInfoCard(),
          const SizedBox(height: 20),
          _buildScheduleCard(),
          const SizedBox(height: 20),
          _buildUpcomingCard(),
        ],
      ),
    );
  }

  // ── Doctor Information card ─────────────────────────────────────────────────

  Widget _buildDoctorInfoCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Doctor Information',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: _openEditDialog,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                ),
                child: const Text('Edit',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('NAME', _name),
          _infoRow('EMAIL', _email),
          _infoRow('PHONE', _phone.isNotEmpty ? _phone : 'Not provided'),
          _infoRow('CLINIC ADDRESS', _address.isNotEmpty ? _address : 'Not provided'),
          _infoRowFee('CONSULTATION FEE', _fee),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, letterSpacing: 0.8, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
      ],
    ),
  );

  Widget _infoRowFee(String label, double fee) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, letterSpacing: 0.8, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 3),
        Text('\$${fee.toStringAsFixed(0)}',
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB))),
      ],
    ),
  );

  // ── Appointment Schedule card ───────────────────────────────────────────────

  Widget _buildScheduleCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Appointment Schedule',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Calendar
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay  = focused;
                _loadSlotsForDay(selected);
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: false,
              titleTextStyle: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(10),
              ),
              todayDecoration: BoxDecoration(
                color: const Color(0xFFEBF1FF),
                borderRadius: BorderRadius.circular(10),
              ),
              todayTextStyle: const TextStyle(
                  color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
              // Highlight days that already have availability
              markerDecoration: const BoxDecoration(
                color: Color(0xFF93C5FD),
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (ctx, day, events) {
                if (_dayHasAvailability(day)) {
                  return Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF93C5FD),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 10),

          // Legend
          Row(children: [
            _legendDot(const Color(0xFF2563EB)), const SizedBox(width: 4),
            const Text('selected', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            const SizedBox(width: 16),
            _legendDot(const Color(0xFF93C5FD)), const SizedBox(width: 4),
            const Text('has availability',
                style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          ]),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Selected day header + Add Slot button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_formatDayHeader(_selectedDay),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('${_slots.length} time slot${_slots.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() => _slots.add(_Slot())),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Slot',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            ],
          ),

          if (_slots.isNotEmpty) ...[
            const SizedBox(height: 12),

            // Column headers
            const Row(
              children: [
                Expanded(
                    child: Text('START',
                        style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)))),
                Expanded(
                    child: Text('END',
                        style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)))),
                Expanded(
                    child: Text('SLOT',
                        style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)))),
                SizedBox(width: 28),
              ],
            ),

            const SizedBox(height: 8),

            // Slot rows
            for (int i = 0; i < _slots.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildSlotRow(i),
              ),

            const SizedBox(height: 12),

            // Save + Remove Day
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSlots,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Save',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: _removeDay,
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 16, color: Color(0xFFEF4444)),
                  label: const Text('Remove Day',
                      style: TextStyle(
                          color: Color(0xFFEF4444), fontSize: 13)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSlotRow(int i) {
    final hours = _hours();
    const durations = [15, 20, 30, 45, 60];

    return Row(
      children: [
        // Start time
        Expanded(
          child: _timeDropdown(
            value: _slots[i].start,
            items: hours,
            onChanged: (v) => setState(() => _slots[i].start = v!),
          ),
        ),
        const SizedBox(width: 8),
        // End time
        Expanded(
          child: _timeDropdown(
            value: _slots[i].end,
            items: hours,
            onChanged: (v) => setState(() => _slots[i].end = v!),
          ),
        ),
        const SizedBox(width: 8),
        // Duration
        Expanded(
          child: _durationDropdown(
            value: _slots[i].durationMin,
            items: durations,
            onChanged: (v) => setState(() => _slots[i].durationMin = v!),
          ),
        ),
        // Remove
        IconButton(
          icon: const Icon(Icons.close, size: 18, color: Color(0xFFEF4444)),
          onPressed: () => setState(() => _slots.removeAt(i)),
        ),
      ],
    );
  }

  Widget _timeDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButton<String>(
        value: items.contains(value) ? value : items.first,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF6B7280)),
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
        items: items.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _durationDropdown({
    required int value,
    required List<int> items,
    required void Function(int?) onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButton<int>(
        value: items.contains(value) ? value : items.first,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF6B7280)),
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
        items: items
            .map((d) => DropdownMenuItem(value: d, child: Text('$d min')))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  // ── Upcoming Appointments card ──────────────────────────────────────────────

  Widget _buildUpcomingCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upcoming Appointments',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_upcomingLoading)
            const Center(child: CircularProgressIndicator())
          else if (_upcoming.isEmpty)
            const Text('No upcoming appointments',
                style: TextStyle(color: Color(0xFF9CA3AF)))
          else
            ..._upcoming.take(5).map((item) => _appointmentRow(item)),
        ],
      ),
    );
  }

  Widget _appointmentRow(Map item) {
    final String diagnosis = item['skin_disease_classification'] ??
        item['ai_diagnosis'] ?? 'Appointment';
    final String patient = item['patient_name'] ?? 'Patient';
    final String date = (item['created_at'] ?? '').toString().length >= 10
        ? item['created_at'].toString().substring(0, 10)
        : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(diagnosis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(date,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280))),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('SCHEDULED',
                          style: TextStyle(
                              fontSize: 10, color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Text(patient,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF2563EB))),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }

  // ── Edit dialog ─────────────────────────────────────────────────────────────

  void _openEditDialog() {
    _nameCtrl.text    = _name;
    _emailCtrl.text   = _email;
    _phoneCtrl.text   = _phone;
    _addressCtrl.text = _address;
    _feeCtrl.text     = _fee.toStringAsFixed(0);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  const Text('Doctor Information',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF2563EB), size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              _dialogField('Full Name', _nameCtrl, hint: 'Dr John Doe'),
              _dialogField('Email', _emailCtrl, readOnly: true),
              _dialogField('Phone Number', _phoneCtrl, hint: '+1 (555) 000-0000'),
              _dialogField('clinic address', _addressCtrl, hint: 'add'),
              _dialogField('Consultation Fee', _feeCtrl, hint: '150',
                  suffixText: '\$'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Save Change',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController ctrl,
      {bool readOnly = false, String? hint, String? suffixText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
          const SizedBox(height: 5),
          TextField(
            controller: ctrl,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
              suffixText: suffixText,
              suffixStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: readOnly
                  ? const Color(0xFFF1F5F9)
                  : const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            ),
          ),
        ],
      ),
    );
  }

  // ── shared helpers ───────────────────────────────────────────────────────────

  Widget _card({required Widget child}) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: child,
      );

  Widget _legendDot(Color color) => Container(
        width: 12, height: 12,
        decoration: BoxDecoration(color: color,
            borderRadius: BorderRadius.circular(3)),
      );
}
