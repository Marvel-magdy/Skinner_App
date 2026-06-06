import 'package:flutter/material.dart';
import 'package:skinner/services/auth_service.dart';

class DoctorsScreen extends StatefulWidget {
  final Function(Map doctor) onBookAppointment;
  final Function(Map doctor) onViewMap;

  const DoctorsScreen({
    super.key,
    required this.onBookAppointment,
    required this.onViewMap,
  });

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  List<dynamic> _doctors = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      if (adminToken == null || adminToken!.isEmpty) {
        throw Exception("You must be logged in to fetch specialists.");
      }
      final response = await AuthService().getDoctors(token: adminToken!);
      final data = response.data["data"];
      setState(() {
        _doctors = (data is List) ? data : [];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching doctors: $e");
      setState(() {
        _errorMessage = e is Exception
            ? e.toString().replaceAll("Exception: ", "")
            : "Failed to load doctors. Please check your network connection.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Recommended Specialists",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Based on your diagnosis, we recommend these verified dermatology specialists',
                style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
              ),
              const SizedBox(height: 20),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return _buildSkeletonList();
    if (_errorMessage != null) return _buildErrorState();
    if (_doctors.isEmpty) return _buildEmptyState();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _doctors.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) =>
          _DoctorCard(
            doctor: _doctors[index] as Map,
            onBookAppointment: widget.onBookAppointment,
            onViewMap: widget.onViewMap,
          ),
    );
  }

  // ── Skeleton ──────────────────────────────────────────────
  Widget _buildSkeletonList() => Column(
        children: List.generate(2, (_) => _buildSkeletonCard()),
      );

  Widget _buildSkeletonCard() {
    final base = Colors.grey.shade300;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 28, backgroundColor: Color(0xFFBBBBBB)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 14, color: const Color(0xFFBBBBBB)),
                    const SizedBox(height: 8),
                    Container(width: 80, height: 12, color: const Color(0xFFBBBBBB)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(width: double.infinity, height: 11, color: const Color(0xFFBBBBBB)),
          const SizedBox(height: 6),
          Container(width: 160, height: 11, color: const Color(0xFFBBBBBB)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFBBBBBB),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty ─────────────────────────────────────────────────
  Widget _buildEmptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              const Icon(Icons.person_search_rounded,
                  size: 64, color: Color(0xFF94A3B8)),
              const SizedBox(height: 16),
              const Text(
                "No recommended doctors found.",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              Text(
                "We couldn't find any specialists at the moment.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );

  // ── Error ─────────────────────────────────────────────────
  Widget _buildErrorState() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
          child: Column(
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 64, color: Color(0xFFEF4444)),
              const SizedBox(height: 16),
              const Text(
                "Failed to Load Specialists",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage ??
                    "An unexpected error occurred while querying our system.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchDoctors,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
}

// ── Doctor Card ────────────────────────────────────────────────────────────────
class _DoctorCard extends StatelessWidget {
  final Map doctor;
  final Function(Map) onBookAppointment;
  final Function(Map) onViewMap;

  const _DoctorCard({
    required this.doctor,
    required this.onBookAppointment,
    required this.onViewMap,
  });

  String get _name => (doctor["name"] ?? "Specialist Doctor").toString();
  String get _specialization =>
      (doctor["specialization"] ?? "Dermatology").toString();
  String get _address =>
      (doctor["clinic_address"] ?? "Address unavailable").toString();
  int get _experience => (doctor["year_of_experience"] ?? 0) as int;
  String get _fee =>
      doctor["consultation_fee"] != null
          ? doctor["consultation_fee"].toString()
          : "150";

  // Two-letter initials avatar, matching the light-blue circle in the design
  String get _initials => _name
      .split(" ")
      .take(2)
      .map((w) => w.isNotEmpty ? w[0] : "")
      .join()
      .toUpperCase();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = theme.textTheme.bodyLarge?.color ?? const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Avatar | Name + Verified + Specialty ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFDDEAFE),
                child: Text(
                  _initials.isNotEmpty ? _initials : "DR",
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: const Color(0xFF86EFAC), width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: Color(0xFF16A34A), size: 11),
                              SizedBox(width: 3),
                              Text("Verified",
                                  style: TextStyle(
                                    color: Color(0xFF15803D),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(_specialization, style: TextStyle(color: textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text("4.9",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary)),
              const SizedBox(width: 4),
              Text("(324 reviews)", style: TextStyle(fontSize: 12, color: textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.work_outline_rounded, size: 15, color: textSecondary),
              const SizedBox(width: 6),
              Text("$_experience years experience",
                  style: TextStyle(fontSize: 13, color: textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => onViewMap(doctor),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, size: 15, color: textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(_address,
                      style: TextStyle(fontSize: 13, color: textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 15, color: textSecondary),
              const SizedBox(width: 6),
              Text("Available today", style: TextStyle(fontSize: 13, color: textSecondary)),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: const [
              _Chip(text: "MD"),
              _Chip(text: "Harvard Medical School"),
              _Chip(text: "English"),
              _Chip(text: "Spanish"),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: Column(
              children: [
                Text("Consultation Fee",
                    style: TextStyle(fontSize: 12, color: textSecondary)),
                const SizedBox(height: 2),
                Text("\$$_fee",
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => onBookAppointment(doctor),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF2C67FF) : const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.calendar_today_rounded, size: 16),
              label: const Text("Book Appointment",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small chip helper ──────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
        ),
      ),
    );
  }
}
