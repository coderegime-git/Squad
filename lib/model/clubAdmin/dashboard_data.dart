class DashboardData {
  Members? members;
  int? coaches;
  int? groups;
  int? activities;
  Events? events;
  Payments? payments;
  Revenue? revenue;
  List<String>? alerts;

  DashboardData({
    this.members,
    this.coaches,
    this.groups,
    this.activities,
    this.events,
    this.payments,
    this.revenue,
    this.alerts,
  });

  DashboardData.fromJson(Map<String, dynamic> json) {
    members = json['members'] != null
        ? new Members.fromJson(json['members'])
        : null;
    coaches = json['coaches'];
    groups = json['groups'];
    activities = json['activities'];
    events = json['events'] != null
        ? new Events.fromJson(json['events'])
        : null;
    payments = json['payments'] != null
        ? new Payments.fromJson(json['payments'])
        : null;
    revenue = json['revenue'] != null
        ? new Revenue.fromJson(json['revenue'])
        : null;
    alerts = json['alerts'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.members != null) {
      data['members'] = this.members!.toJson();
    }
    data['coaches'] = this.coaches;
    data['groups'] = this.groups;
    data['activities'] = this.activities;
    if (this.events != null) {
      data['events'] = this.events!.toJson();
    }
    if (this.payments != null) {
      data['payments'] = this.payments!.toJson();
    }
    if (this.revenue != null) {
      data['revenue'] = this.revenue!.toJson();
    }
    data['alerts'] = this.alerts;
    return data;
  }
}

class Members {
  int? total;
  int? active;

  Members({this.total, this.active});

  Members.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['active'] = this.active;
    return data;
  }
}

class Events {
  int? upcomingCount;

  Events({this.upcomingCount});

  Events.fromJson(Map<String, dynamic> json) {
    upcomingCount = json['upcomingCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['upcomingCount'] = this.upcomingCount;
    return data;
  }
}

class Payments {
  Pending? pending;
  Pending? overdue;

  Payments({this.pending, this.overdue});

  Payments.fromJson(Map<String, dynamic> json) {
    pending = json['pending'] != null
        ? new Pending.fromJson(json['pending'])
        : null;
    overdue = json['overdue'] != null
        ? new Pending.fromJson(json['overdue'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pending != null) {
      data['pending'] = this.pending!.toJson();
    }
    if (this.overdue != null) {
      data['overdue'] = this.overdue!.toJson();
    }
    return data;
  }
}

class Pending {
  int? count;
  double? amount;

  Pending({this.count, this.amount});

  Pending.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    amount = json['amount'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['amount'] = this.amount;
    return data;
  }
}

class Revenue {
  int? currentPeriod;

  Revenue({this.currentPeriod});

  Revenue.fromJson(Map<String, dynamic> json) {
    currentPeriod = json['currentPeriod'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currentPeriod'] = this.currentPeriod;
    return data;
  }
}
