// screens/coach/coach_groups.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/app_theme.dart';
import '../../config/colors.dart';
import 'coach_attendance_screen.dart';

class CoachGroupsScreen extends StatefulWidget {
  const CoachGroupsScreen({super.key});

  @override
  State<CoachGroupsScreen> createState() => _CoachGroupsScreenState();
}

class _CoachGroupsScreenState extends State<CoachGroupsScreen> {
  late Future<List<Group>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _fetchGroups();
  }

  Future<List<Group>> _fetchGroups() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      Group(
        id: "g1",
        name: "Under-14 A",
        activity: "Football",
        memberCount: 18,
        attendanceRate: 94,
      ),
      Group(
        id: "g2",
        name: "Under-12 B",
        activity: "Football",
        memberCount: 15,
        attendanceRate: 88,
      ),
      Group(
        id: "g3",
        name: "Intermediate Squad",
        activity: "Swimming",
        memberCount: 12,
        attendanceRate: 92,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            Container(
              height: 80.h,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.08),
                    width: 0.5,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    // Icon(
                    //   Icons.menu_outlined,
                    //   color: Colors.white,
                    //   size: 20.sp,
                    // ),
                    // 10.width,
                    Text(
                      "My groups",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: cardDark,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    //const Spacer(),

                    //20.width,

                    // Child switcher
                    // GestureDetector(
                    //   onTap: () => toast("Switch child"),
                    //   child: CircleAvatar(
                    //     radius: 20.r,
                    //     backgroundColor: accentGreen.withOpacity(0.3),
                    //     child: Icon(
                    //       Icons.swap_horiz_rounded,
                    //       color: accentGreen,
                    //       size: 24.sp,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Group>>(
                future: _groupsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final groups = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _groupsFuture = _fetchGroups();
                      });
                    },
                    color: accentGreen,
                    child: ListView.builder(
                      padding: EdgeInsets.all(20.w),
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        return _GroupCard(group: groups[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final Group group;

  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: accentGreen.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    4.height,
                    Text(
                      group.activity,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: accentGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  "${group.memberCount} members",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          16.height,
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: "Attendance",
                  value: "${group.attendanceRate}%",
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: "Members",
                  value: "${group.memberCount}",
                  icon: Icons.people_outline_rounded,
                ),
              ),
            ],
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                label: "View Members",
                icon: Icons.list_rounded,
                onTap: () => toast("View members of ${group.name}"),
              ),
              _ActionButton(
                label: "Attendance",
                icon: Icons.assignment_turned_in_rounded,
                onTap: () {} /*Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoachAttendanceScreen(
                      groupName: group.name,
                      eventName: group.activity,
                      groupId: group.id,
                    ),
                  ),*/,
              ),

              _ActionButton(
                label: "Feedback",
                icon: Icons.rate_review_rounded,
                onTap: () => toast("Add feedback for ${group.name}"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: accentGreen),
        8.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 10.sp, color: textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: accentGreen, size: 20.sp),
          ),
          4.height,
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 9.sp, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class Group {
  final String id;
  final String name;
  final String activity;
  final int memberCount;
  final int attendanceRate;

  Group({
    required this.id,
    required this.name,
    required this.activity,
    required this.memberCount,
    required this.attendanceRate,
  });
}

// screens/coach/coach_events.dart
// class CoachEventsScreen extends StatefulWidget {
//   const CoachEventsScreen({super.key});
//
//   @override
//   State<CoachEventsScreen> createState() => _CoachEventsScreenState();
// }
//
// class _CoachEventsScreenState extends State<CoachEventsScreen> {
//   late Future<List<CoachEventDetail>> _eventsFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _eventsFuture = _fetchEvents();
//   }
//
//   Future<List<CoachEventDetail>> _fetchEvents() async {
//     await Future.delayed(const Duration(milliseconds: 700));
//     return [
//       CoachEventDetail(
//         id: "e1",
//         title: "Weekend Training Session",
//         type: "Training",
//         dateTime: DateTime.now().add(const Duration(days: 2)),
//         location: "Main Ground",
//         groupName: "Under-14 A",
//         attendanceStatus: "Pending",
//       ),
//       CoachEventDetail(
//         id: "e2",
//         title: "Inter-Club Tournament",
//         type: "Match",
//         dateTime: DateTime.now().add(const Duration(days: 5)),
//         location: "City Stadium",
//         groupName: "Under-14 A",
//         attendanceStatus: "Not Started",
//       ),
//       CoachEventDetail(
//         id: "e3",
//         title: "Swimming Practice",
//         type: "Training",
//         dateTime: DateTime.now().add(const Duration(days: 1)),
//         location: "Pool B",
//         groupName: "Intermediate Squad",
//         attendanceStatus: "Completed",
//       ),
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(
//         statusBarColor: Colors.white,
//         statusBarIconBrightness: Brightness.light,
//         statusBarBrightness: Brightness.dark,
//       ),
//       child: Scaffold(
//         backgroundColor: scaffoldDark,
//         floatingActionButton: FloatingActionButton.extended(
//           onPressed: () {
//             toast("Create new event");
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const CreateEventScreen(),
//               ),
//             );
//           } ,
//           backgroundColor: accentGreen,
//           icon: const Icon(Icons.add, color: Colors.white),
//           label: Text(
//             "Create Event",
//             style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
//           ),
//         ),
//         body: Column(
//           children: [
//             // Container(
//             //   height: 80.h,
//             //   width: double.infinity,
//             //   padding: EdgeInsets.symmetric(horizontal: 20.w),
//             //   decoration: BoxDecoration(
//             //     color: Colors.black.withOpacity(0.9),
//             //     border: Border(
//             //       bottom: BorderSide(
//             //         color: Colors.white.withOpacity(0.08),
//             //         width: 0.5,
//             //       ),
//             //     ),
//             //   ),
//             //   child: Padding(
//             //     padding: EdgeInsets.only(top: 20),
//             //     child: Row(
//             //       children: [
//             //         // Icon(
//             //         //   Icons.menu_outlined,
//             //         //   color: Colors.white,
//             //         //   size: 20.sp,
//             //         // ),
//             //         // 10.width,
//             //
//             //         Text("Events",style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: cardDark,fontSize: 20.sp,fontWeight: FontWeight.bold,),),
//             //         const Spacer(),
//             //
//             //
//             //         //20.width,
//             //
//             //         // Child switcher
//             //         // GestureDetector(
//             //         //   onTap: () => toast("Switch child"),
//             //         //   child: CircleAvatar(
//             //         //     radius: 20.r,
//             //         //     backgroundColor: accentGreen.withOpacity(0.3),
//             //         //     child: Icon(
//             //         //       Icons.swap_horiz_rounded,
//             //         //       color: accentGreen,
//             //         //       size: 24.sp,
//             //         //     ),
//             //         //   ),
//             //         // ),
//             //       ],
//             //     ),
//             //   ),
//             // ),
//             Container(
//               height: 85.h,                      // slightly taller → better proportions
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(16),
//                   bottomRight: Radius.circular(16),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.25),
//                     blurRadius: 10,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: SafeArea(
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                     top: 5.h,
//                     left: 20.w,
//                     right: 20.w,
//                   ),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Events",
//                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                           color: Colors.white,
//                           fontSize: 20.sp,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       //const Spacer(),
//
//                       // GestureDetector(
//                       //   onTap: () {
//                       //     //Navigator.pushNamed(context, AppRoutes.guardianNotifications);
//                       //   },
//                       //   child: Stack(
//                       //     children: [
//                       //       Icon(
//                       //         Icons.notifications_none_rounded,
//                       //         color: Colors.white,
//                       //         size: 26.sp,
//                       //       ),
//                       //       Positioned(
//                       //         right: 0,
//                       //         top: 0,
//                       //         child: Container(
//                       //           width: 10.r,
//                       //           height: 10.r,
//                       //           decoration: BoxDecoration(
//                       //             color: accentOrange,
//                       //             shape: BoxShape.circle,
//                       //             border: Border.all(
//                       //               color: Colors.black,
//                       //               width: 1.5,
//                       //             ),
//                       //           ),
//                       //         ),
//                       //       ),
//                       //     ],
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: FutureBuilder<List<CoachEventDetail>>(
//                 future: _eventsFuture,
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   final events = snapshot.data!;
//                   return RefreshIndicator(
//                     onRefresh: () async {
//                       setState(() {
//                         _eventsFuture = _fetchEvents();
//                       });
//                     },
//                     color: accentGreen,
//                     child: ListView.builder(
//                       padding: EdgeInsets.all(20.w),
//                       itemCount: events.length,
//                       itemBuilder: (context, index) {
//                         return _EventCard(event: events[index]);
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _EventCard extends StatelessWidget {
  final CoachEventDetail event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (event.attendanceStatus) {
      case "Completed":
        statusColor = accentGreen;
        break;
      case "Pending":
        statusColor = accentOrange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: GoogleFonts.montserrat(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  event.type,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          8.height,
          Text(
            event.groupName,
            style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
          ),
          8.height,
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14.sp,
                color: textSecondary,
              ),
              6.width,
              Text(
                "In ${event.dateTime.difference(DateTime.now()).inDays} days",
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          4.height,
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 14.sp,
                color: textSecondary,
              ),
              6.width,
              Text(
                event.location,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          12.height,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => toast("View event details"),
                  style: OutlinedButton.styleFrom(
                    //backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.deepOrangeAccent, width: 1),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    "View Details",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              if (event.attendanceStatus != "Completed") ...[
                12.width,
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => toast("Take attendance"),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: accentGreen, width: 1),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Attendance",
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: accentGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class CoachEventDetail {
  final String id;
  final String title;
  final String type;
  final DateTime dateTime;
  final String location;
  final String groupName;
  final String attendanceStatus;

  CoachEventDetail({
    required this.id,
    required this.title,
    required this.type,
    required this.dateTime,
    required this.location,
    required this.groupName,
    required this.attendanceStatus,
  });
}

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Training';
  String _selectedGroup = 'Under-14 A';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 16, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Event')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Event Title',
                hintText: 'Enter event title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter event title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Event Type',
                prefixIcon: Icon(Icons.category),
              ),
              items: ['Training', 'Match', 'Tournament'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGroup,
              decoration: const InputDecoration(
                labelText: 'Group',
                prefixIcon: Icon(Icons.groups),
              ),
              items: ['Under-14 A', 'Under-16', 'Under-12'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGroup = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2027),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time),
                    title: const Text('Start Time'),
                    subtitle: Text(_startTime.format(context)),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: _startTime,
                      );
                      if (picked != null && picked != _startTime) {
                        setState(() {
                          _startTime = picked;
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time),
                    title: const Text('End Time'),
                    subtitle: Text(_endTime.format(context)),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: _endTime,
                      );
                      if (picked != null && picked != _endTime) {
                        setState(() {
                          _endTime = picked;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Enter location',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter event description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // TODO: Save event
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event created successfully')),
                  );
                }
              },
              child: const Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}
