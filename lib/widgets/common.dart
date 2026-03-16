// widgets/common_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';

class EventCard1 extends StatelessWidget {
  final String title, subtitle, location, status;

  const EventCard1({
    super.key,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isConfirmed = status == "Confirmed";

    return Container(
      width: 260.w,
      //height: 50.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isConfirmed ? accentGreen : accentOrange, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: boldTextStyle(size: 17, color: textPrimary)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isConfirmed ? accentGreen.withOpacity(0.25) : accentOrange.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  status,
                  style: secondaryTextStyle(
                    size: 11,
                    color: isConfirmed ? accentGreen : accentOrange,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          6.height,
          Text(subtitle, style: secondaryTextStyle(size: 13)),
          8.height,
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16.sp, color: textSecondary),
              4.width,
              Text(location, style: secondaryTextStyle(size: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class NotificationListTile extends StatelessWidget {
  final String title;
  final String time;
  final bool isActionRequired;

  const NotificationListTile({
    super.key,
    required this.title,
    required this.time,
    this.isActionRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade500)
        // border: isActionRequired
        //     ? Border(left: BorderSide(color: accentOrange, width: 4.w))
        //     : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isActionRequired ? Icons.warning_amber_rounded : Icons.notifications_outlined,
              color: isActionRequired ? accentOrange : accentGreen,
              size: 22.sp,
            ),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: primaryTextStyle(
                      size: 15,
                      color: textPrimary,
                      weight: isActionRequired ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  4.height,
                  Text(
                    time,
                    style: secondaryTextStyle(size: 12, color: textSecondary),
                  ),
                ],
              ),
            ),
            if (isActionRequired)
              TextButton(
                onPressed: () => toast("Action: $title"),
                child: Text("Act Now", style: TextStyle(color: accentOrange, fontSize: 13.sp)),
              ),
          ],
        ),
      ),
    );
  }
}