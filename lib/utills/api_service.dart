import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports/model/clubAdmin/add_guardians.dart';
import 'package:sports/model/clubAdmin/get_groups.dart';
import 'package:sports/model/guardian/get_your_member.dart';
import 'package:sports/utills/shared_preference.dart';

import '../model/clubAdmin/getSubGroups.dart';
import '../model/clubAdmin/get_coaches.dart';
import '../model/clubAdmin/get_event_details.dart';
import '../model/clubAdmin/get_event_details_by_id.dart';
import '../model/clubAdmin/get_guardians.dart';
import '../model/clubAdmin/get_members.dart';
import '../model/clubAdmin/get_teams.dart';
import '../model/member/get_events_members.dart';


late GlobalKey<NavigatorState> _navigatorKey;

clearUserData() async {}

class ApiBaseHelper {
  initApiService(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  // static const _baseUrl = "https://api.apniride.org/api/";
  // static const _baseUrl = "http://13.55.87.147/api/";
  static const _baseUrl = "http://clubmvp-env.eba-uvibktrv.ap-south-1.elasticbeanstalk.com/";

  // static const _baseUrl = "http://192.168.0.11:9000/api/";
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 300),
      /* receiveDataWhenStatusError: true,
      receiveTimeout: const Duration(seconds: 300),
      responseType: ResponseType.json,
      contentType: Headers.jsonContentType,*/
      // receiveTimeout: 3000,
    ),
  );

  dynamic _returnResponse(Response response) {
    print("response.statusCode");
    print(response.statusCode);
    switch (response.statusCode) {
      case 200:
        var responseJson = response.data;
        return responseJson;
      case 201:
        var responseJson = response.data;
        return responseJson;
      case 400:
        ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: response.data['message'] ?? "Failed to load"),
        );
    // throw BadRequestException(response.data.toString());
      case 401:
        throw UnAuthorisedException(response.data.toString());
      case 403:
        throw UnAuthorisedException(response.data.toString());

      case 500:
        throw FetchDataException('Server error,Please try again later');

      default:
        throw FetchDataException('Server error,Please try again later');
    }
  }

  Map<String, String> getMainHeaders() {
    String? token = SharedPreferenceHelper.getToken() ?? "";
    print("Print ${token}");
    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (token != null && token != "") {
      headers['Authorization'] = '$token';
    }
    return headers;
  }

  Future<dynamic> get(String url) async {
    String params = "";

    var apiUrl = _baseUrl + url + params;
    var headers = getMainHeaders();
    print("apiurl ${apiUrl}");
    print(headers);

    dynamic responseJson;
    try {
      final response = await dio.get(
        apiUrl,
        options: Options(headers: headers),
      );
      responseJson = _returnResponse(response);
    } catch (e) {
      print("sfsdsdsd");
      print(e.toString());
      if (e.toString().contains("401")) {
        clearUserData();
        throw Exception('token_expired');
      } else if (e.toString().contains("403")) {
        /* _showToast(
          _navigatorKey.currentContext!,
          "your_account_is_disabled_Please_contact_admin".tr(),
        );*/
        clearUserData();
        throw Exception('user_inactive');
      } else if (e.toString().contains("500")) {
        /* _showToast(
          _navigatorKey.currentContext!,
          "your_account_is_disabled_Please_contact_admin".tr(),
        );*/
        print(e.toString().contains("500"));
        print("50000");
        // ScaffoldMessenger.of(
        //   _navigatorKey.currentContext!,
        // ).showSnackBar(SnackBar(content: Text("Server error")));

        throw Exception('user_inactive');
      } else if (e.toString().contains("400")) {
        /* _showToast(
          _navigatorKey.currentContext!,
          "your_account_is_disabled_Please_contact_admin".tr(),
        );*/
        print(e.toString().contains("500"));
        print("50000");
        ScaffoldMessenger.of(
          _navigatorKey.currentContext!,
        ).showSnackBar(SnackBar(content: Text("Failed to load")));
        throw Exception('user_inactive');
      } else {
        throw Exception(e.toString());
      }
    }

    return responseJson;
  }

  void _showToast(BuildContext context, message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<dynamic> post(String url, [dynamic body]) async {
    String params = "";

    var apiUrl = _baseUrl + url + params;
    var headers = getMainHeaders();
    dynamic responseJson;
    print("apiUrl ${apiUrl}");
    print("");
    print("headers ${headers}");
    try {
      final response = await dio.post(
        apiUrl,
        data: body,
        options:
        headers['Authorization'] != null ? Options(headers: headers) : null,
      );
      print("responseresponse ${response}");
      responseJson = _returnResponse(response);
    } catch (e) {
      print("sfsdsdsd");
      print(e.toString());
      if (e.toString().contains("401")) {
        clearUserData();
        throw Exception('token_expired');
      } else if (e.toString().contains("403")) {
        /* _showToast(
          _navigatorKey.currentContext!,
          "your_account_is_disabled_Please_contact_admin".tr(),
        );*/
        clearUserData();
        throw Exception('user_inactive');
      } else if (e.toString().contains("500")) {
        /* _showToast(
          _navigatorKey.currentContext!,
          "your_account_is_disabled_Please_contact_admin".tr(),
        );*/
        print(e.toString().contains("500"));
        print("50000");
        ScaffoldMessenger.of(
          _navigatorKey.currentContext!,
        ).showSnackBar(SnackBar(content: Text("Server error")));
        throw Exception('user_inactive');
      } else if (e.toString().contains("400")) {
        /* _showToast(
          _navigatorKey.currentContext!,
          "your_account_is_disabled_Please_contact_admin".tr(),
        );*/
        print(e.toString().contains("500"));
        print("50000");
        _showToast(
          _navigatorKey.currentContext!,
          "your_account_is_disabled_Please_contact_admin",
        );
        ScaffoldMessenger.of(
          _navigatorKey.currentContext!,
        ).showSnackBar(SnackBar(content: Text("Failed to load")));
        throw Exception('user_inactive');
      } else {
        throw Exception(e.toString());
      }
    }

    return responseJson;
  }

  Future<dynamic> put(String url, [dynamic body]) async {
    var headers = getMainHeaders();
    dynamic responseJson;
    try {
      final response = await dio.put(
        url,
        data: jsonEncode(body),
        options: Options(headers: headers),
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }

    return responseJson;
  }

  Future<dynamic> patch(String url, [dynamic body]) async {
    var apiUrl = "${_baseUrl}" + url;
    print("apiUrl: $apiUrl");
    var headers = getMainHeaders();
    print("Headers: $headers");

    try {
      final response = await dio.patch(
        apiUrl,
        data: body,
        options: Options(headers: headers),
      );

      print("Response body: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw FetchDataException('No Internet connection');
      }
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Error response: ${"Failed"}");
        throw FetchDataException('Error: ${"Failed"} - ${"Failed"}');
      } else {
        throw FetchDataException('Unexpected error: ${"Failed"}');
      }
    } catch (e) {
      print("sfsdsdsd");
      print(e.toString());
      if (e.toString().contains("401")) {
        clearUserData();
        throw Exception('token_expired');
      } else if (e.toString().contains("403")) {
        /* _showToast(
          _navigatorKey.currentContext!,
          "your_account_is_disabled_Please_contact_admin".tr(),
        );*/
        clearUserData();
        throw Exception('user_inactive');
      } else if (e.toString().contains("500")) {
        /* _showToast(
          _navigatorKey.currentContext!,
          "your_account_is_disabled_Please_contact_admin".tr(),
        );*/
        print(e.toString().contains("500"));
        print("50000");
        ScaffoldMessenger.of(
          _navigatorKey.currentContext!,
        ).showSnackBar(SnackBar(content: Text("Server error")));
        throw Exception('user_inactive');
      } else if (e.toString().contains("400")) {
        /* _showToast(
          _navigatorKey.currentContext!,
          "your_account_is_disabled_Please_contact_admin".tr(),
        );*/
        print(e.toString().contains("500"));
        print("50000");
        ScaffoldMessenger.of(
          _navigatorKey.currentContext!,
        ).showSnackBar(SnackBar(content: Text("Failed to load")));
        throw Exception('user_inactive');
      } else {
        throw Exception(e.toString());
      }
    }
  }

  Future<dynamic> delete(String url) async {
    var headers = getMainHeaders();
    dynamic apiResponse;
    try {
      final response = await dio.delete(
        url,
        options: Options(headers: headers),
      );
      apiResponse = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return apiResponse;
  }
}

class ClubApiService {
  ClubApiService();

  initApiService(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  final ApiBaseHelper _helper = ApiBaseHelper();


  Future<bool> login(Map<String, dynamic> data) async {
    try {
      print("Login data: $data");

      final fullResponse = await _helper.post("auth/login", data);
      final jsonResponse = jsonEncode(fullResponse);

      print("jsonResponse  ${jsonResponse}");
      if (fullResponse['success'] == true) {
        print("Login successful → ${fullResponse['message']}");
        SharedPreferenceHelper.setToken(fullResponse['data']['accessToken']);
        print("tokentoken");
        print(SharedPreferenceHelper.getToken());
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
      return false;
    } catch (e) {
      print("Login failed: $e");
      return false;
    }
  }
  Future<bool> AddMember(Map<String, dynamic> data) async {
    try {
      print("Add member data: $data");

      final fullResponse = await _helper.post("api/members", data);
      final jsonResponse = jsonEncode(fullResponse);

      print("jsonResponse  ${jsonResponse}");
      if (fullResponse['success'] == true) {
        print("Add member successful → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
      return false;
    } catch (e) {
      print("Login failed: $e");
      return false;
    }
  }
  Future<bool> AddGuardian(Map<String, dynamic> data) async {
    try {
      print("Add guardian data : $data");

      final fullResponse = await _helper.post("api/guardians", data);
      final jsonResponse = jsonEncode(fullResponse);

      print("jsonResponse  ${jsonResponse}");
      if (fullResponse['success'] == true) {
        print("Add Guardian → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
      return false;
    } catch (e) {
      print("Login failed: $e");
      return false;
    }
  }
  Future<bool> AddCoach(Map<String, dynamic> data) async {
    try {
      print("Add guardian data : $data");

      final fullResponse = await _helper.post("api/coaches", data);
      final jsonResponse = jsonEncode(fullResponse);

      print("jsonResponse  ${jsonResponse}");
      if (fullResponse['success'] == true) {
        print("Add Coaches → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
      return false;
    } catch (e) {
      print("Add Coach failed: $e");
      return false;
    }
  }
  Future<bool> AddEvents(Map<String, dynamic> data) async {
    try {
      print("Add Event data : $data");

      final fullResponse = await _helper.post("api/events", data);
      final jsonResponse = jsonEncode(fullResponse);

      print("jsonResponse  ${jsonResponse}");
      if (fullResponse['success'] == true) {
        print("Add Events → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
      return false;
    } catch (e) {
      print("Add Coach failed: $e");
      return false;
    }
  }

  Future<GetMembers> getMembers() async {
    try {
      final fullResponse = await _helper.get("api/members");
      print("status status");
      fullResponse['success'];
      print(fullResponse['success']);
      final jsonResponse = jsonEncode(fullResponse);
      return GetMembersFromJson(jsonResponse);
    } catch (e) {
      print("Menu fetch failed: $e");
      rethrow;
    }
  }
  Future<GetCoaches> getCoaches() async {
    try {
      final fullResponse = await _helper.get("api/coaches");
      print("status status");
      fullResponse['success'];
      print(fullResponse['success']);
      final jsonResponse = jsonEncode(fullResponse);
      return GetCoachesFromJson(jsonResponse);
    } catch (e) {
      print("Menu fetch failed: $e");
      rethrow;
    }
  }
  Future<bool> deleteCoaches(int id) async {
    try {
      print("delete Coaches data : $id");

      final fullResponse = await _helper.delete("api/coaches/${id}");
      final jsonResponse = jsonEncode(fullResponse);

      print("jsonResponse  ${jsonResponse}");
      if (fullResponse['success'] == true) {
        print("delete Coaches → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
      return false;
    } catch (e) {
      print("delete failed: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getTasks() async {
    try {
      final fullResponse = await _helper.get("api/tasks");
      print("getTasks response: $fullResponse");
      if (fullResponse['success'] == true) {
        return fullResponse['data'] as Map<String, dynamic>;
      } else {
        print("getTasks failure: ${fullResponse['message']}");
        return null;
      }
    } catch (e) {
      print("getTasks failed: $e");
      return null;
    }
  }
  Future<GetGuardians> getGuardians() async {
    try {
      final fullResponse = await _helper.get("api/guardians");
      print("status status");
      fullResponse['success'];
      print(fullResponse['success']);
      final jsonResponse = jsonEncode(fullResponse);
      return GetGuardiansFromJson(jsonResponse);
    } catch (e) {
      print("Menu fetch failed: $e");
      rethrow;
    }
  }
  Future<bool> deleteMembers(int id) async {
    try {
      print("delete member data : $id");

      final fullResponse = await _helper.delete("api/members/${id}");
      final jsonResponse = jsonEncode(fullResponse);

      print("jsonResponse  ${jsonResponse}");
      if (fullResponse['success'] == true) {
        print("delete Member → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
      return false;
    } catch (e) {
      print("delete failed: $e");
      return false;
    }
  }
  Future<bool> deleteGuardians(int id) async {
    try {
      print("delete guardian data : $id");

      final fullResponse = await _helper.delete("api/guardians/${id}");
      final jsonResponse = jsonEncode(fullResponse);

      print("jsonResponse  ${jsonResponse}");
      if (fullResponse['success'] == true) {
        print("delete Guardian → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
      return false;
    } catch (e) {
      print("delete failed: $e");
      return false;
    }
  }
  Future<bool> mapGuardian(int memberId,int guardianId) async {
    try {
      print("map guardian data: ${memberId},${guardianId}");

      final fullResponse = await _helper.post("api/members/${memberId}/guardians/${guardianId}");
      final jsonResponse = jsonEncode(fullResponse);

      print("jsonResponse  ${jsonResponse}");
      print("jsonResponse  ${jsonResponse}");
      if (fullResponse['success'] == true) {
        print("map member to guardian link successfully → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
    } catch (e) {
      print("map member to guardian failed $e");
      return false;
    }
  }
  Future<GetEventDetails> getEvents() async {
    try {
      final fullResponse = await _helper.get("api/events");
      print("status status");
      fullResponse['success'];
      print(fullResponse['success']);
      final jsonResponse = jsonEncode(fullResponse);
      return GetEventDetailsFromJson(jsonResponse);
    } catch (e) {
      print("Get Events failed: $e");
      rethrow;
    }
  }
  Future<GetEventById> getEventById(int eventId) async {
    try {
      print("Get Event by id: $eventId");
      final fullResponse = await _helper.get("api/events/$eventId");
      print("getEventById response: $fullResponse");
      final jsonResponse = jsonEncode(fullResponse);
      return getEventByIdFromJson(jsonResponse);
    } catch (e) {
      print("getEventById failed: $e");
      rethrow;
    }
  }
  Future<bool> deleteEvent(int eventId) async {
    print("delete event");
    print("delete event");
    try {
      print("Delete event id: $eventId");
      final fullResponse = await _helper.delete("api/events/$eventId");
      final jsonResponse = jsonEncode(fullResponse);
      print("jsonResponse  $jsonResponse");
      if (fullResponse['success'] == true) {
        print("Delete Event → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
    } catch (e) {
      print("Delete event failed: $e");
      return false;
    }
  }
  // ══════════════════════════════════════════════════════════════
  // EVENT GROUP APIs  — newly added, nothing above changed
  // ══════════════════════════════════════════════════════════════

  /// POST /api/events/{eventId}/groups
  Future<bool> createGroup(int eventId, Map<String, dynamic> data) async {
    try {
      print("Create group data: $data for eventId: $eventId");
      final fullResponse =
      await _helper.post("api/events/$eventId/groups", data);
      final jsonResponse = jsonEncode(fullResponse);
      print("jsonResponse  $jsonResponse");
      if (fullResponse['success'] == true) {
        print("Create Group → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
    } catch (e) {
      print("Create group failed: $e");
      return false;
    }
  }

  /// GET /api/events/{eventId}/groups
  Future<GetGroups> getGroupsByEvent(int eventId) async {
    try {
      print("Get groups for eventId: $eventId");
      final fullResponse = await _helper.get("api/events/$eventId/groups");
      fullResponse['success'];
      print(fullResponse['success']);
      final jsonResponse = jsonEncode(fullResponse);
      return getGroupsFromJson(jsonResponse);
    } catch (e) {
      print("Get groups failed: $e");
      rethrow;
    }
  }

  /// PUT /api/events/{eventId}/groups/{groupId}
  Future<bool> updateGroup(
      int eventId, int groupId, Map<String, dynamic> data) async {
    try {
      print(
          "Update group data: $data for eventId: $eventId groupId: $groupId");
      final fullResponse =
      await _helper.put("api/events/$eventId/groups/$groupId", data);
      final jsonResponse = jsonEncode(fullResponse);
      print("jsonResponse  $jsonResponse");
      if (fullResponse['success'] == true) {
        print("Update Group → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
    } catch (e) {
      print("Update group failed: $e");
      return false;
    }
  }

  /// DELETE /api/events/{eventId}/groups/{groupId}
  Future<bool> deleteGroup(int eventId, int groupId) async {
    print("Delete group");
    print("Delete group");
    try {
      print("Delete group eventId: $eventId groupId: $groupId");
      final fullResponse =
      await _helper.delete("api/events/$eventId/groups/$groupId");
      final jsonResponse = jsonEncode(fullResponse);
      print("jsonResponse  $jsonResponse");
      if (fullResponse['success'] == true) {
        print("Delete Group → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
    } catch (e) {
      print("Delete group failed: $e");
      return false;
    }
  }
  // NEW METHODS TO ADD TO ClubApiService in utills/api_service.dart
// Add these methods inside the ClubApiService class

  // ══════════════════════════════════════════════════════════════
  // SUB-GROUP APIs
  // ══════════════════════════════════════════════════════════════

  /// POST /api/groups/{groupId}/sub-groups
  Future<bool> createSubGroup(int groupId, Map<String, dynamic> data) async {
    try {
      print("Create sub-group data: $data for groupId: $groupId");
      final fullResponse =
      await _helper.post("api/groups/$groupId/sub-groups", data);
      final jsonResponse = jsonEncode(fullResponse);
      print("jsonResponse  $jsonResponse");
      if (fullResponse['success'] == true) {
        print("Create SubGroup → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
    } catch (e) {
      print("Create sub-group failed: $e");
      return false;
    }
  }

  /// GET /api/groups/{groupId}/sub-groups
  Future<GetSubGroups> getSubGroups(int groupId) async {
    try {
      print("Get sub-groups for groupId: $groupId");
      final fullResponse = await _helper.get("api/groups/$groupId/sub-groups");
      final jsonResponse = jsonEncode(fullResponse);
      return getSubGroupsFromJson(jsonResponse);
    } catch (e) {
      print("Get sub-groups failed: $e");
      rethrow;
    }
  }

  /// PUT /api/groups/{groupId}/sub-groups/{subGroupId}
  Future<bool> updateSubGroup(
      int groupId, int subGroupId, Map<String, dynamic> data) async {
    try {
      print("Update sub-group data: $data groupId: $groupId subGroupId: $subGroupId");
      final fullResponse = await _helper
          .put("api/groups/$groupId/sub-groups/$subGroupId", data);
      final jsonResponse = jsonEncode(fullResponse);
      print("jsonResponse  $jsonResponse");
      if (fullResponse['success'] == true) {
        print("Update SubGroup → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
    } catch (e) {
      print("Update sub-group failed: $e");
      return false;
    }
  }

  /// DELETE /api/groups/{groupId}/sub-groups/{subGroupId}
  Future<bool> deleteSubGroup(int groupId, int subGroupId) async {
    print("Delete sub group");
    print("Delete sub group");
    try {
      print("Delete sub-group groupId: $groupId subGroupId: $subGroupId");
      final fullResponse =
      await _helper.delete("api/groups/$groupId/sub-groups/$subGroupId");
      final jsonResponse = jsonEncode(fullResponse);
      print("jsonResponse  $jsonResponse");
      if (fullResponse['success'] == true) {
        print("Delete SubGroup → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
    } catch (e) {
      print("Delete sub-group failed: $e");
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // TEAM APIs
  // ══════════════════════════════════════════════════════════════

  /// POST /api/sub-groups/{subGroupId}/teams
  Future<bool> createTeam(int subGroupId, Map<String, dynamic> data) async {
    try {
      print("Create team data: $data for subGroupId: $subGroupId");
      final fullResponse =
      await _helper.post("api/sub-groups/$subGroupId/teams", data);
      final jsonResponse = jsonEncode(fullResponse);
      print("jsonResponse  $jsonResponse");
      if (fullResponse['success'] == true) {
        print("Create Team → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
    } catch (e) {
      print("Create team failed: $e");
      return false;
    }
  }

  /// GET /api/sub-groups/{subGroupId}/teams
  Future<GetTeams> getTeams(int subGroupId) async {
    try {
      print("Get teams for subGroupId: $subGroupId");
      final fullResponse =
      await _helper.get("api/sub-groups/$subGroupId/teams");
      final jsonResponse = jsonEncode(fullResponse);
      return getTeamsFromJson(jsonResponse);
    } catch (e) {
      print("Get teams failed: $e");
      rethrow;
    }
  }

  /// DELETE /api/sub-groups/{subGroupId}/teams/{teamId}
  Future<bool> deleteTeam(int subGroupId, int teamId) async {
    print("delete Team");
    print("delete Team");
    try {
      print("Delete team subGroupId: $subGroupId teamId: $teamId");
      final fullResponse =
      await _helper.delete("api/sub-groups/$subGroupId/teams/$teamId");
      final jsonResponse = jsonEncode(fullResponse);
      print("jsonResponse  $jsonResponse");
      if (fullResponse['success'] == true) {
        print("Delete Team → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
    } catch (e) {
      print("Delete team failed: $e");
      return false;
    }
  }


  /// POST /api/teams/{teamId}/members
  Future<bool> assignMembersToTeam(
      int teamId, List<int> memberIds) async {
    try {
      print("Assign members $memberIds to teamId: $teamId");
      final fullResponse = await _helper.post(
        "api/teams/$teamId/members",
        {"teamId": teamId, "memberIds": memberIds},
      );
      print("full response ${fullResponse}");
      final jsonResponse = jsonEncode(fullResponse);
      print("jsonResponse  $jsonResponse");
      if (fullResponse['success'] == true) {
        print("Assign Members → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
    } catch (e) {
      print("Assign members failed: $e");
      return false;
    }
  }

  /// GET /api/teams/{teamId}/members
  Future<GetMembers> getTeamMembers(int teamId) async {
    try {
      print("Get team members for teamId: $teamId");
      final fullResponse = await _helper.get("api/teams/$teamId/members");
      final jsonResponse = jsonEncode(fullResponse);
      return GetMembersFromJson(jsonResponse);
    } catch (e) {
      print("Get team members failed: $e");
      rethrow;
    }
  }

  /// DELETE /api/teams/{teamId}/members/{memberId}
  Future<bool> removeTeamMember(int teamId, int memberId) async {
    try {
      print("Remove member $memberId from team $teamId");
      final fullResponse =
      await _helper.delete("api/teams/$teamId/members/$memberId");
      final jsonResponse = jsonEncode(fullResponse);
      print("jsonResponse  $jsonResponse");
      if (fullResponse['success'] == true) {
        print("Remove Team Member → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
    } catch (e) {
      print("Remove team member failed: $e");
      return false;
    }
  }



  /// POST /api/events — returns eventId on success, -1 on failure
  Future<int> addEvent(Map<String, dynamic> data) async {
    try {
      print("Add Event data : $data");
      final fullResponse = await _helper.post("api/events", data);
      final jsonResponse = jsonEncode(fullResponse);
      print("jsonResponse  $jsonResponse");
      if (fullResponse['success'] == true) {
        print("Add Events → ${fullResponse['message']}");
        // Try to extract eventId from response data
        final responseData = fullResponse['data'];
        if (responseData is Map && responseData['eventId'] != null) {
          return responseData['eventId'] as int;
        }
        if (responseData is Map && responseData['id'] != null) {
          return responseData['id'] as int;
        }
        return 0; // success but no id returned
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return -1;
      }
    } catch (e) {
      print("Add Event failed: $e");
      return -1;
    }
  }
}

class ParentApiService {
  ParentApiService();

  initApiService(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  final ApiBaseHelper _helper = ApiBaseHelper();

  Future<GetYourMember> getYourMembers() async {
    try {
      final fullResponse = await _helper.get("api/members/8/members");
      print("status status");
      fullResponse['success'];
      print(fullResponse['success']);
      final jsonResponse = jsonEncode(fullResponse);
      return GetYourMemberFromJson(jsonResponse);
    } catch (e) {
      print("Menu fetch failed: $e");
      rethrow;
    }
  }
}
class MemberApiService {
  MemberApiService();

  initApiService(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  final ApiBaseHelper _helper = ApiBaseHelper();
  // ══════════════════════════════════════════════════════════════════════════════
// ADD THESE 3 METHODS to ClubApiService in lib/utills/api_service.dart
//
// STEP 1: Add this import at the top of api_service.dart:
//   import '../model/member/get_member_events.dart';
//
// STEP 2: Paste these 3 methods inside ClubApiService class
// ══════════════════════════════════════════════════════════════════════════════

  /// GET /api/member/events — all events for logged-in member
  Future<GetMemberEvents> getMemberEvents() async {
    try {
      final fullResponse = await _helper.get("api/member/events");
      print("getMemberEvents success: ${fullResponse['success']}");
      final jsonResponse = jsonEncode(fullResponse);
      return getMemberEventsFromJson(jsonResponse);
    } catch (e) {
      print("getMemberEvents failed: $e");
      rethrow;
    }
  }

  /// GET /api/member/events/pending — pending events only
  Future<GetMemberEvents> getMemberPendingEvents() async {
    try {
      final fullResponse = await _helper.get("api/member/events/pending");
      print("getMemberPendingEvents success: ${fullResponse['success']}");
      final jsonResponse = jsonEncode(fullResponse);
      return getMemberEventsFromJson(jsonResponse);
    } catch (e) {
      print("getMemberPendingEvents failed: $e");
      rethrow;
    }
  }

  /// PUT /api/member/events/status — update event status
  /// status values: "ACCEPTED" or "REJECTED"
  Future<bool> updateMemberEventStatus(int eventId, String status) async {
    try {
      print("updateMemberEventStatus eventId: $eventId status: $status");
      final fullResponse = await _helper.put(
        "api/member/events/status",
        {"eventId": eventId, "status": status},
      );
      print("updateMemberEventStatus response: $fullResponse");
      if (fullResponse['success'] == true) {
        print("Update status success → ${fullResponse['message']}");
        return true;
      } else {
        print("Update status failure: ${fullResponse['message']}");
        return false;
      }
    } catch (e) {
      print("updateMemberEventStatus failed: $e");
      return false;
    }
  }
}

class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnAuthorisedException extends AppException {
  UnAuthorisedException([message]) : super(message, "UnAuthorised: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([message]) : super(message, "Invalid Input: ");
}