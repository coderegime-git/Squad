// lib/model/clubAdmin/club_settings_data.dart

class ClubSettingsData {
  final int? clubId;
  final String? clubName;
  final String? registeredName;
  final String? description;
  final ClubAddress? address;
  final String? contactPersonName;
  final String? contactEmail;
  final String? contactPhone;

  ClubSettingsData({
    this.clubId,
    this.clubName,
    this.registeredName,
    this.description,
    this.address,
    this.contactPersonName,
    this.contactEmail,
    this.contactPhone,
  });

  factory ClubSettingsData.fromJson(Map<String, dynamic> json) {
    return ClubSettingsData(
      clubId:            json['clubId'] as int?,
      clubName:          json['clubName'] as String?,
      registeredName:    json['registeredName'] as String?,
      description:       json['description'] as String?,
      address:           json['address'] != null
          ? ClubAddress.fromJson(
          Map<String, dynamic>.from(json['address']))
          : null,
      contactPersonName: json['contactPersonName'] as String?,
      contactEmail:      json['contactEmail'] as String?,
      contactPhone:      json['contactPhone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (clubId          != null) 'clubId':            clubId,
      if (clubName        != null) 'clubName':          clubName,
      if (registeredName  != null) 'registeredName':    registeredName,
      if (description     != null) 'description':       description,
      if (address         != null) 'address':           address!.toJson(),
      if (contactPersonName != null) 'contactPersonName': contactPersonName,
      if (contactEmail    != null) 'contactEmail':      contactEmail,
      if (contactPhone    != null) 'contactPhone':      contactPhone,
    };
  }

  /// Returns a copy with updated fields — useful for partial updates
  ClubSettingsData copyWith({
    int?          clubId,
    String?       clubName,
    String?       registeredName,
    String?       description,
    ClubAddress?  address,
    String?       contactPersonName,
    String?       contactEmail,
    String?       contactPhone,
  }) {
    return ClubSettingsData(
      clubId:            clubId            ?? this.clubId,
      clubName:          clubName          ?? this.clubName,
      registeredName:    registeredName    ?? this.registeredName,
      description:       description       ?? this.description,
      address:           address           ?? this.address,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      contactEmail:      contactEmail      ?? this.contactEmail,
      contactPhone:      contactPhone      ?? this.contactPhone,
    );
  }

  @override
  String toString() => 'ClubSettingsData('
      'clubId: $clubId, '
      'clubName: $clubName, '
      'registeredName: $registeredName, '
      'description: $description, '
      'address: $address, '
      'contactPersonName: $contactPersonName, '
      'contactEmail: $contactEmail, '
      'contactPhone: $contactPhone)';
}

// ─────────────────────────────────────────────────────────────────────────────

class ClubAddress {
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;

  ClubAddress({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  factory ClubAddress.fromJson(Map<String, dynamic> json) {
    return ClubAddress(
      addressLine1: json['addressLine1'] as String?,
      addressLine2: json['addressLine2'] as String?,
      city:         json['city']         as String?,
      state:        json['state']        as String?,
      postalCode:   json['postalCode']   as String?,
      country:      json['country']      as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (addressLine1 != null) 'addressLine1': addressLine1,
      if (addressLine2 != null) 'addressLine2': addressLine2,
      if (city         != null) 'city':         city,
      if (state        != null) 'state':        state,
      if (postalCode   != null) 'postalCode':   postalCode,
      if (country      != null) 'country':      country,
    };
  }

  ClubAddress copyWith({
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
  }) {
    return ClubAddress(
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city:         city         ?? this.city,
      state:        state        ?? this.state,
      postalCode:   postalCode   ?? this.postalCode,
      country:      country      ?? this.country,
    );
  }

  @override
  String toString() => 'ClubAddress('
      'addressLine1: $addressLine1, '
      'addressLine2: $addressLine2, '
      'city: $city, '
      'state: $state, '
      'postalCode: $postalCode, '
      'country: $country)';
}

// ─────────────────────────────────────────────────────────────────────────────

/// Wrapper for the full API response envelope
class ClubSettingsResponse {
  final bool success;
  final String? message;
  final ClubSettingsData? data;
  final String? errorCode;

  ClubSettingsResponse({
    required this.success,
    this.message,
    this.data,
    this.errorCode,
  });

  factory ClubSettingsResponse.fromJson(Map<String, dynamic> json) {
    return ClubSettingsResponse(
      success:   json['success'] as bool? ?? false,
      message:   json['message'] as String?,
      errorCode: json['errorCode'] as String?,
      data:      json['data'] != null && json['data'] is Map
          ? ClubSettingsData.fromJson(
          Map<String, dynamic>.from(json['data']))
          : null,
    );
  }
}