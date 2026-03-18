import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../config/colors.dart';
import '../../model/coach/coach_event.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';
import 'CoachCreateEditEventSheet.dart';
import 'event_details_screen.dart';

class ClubEventsListScreen extends StatefulWidget {
  final int clubId;
  final String clubName;

  const ClubEventsListScreen({
    Key? key,
    required this.clubId,
    required this.clubName,
  }) : super(key: key);

  @override
  State<ClubEventsListScreen> createState() => _ClubEventsListScreenState();
}

class _ClubEventsListScreenState extends State<ClubEventsListScreen> {
  final CoachApiService _apiService = CoachApiService();
  late Future<List<CoachEventModel>> _eventsFuture;
  List<CoachEventModel> _allEvents = [];
  List<CoachEventModel> _filteredEvents = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'SCHEDULED', 'ONGOING', 'COMPLETED', 'CANCELLED'];

  @override
  void initState() {
    super.initState();
    _eventsFuture = _fetchEvents();
    _searchController.addListener(_filterEvents);
  }

  Future<List<CoachEventModel>> _fetchEvents() async {
    final events = await _apiService.getClubEvents(widget.clubId);
    _allEvents = events;
    _filterEvents();
    return events;
  }

  void _filterEvents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEvents = _allEvents.where((event) {
        final matchesSearch = query.isEmpty ||
            event.eventName.toLowerCase().contains(query) ||
            event.location.toLowerCase().contains(query);

        final matchesFilter = _selectedFilter == 'All' ||
            event.status == _selectedFilter;

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCreateEvent() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CoachCreateEditEventSheet(
        clubId: widget.clubId,
        clubName: widget.clubName,
        onSuccess: () {
          setState(() {
            _eventsFuture = _fetchEvents();
          });
        },
      ),
    );
  }

  void _navigateToEditEvent(CoachEventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CoachCreateEditEventSheet(
        clubId: widget.clubId,
        clubName: widget.clubName,
        event: event,
        onSuccess: () {
          setState(() {
            _eventsFuture = _fetchEvents();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Club Events",
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: accentGreen),
            onPressed: _navigateToCreateEvent,
          ),
        ],
      ),
      body: Column(
        children: [
          // Club Info Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.clubName,
                  style: GoogleFonts.montserrat(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                4.height,
                Text(
                  "Club ID: #${widget.clubId}",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Search and Filter
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search events...",
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                ),
                12.height,
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                              _filterEvents();
                            });
                          },
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: accentGreen.withOpacity(0.2),
                          checkmarkColor: accentGreen,
                          labelStyle: GoogleFonts.poppins(
                            color: isSelected ? accentGreen : Colors.black87,
                            fontSize: 12.sp,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Events List
          Expanded(
            child: FutureBuilder<List<CoachEventModel>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: accentGreen));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60.sp, color: Colors.red),
                        16.height,
                        Text(
                          "Failed to load events",
                          style: GoogleFonts.poppins(fontSize: 16.sp),
                        ),
                        16.height,
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _eventsFuture = _fetchEvents();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                          ),
                          child: Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredEvents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 60.sp, color: Colors.grey.shade400),
                        16.height,
                        Text(
                          _searchController.text.isEmpty && _selectedFilter == 'All'
                              ? "No events found"
                              : "No matching events",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        16.height,
                        if (_searchController.text.isEmpty && _selectedFilter == 'All')
                          ElevatedButton(
                            onPressed: _navigateToCreateEvent,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentGreen,
                            ),
                            child: Text("Create Event"),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = _filteredEvents[index];
                    return _buildEventCard(event);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(CoachEventModel event) {
    Color statusColor;
    switch (event.status) {
      case 'SCHEDULED':
        statusColor = Colors.blue;
        break;
      case 'ONGOING':
        statusColor = Colors.green;
        break;
      case 'COMPLETED':
        statusColor = Colors.grey;
        break;
      case 'CANCELLED':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12.w),
        leading: Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: accentGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                event.eventDate.day.toString(),
                style: GoogleFonts.montserrat(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: accentGreen,
                ),
              ),
              Text(
                _getMonthName(event.eventDate.month),
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: accentGreen,
                ),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                event.eventName,
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                event.status,
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.location,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
            4.height,
            Row(
              children: [
                Icon(Icons.access_time, size: 12.sp, color: Colors.grey.shade500),
                4.width,
                Text(
                  "${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, size: 18.sp, color: accentGreen),
              onPressed: () => _navigateToEditEvent(event),
            ),
            Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey),
          ],
        ),
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => EventDetailsScreen(
          //       clubId: widget.clubId,
          //       eventId: event.eventId,
          //       clubName: widget.clubName,
          //     ),
          //   ),
          // ).then((updated) {
          //   if (updated == true) {
          //     setState(() {
          //       _eventsFuture = _fetchEvents();
          //     });
          //   }
          // });
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatTime(String time) {
    try {
      if (time.isEmpty) return '';
      final parts = time.split(':');
      if (parts.length < 2) return time;

      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return time.length >= 5 ? time.substring(0, 5) : time;
    }
  }
}