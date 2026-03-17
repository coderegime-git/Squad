import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sports/utills/api_service.dart';

import '../../model/member/profile_data.dart';

class AddressData {
  int? id;
  String addressLine1;
  String addressLine2;
  String city;
  String state;
  String postalCode;
  String country;
  String addressType; // "HOME" | "WORK" | "OTHER"
  bool isDefault;

  AddressData({
    this.id,
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.city = '',
    this.state = '',
    this.postalCode = '',
    this.country = '',
    this.addressType = 'HOME',
    this.isDefault = false,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) => AddressData(
    id: json['id'],
    addressLine1: json['addressLine1'] ?? '',
    addressLine2: json['addressLine2'] ?? '',
    city: json['city'] ?? '',
    state: json['state'] ?? '',
    postalCode: json['postalCode'] ?? '',
    country: json['country'] ?? '',
    addressType: json['addressType'] ?? 'HOME',
    isDefault: json['isDefault'] ?? false,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'addressType': addressType,
      'isDefault': isDefault,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  AddressData copyWith({
    int? id,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? addressType,
    bool? isDefault,
  }) => AddressData(
    id: id ?? this.id,
    addressLine1: addressLine1 ?? this.addressLine1,
    addressLine2: addressLine2 ?? this.addressLine2,
    city: city ?? this.city,
    state: state ?? this.state,
    postalCode: postalCode ?? this.postalCode,
    country: country ?? this.country,
    addressType: addressType ?? this.addressType,
    isDefault: isDefault ?? this.isDefault,
  );
}

class ProfileData {
  String firstName;
  String lastName;
  String dateOfBirth;
  String gender;
  String profileImage;
  String emergencyContactName;
  String emergencyContactPhone;
  List<AddressData> addresses;

  ProfileData({
    this.firstName = '',
    this.lastName = '',
    this.dateOfBirth = '',
    this.gender = 'MALE',
    this.profileImage = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.addresses = const [],
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] ?? {};
    final addressList = (json['addresses'] as List<dynamic>? ?? [])
        .map((a) => AddressData.fromJson(a as Map<String, dynamic>))
        .toList();
    return ProfileData(
      firstName: profile['firstName'] ?? '',
      lastName: profile['lastName'] ?? '',
      dateOfBirth: profile['dateOfBirth'] ?? '',
      gender: profile['gender'] ?? 'MALE',
      profileImage: profile['profileImage'] ?? '',
      emergencyContactName: profile['emergencyContactName'] ?? '',
      emergencyContactPhone: profile['emergencyContactPhone'] ?? '',
      addresses: addressList,
    );
  }

  Map<String, dynamic> toJson() => {
    'profile': {
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'profileImage': profileImage,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
    },
    'addresses': addresses.map((a) => a.toJson()).toList(),
  };
}

// ─── Address Form Controllers Helper ─────────────────────────────────────────

class AddressControllers {
  final TextEditingController line1 = TextEditingController();
  final TextEditingController line2 = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController postalCode = TextEditingController();
  final TextEditingController country = TextEditingController();
  String addressType;
  bool isDefault;
  int? id;

  AddressControllers({AddressData? from})
    : addressType = from?.addressType ?? 'HOME',
      isDefault = from?.isDefault ?? false,
      id = from?.id {
    if (from != null) {
      line1.text = from.addressLine1;
      line2.text = from.addressLine2;
      city.text = from.city;
      state.text = from.state;
      postalCode.text = from.postalCode;
      country.text = from.country;
    }
  }

  AddressData toAddressData() => AddressData(
    id: id,
    addressLine1: line1.text.trim(),
    addressLine2: line2.text.trim(),
    city: city.text.trim(),
    state: state.text.trim(),
    postalCode: postalCode.text.trim(),
    country: country.text.trim(),
    addressType: addressType,
    isDefault: isDefault,
  );

  void dispose() {
    line1.dispose();
    line2.dispose();
    city.dispose();
    state.dispose();
    postalCode.dispose();
    country.dispose();
  }
}

// ─── Edit Profile Page ────────────────────────────────────────────────────────

class EditProfilePage extends StatefulWidget {
  final MemberProfileData memberProfileData;

  const EditProfilePage({super.key, required this.memberProfileData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with TickerProviderStateMixin {
  // Profile controllers
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _emergencyNameCtrl;
  late TextEditingController _emergencyPhoneCtrl;

  String _selectedGender = 'MALE';
  bool _isSaving = false;

  // Address controllers list
  final List<AddressControllers> _addressControllers = [];

  final _profileFormKey = GlobalKey<FormState>();
  late AnimationController _saveAnimCtrl;

  // ── Theme ──
  static const _primary = Color(0xFF2563EB);
  static const _primaryLight = Color(0xFFEFF6FF);
  static const _danger = Color(0xFFDC2626);
  static const _dangerLight = Color(0xFFFEF2F2);
  static const _success = Color(0xFF16A34A);
  static const _surface = Color(0xFFF8FAFC);
  static const _border = Color(0xFFE2E8F0);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  final apiService = MemberApiService();

  @override
  void initState() {
    super.initState();
    final p = widget.memberProfileData.data!.profile;
    _firstNameCtrl = TextEditingController(text: p!.firstName ?? "");
    _lastNameCtrl = TextEditingController(text: p.lastName ?? "");
    _dobCtrl = TextEditingController(text: p.dateOfBirth ?? "");
    _emergencyNameCtrl = TextEditingController(
      text: p.emergencyContactName ?? "",
    );
    _emergencyPhoneCtrl = TextEditingController(
      text: p.emergencyContactPhone ?? "",
    );
    _selectedGender = p.gender != null ? p.gender ?? "" : 'MALE';

    // for (final addr in widget.memberProfileData.data.addresses) {
    //   _addressControllers.add(AddressControllers(from: addr));
    // }

    _saveAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _dobCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    for (final c in _addressControllers) {
      c.dispose();
    }
    _saveAnimCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _setDefault(int index) {
    setState(() {
      for (int i = 0; i < _addressControllers.length; i++) {
        _addressControllers[i].isDefault = (i == index);
      }
    });
  }

  void _deleteAddress(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Address',
          style: TextStyle(fontWeight: FontWeight.w700, color: _textPrimary),
        ),
        content: const Text(
          'Are you sure you want to remove this address?',
          style: TextStyle(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _addressControllers[index].dispose();
        _addressControllers.removeAt(index);
        // Ensure at least one default if list not empty
        final hasDefault = _addressControllers.any((c) => c.isDefault);
        if (!hasDefault && _addressControllers.isNotEmpty) {
          _addressControllers.first.isDefault = true;
        }
      });
    }
  }

  void _addAddress() {
    setState(() {
      _addressControllers.add(
        AddressControllers(
          from: AddressData(isDefault: _addressControllers.isEmpty),
        ),
      );
    });
    // Scroll to bottom after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  Future<void> _pickDate() async {
    DateTime initial = DateTime.now();
    try {
      if (_dobCtrl.text.isNotEmpty) {
        initial = DateTime.parse(_dobCtrl.text);
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _primary)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _save() async {
    if (!_profileFormKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final payload = ProfileData(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      dateOfBirth: _dobCtrl.text.trim(),
      gender: _selectedGender,
      profileImage:
          widget.memberProfileData.data!.profile!.profileImageUrl ?? "",
      emergencyContactName: _emergencyNameCtrl.text.trim(),
      emergencyContactPhone: _emergencyPhoneCtrl.text.trim(),
      addresses: _addressControllers.map((c) => c.toAddressData()).toList(),
    );

    debugPrint('PUT /api/profile  →  ${payload.toJson()}');

    // TODO: replace with your actual API call
    await apiService.updateProfile(payload);

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: _success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _label(String text, {bool required = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        if (required)
          const Text(' *', style: TextStyle(color: _danger, fontSize: 13)),
      ],
    ),
  );

  InputDecoration _inputDecoration(String hint, {IconData? icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textSecondary, fontSize: 14),
        prefixIcon: icon != null
            ? Icon(icon, color: _textSecondary, size: 18)
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _danger, width: 1.8),
        ),
      );

  Widget _sectionHeader(String title, {Widget? trailing}) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing,
      ],
    ),
  );

  Widget _card({required Widget child}) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );

  // ── Profile Section ───────────────────────────────────────────────────────

  Widget _buildProfileSection() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Personal Information'),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('First Name', required: true),
                  TextFormField(
                    controller: _firstNameCtrl,
                    decoration: _inputDecoration('Enter first name'),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Last Name', required: true),
                  TextFormField(
                    controller: _lastNameCtrl,
                    decoration: _inputDecoration('Enter last name'),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _label('Date of Birth'),
        TextFormField(
          controller: _dobCtrl,
          readOnly: true,
          onTap: _pickDate,
          decoration: _inputDecoration(
            'YYYY-MM-DD',
            icon: Icons.calendar_today_outlined,
          ),
        ),
        const SizedBox(height: 16),
        _label('Gender', required: true),
        Row(
          children: [
            for (final g in ['MALE', 'FEMALE', 'OTHER'])
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _GenderChip(
                  label: g[0] + g.substring(1).toLowerCase(),
                  selected: _selectedGender == g,
                  onTap: () => setState(() => _selectedGender = g),
                ),
              ),
          ],
        ),
      ],
    ),
  );

  // ── Emergency Section ─────────────────────────────────────────────────────

  Widget _buildEmergencySection() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Emergency Contact'),
        _label('Contact Name'),
        TextFormField(
          controller: _emergencyNameCtrl,
          decoration: _inputDecoration('Full name', icon: Icons.person_outline),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        _label('Contact Phone'),
        TextFormField(
          controller: _emergencyPhoneCtrl,
          decoration: _inputDecoration(
            '+91 XXXXX XXXXX',
            icon: Icons.phone_outlined,
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[+\d]')),
          ],
        ),
      ],
    ),
  );

  // ── Address Card ──────────────────────────────────────────────────────────

  Widget _buildAddressCard(int index) {
    final ctrl = _addressControllers[index];
    final isDefault = ctrl.isDefault;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault ? _primary : _border,
          width: isDefault ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDefault ? _primaryLight : _surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                // Address type selector
                _AddressTypeSelector(
                  selected: ctrl.addressType,
                  onChanged: (v) => setState(() => ctrl.addressType = v),
                ),
                const Spacer(),
                // Default badge / button
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 13),
                        SizedBox(width: 4),
                        Text(
                          'Default',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => _setDefault(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: _primary),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Set Default',
                        style: TextStyle(
                          color: _primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                // Delete button
                GestureDetector(
                  onTap: () => _deleteAddress(index),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _dangerLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: _danger,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Fields ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Address Line 1', required: true),
                TextFormField(
                  controller: ctrl.line1,
                  decoration: _inputDecoration('Street, building, etc.'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                _label('Address Line 2'),
                TextFormField(
                  controller: ctrl.line2,
                  decoration: _inputDecoration('Apt, suite, floor (optional)'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('City', required: true),
                          TextFormField(
                            controller: ctrl.city,
                            decoration: _inputDecoration('City'),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('State', required: true),
                          TextFormField(
                            controller: ctrl.state,
                            decoration: _inputDecoration('State'),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Postal Code', required: true),
                          TextFormField(
                            controller: ctrl.postalCode,
                            decoration: _inputDecoration('000000'),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Country', required: true),
                          TextFormField(
                            controller: ctrl.country,
                            decoration: _inputDecoration('Country'),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Address Section ───────────────────────────────────────────────────────

  Widget _buildAddressSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionHeader(
        'Addresses',
        trailing: TextButton.icon(
          onPressed: _addAddress,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Address'),
          style: TextButton.styleFrom(
            foregroundColor: _primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      if (_addressControllers.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border, style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              Icon(
                Icons.location_off_outlined,
                color: _textSecondary.withOpacity(0.5),
                size: 40,
              ),
              const SizedBox(height: 8),
              const Text(
                'No addresses added',
                style: TextStyle(color: _textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _addAddress,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Address'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        )
      else
        ...List.generate(_addressControllers.length, _buildAddressCard),
    ],
  );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: _textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _primary,
                    ),
                  )
                : TextButton(
                    onPressed: _save,
                    style: TextButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _profileFormKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            _buildProfileSection(),
            _buildEmergencySection(),
            _buildAddressSection(),
            const SizedBox(height: 32),
            // Bottom Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  disabledBackgroundColor: _primary.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Gender Chip ──────────────────────────────────────────────────────────────

class _GenderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const _primary = Color(0xFF2563EB);
  static const _primaryLight = Color(0xFFEFF6FF);
  static const _border = Color(0xFFE2E8F0);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? _primary : _border,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? _primary : _textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Address Type Selector ────────────────────────────────────────────────────

class _AddressTypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _AddressTypeSelector({required this.selected, required this.onChanged});

  static const _types = ['HOME', 'WORK', 'OTHER'];
  static const _icons = [
    Icons.home_outlined,
    Icons.business_outlined,
    Icons.location_on_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_types.length, (i) {
        final isSelected = selected == _types[i];
        return GestureDetector(
          onTap: () => onChanged(_types[i]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2563EB) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _icons[i],
                  size: 14,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  _types[i][0] + _types[i].substring(1).toLowerCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
