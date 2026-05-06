import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sports/model/clubAdmin/activities_data.dart';
import 'package:sports/model/clubAdmin/add_guardians.dart';
import 'package:sports/model/clubAdmin/dashboard_data.dart';
import 'package:sports/model/clubAdmin/get_groups.dart';
import 'package:sports/model/coach/event_attendance_data.dart';
import 'package:sports/model/coach/group_memebers_data.dart';
import 'package:sports/model/guardian/get_your_member.dart';
import 'package:sports/model/member/metrics.dart';
import 'package:sports/model/member/profile_data.dart';
import 'package:sports/utills/shared_preference.dart';
import '../model/clubAdmin/get_direct_group_members.dart';
import '../model/clubAdmin/get_members.dart' as membersModel;

import '../model/clubAdmin/activity_mapped_event_data.dart';
import '../model/clubAdmin/getSubGroups.dart';
import '../model/clubAdmin/get_coaches.dart';
import '../model/clubAdmin/get_event_details.dart';
import '../model/clubAdmin/get_event_details_by_id.dart';
import '../model/clubAdmin/get_guardians.dart';
import '../model/clubAdmin/get_members.dart';
import '../model/clubAdmin/get_subgroups_member.dart';
import '../model/clubAdmin/get_teams.dart';
import '../model/coach/club.dart';
import '../model/coach/club_member.dart';
import '../model/coach/coach_dashboard_data.dart';
import '../model/coach/coach_event.dart';
import '../model/coach/event_performance_data.dart';
import '../model/get_clubs_data.dart';
import '../model/guardian/getGuardianEvents.dart';
import '../model/guardian/get_member_dashboard_data.dart';
import '../model/member/get_events_members.dart';
import '../model/member/get_guardian_for_members.dart';
import '../model/member/get_member_dashboard.dart';
import '../model/notification_data.dart';

// late GlobalKey<NavigatorState> _navigatorKey;
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void clearUserData() async {
  SharedPreferenceHelper.clear();
}

class ApiBaseHelper {
  void initApiService(GlobalKey<NavigatorState> navigatorKey) {}

  // initApiService(GlobalKey<NavigatorState> navigatorKey) {
  //   _navigatorKey = navigatorKey;
  // }

  // static const _baseUrl = "https://api.apniride.org/api/";
  // static const _baseUrl = "http://13.55.87.147/api/";
  static const _baseUrl =
      "http://clubmvp-env.eba-uvibktrv.ap-south-1.elasticbeanstalk.com/";

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
        print('❌ 400 from _returnResponse: ${response.data}');
        final msg = response.data is Map
            ? response.data['message']?.toString() ?? 'Bad request'
            : 'Bad request';
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

    if (token != "") {
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
      print("responseJson ${responseJson}");
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
        if (e is DioException) {
          final responseData = e.response?.data;
          print('❌ 400 Bad Request');
          print('   Status : ${e.response?.statusCode}');
          print('   URL    : ${e.requestOptions.uri}');
          print('   Body   : $responseData');

          // Extract the message if it's a Map
          final message = responseData is Map
              ? responseData['message']?.toString() ?? 'Bad request'
              : responseData?.toString() ?? 'Bad request';

          throw Exception(message); // ← throws the actual server message
        }
        throw Exception('Bad request');
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
        options: headers['Authorization'] != null
            ? Options(headers: headers)
            : null,
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
        if (e is DioException) {
          final responseData = e.response?.data;
          print('❌ 400 Bad Request');
          print('   Status : ${e.response?.statusCode}');
          print('   URL    : ${e.requestOptions.uri}');
          print('   Body   : $responseData');

          // Extract the message if it's a Map
          final message = responseData is Map
              ? responseData['message']?.toString() ?? 'Bad request'
              : responseData?.toString() ?? 'Bad request';

          throw Exception(message); // ← throws the actual server message
        }
        throw Exception('Bad request');
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
        if (e is DioException) {
          final responseData = e.response?.data;
          print('❌ 400 Bad Request');
          print('   Status : ${e.response?.statusCode}');
          print('   URL    : ${e.requestOptions.uri}');
          print('   Body   : $responseData');

          // Extract the message if it's a Map
          final message = responseData is Map
              ? responseData['message']?.toString() ?? 'Bad request'
              : responseData?.toString() ?? 'Bad request';

          throw Exception(message); // ← throws the actual server message
        }
        throw Exception('Bad request');
        /* _showToast(
          _navigatorKey.currentContext!,
          "your_account_is_disabled_Please_contact_admin".tr(),
        );*/
        if (e is DioException) {
          final responseData = e.response?.data;
          print('❌ 400 Bad Request');
          print('   Status : ${e.response?.statusCode}');
          print('   URL    : ${e.requestOptions.uri}');
          print('   Body   : $responseData');

          // Extract the message if it's a Map
          final message = responseData is Map
              ? responseData['message']?.toString() ?? 'Bad request'
              : responseData?.toString() ?? 'Bad request';

          throw Exception(message); // ← throws the actual server message
        }
        throw Exception('Bad request');
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
  Future<dynamic> deleteWithBody(String url, [dynamic body]) async {
    var apiUrl = ApiBaseHelper._baseUrl + url;
    var headers = getMainHeaders();
    dynamic responseJson;
    try {
      final response = await dio.delete(
        apiUrl,
        data: body,
        options: Options(headers: headers),
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } catch (e) {
      print("deleteWithBody error: $e");
      if (e.toString().contains("401")) {
        clearUserData();
        throw Exception('token_expired');
      }
      rethrow;
    }
    return responseJson;
  }
}

class ClubApiService {
  ClubApiService();

  void initApiService(GlobalKey<NavigatorState> navigatorKey) {}

  // initApiService(GlobalKey<NavigatorState> navigatorKey) {
  //   _navigatorKey = navigatorKey;
  // }

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
    } catch (e) {
      print("Login failed: $e");
      return false;
    }
  }

  Future<DashboardData> getDashboardData() async {
    final fullResponse = await _helper.get("api/dashboard/admin");
    print(fullResponse);
    print(fullResponse['data']['events']);
    print(fullResponse['data']['payments']);
    return DashboardData.fromJson(fullResponse["data"]);
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
    } catch (e) {
      print("delete failed: $e");
      return false;
    }
  }

  Future<bool> mapGuardian(int memberId, int guardianId) async {
    try {
      print("map guardian data: ${memberId},${guardianId}");

      final fullResponse = await _helper.post(
        "api/members/${memberId}/guardians/${guardianId}",
      );
      final jsonResponse = jsonEncode(fullResponse);

      print("jsonResponse  ${jsonResponse}");
      print("jsonResponse  ${jsonResponse}");
      if (fullResponse['success'] == true) {
        print(
          "map member to guardian link successfully → ${fullResponse['message']}",
        );
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


  Future<bool> createGroup(int eventId, Map<String, dynamic> data) async {
    try {
      print("Create group data: $data for eventId: $eventId");
      final fullResponse = await _helper.post(
        "api/events/$eventId/groups",
        data,
      );
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
    int eventId,
    int groupId,
    Map<String, dynamic> data,
  ) async {
    try {
      print("Update group data: $data for eventId: $eventId groupId: $groupId");
      final fullResponse = await _helper.put(
        "api/events/$eventId/groups/$groupId",
        data,
      );
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

  Future<ActivityData> addActivities(String clubId, dynamic body) async {
    try {
      final fullResponse = await _helper.post(
        "api/clubs/$clubId/activities",
        body,
      );
      print("getMemberEvents success: ${fullResponse}");
      jsonEncode(fullResponse);
      return activityDataFromJson(fullResponse);
    } catch (e) {
      print("getMemberEvents failed: $e");
      rethrow;
    }
  }

  Future<ActivityData> updateActivities(String activityId, dynamic body) async {
    try {
      final fullResponse = await _helper.put(
        "api/activities/$activityId",
        body,
      );
      print("getMemberEvents success: ${fullResponse}");
      jsonEncode(fullResponse);
      return activityDataFromJson(fullResponse);
    } catch (e) {
      print("getMemberEvents failed: $e");
      rethrow;
    }
  }

  Future<dynamic> deleteActivities(String activityId) async {
    try {
      final fullResponse = await _helper.delete("api/activities/$activityId");
      jsonEncode(fullResponse);
      return fullResponse;
    } catch (e) {
      print("getMemberEvents failed: $e");
      rethrow;
    }
  }

  Future<dynamic> mapActivitiesEvents(String activityId, String eventId) async {
    try {
      final fullResponse = await _helper.post(
        "api/activities/$activityId/events/$eventId",
      );
      jsonEncode(fullResponse);
      return fullResponse;
    } catch (e) {
      print("getMemberEvents failed: $e");
      rethrow;
    }
  }

  Future<ActivityMappedEventData> getMapActivitiesEvents(
    String activityId,
  ) async {
    try {
      final fullResponse = await _helper.get(
        "api/activities/$activityId/events",
      );
      jsonEncode(fullResponse);
      return activityMappedEventDataFromJson(fullResponse);
    } catch (e) {
      print("getMemberEvents failed: $e");
      rethrow;
    }
  }

  Future<List<ActivityListData>> getActivities(String clubId) async {
    try {
      final fullResponse = await _helper.get("api/clubs/$clubId/activities");

      print("getMemberEvents success: $fullResponse");

      List<ActivityListData> data = [];
      jsonEncode(fullResponse);

      for (var item in fullResponse['data']) {
        data.add(ActivityListData.fromJson(item));
      }

      return data;
    } catch (e) {
      print("getMemberEvents failed: $e");
      rethrow;
    }
  }
  Future<bool> deleteGroup(int eventId, int groupId) async {
    print("Delete group");
    print("Delete group");
    try {
      print("Delete group eventId: $eventId groupId: $groupId");
      final fullResponse = await _helper.delete(
        "api/events/$eventId/groups/$groupId",
      );
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
  Future<bool> createSubGroup(int groupId, Map<String, dynamic> data) async {
    try {
      print("Create sub-group data: $data for groupId: $groupId");
      final fullResponse = await _helper.post(
        "api/groups/$groupId/sub-groups",
        data,
      );
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

  Future<bool> updateSubGroup(
    int groupId,
    int subGroupId,
    Map<String, dynamic> data,
  ) async {
    try {
      print(
        "Update sub-group data: $data groupId: $groupId subGroupId: $subGroupId",
      );
      final fullResponse = await _helper.put(
        "api/groups/$groupId/sub-groups/$subGroupId",
        data,
      );
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

  Future<bool> deleteSubGroup(int groupId, int subGroupId) async {
    print("Delete sub group");
    print("Delete sub group");
    try {
      print("Delete sub-group groupId: $groupId subGroupId: $subGroupId");
      final fullResponse = await _helper.delete(
        "api/groups/$groupId/sub-groups/$subGroupId",
      );
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
  Future<bool> createTeam(int subGroupId, Map<String, dynamic> data) async {
    try {
      print("Create team data: $data for subGroupId: $subGroupId");
      final fullResponse = await _helper.post(
        "api/sub-groups/$subGroupId/teams",
        data,
      );
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
  Future<GetTeams> getTeams(int subGroupId) async {
    try {
      print("Get teams for subGroupId: $subGroupId");
      final fullResponse = await _helper.get(
        "api/sub-groups/$subGroupId/teams",
      );
      final jsonResponse = jsonEncode(fullResponse);
      return getTeamsFromJson(jsonResponse);
    } catch (e) {
      print("Get teams failed: $e");
      rethrow;
    }
  }
  Future<bool> deleteTeam(int subGroupId, int teamId) async {
    print("delete Team");
    print("delete Team");
    try {
      print("Delete team subGroupId: $subGroupId teamId: $teamId");
      final fullResponse = await _helper.delete(
        "api/sub-groups/$subGroupId/teams/$teamId",
      );
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
  Future<bool> assignMembersToTeam(int teamId, List<int> memberIds) async {
    try {
      print("Assign members $memberIds to teamId: $teamId");
      final fullResponse = await _helper.post("api/teams/$teamId/members", {
        // "teamId": teamId,
        "memberIds": memberIds,
      });

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
      final fullResponse = await _helper.delete(
        "api/teams/$teamId/members/$memberId",
      );
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

  Future<bool> updateTeam(
    int subGroupId,
    int teamId,
    Map<String, dynamic> data,
  ) async {
    try {
      print("Update team data: $data subGroupId: $subGroupId teamId: $teamId");
      final fullResponse = await _helper.put(
        "api/sub-groups/$subGroupId/teams/$teamId",
        data,
      );
      final jsonResponse = jsonEncode(fullResponse);
      print("jsonResponse  $jsonResponse");
      if (fullResponse['success'] == true) {
        print("Update Team → ${fullResponse['message']}");
        return true;
      } else {
        print("Body says failure: ${fullResponse['message']}");
        return false;
      }
    } catch (e) {
      print("Update team failed: $e");
      return false;
    }
  }
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

  Future<bool> addPerformanceNotes({
    required String eventId,
    required String memberId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final fullResponse = await _helper.post(
        "api/events/$eventId/members/$memberId/performance",
        data,
      );
      final jsonResponse = jsonEncode(fullResponse);
      return fullResponse['success'];
    } catch (e) {
      print("Add Event failed: $e");
      return false;
    }
  }

// Replace in ClubApiService:
  Future<PerformanceNotesData> getEventsPerformanceNotes({
    required String eventId,
  }) async {
    try {
      final fullResponse = await _helper.get(
        "api/events/$eventId/performance-notes", // removed leading slash
      );
      final jsonResponse = jsonEncode(fullResponse);
      print("getEventsPerformanceNotes response: $jsonResponse");
      return PerformanceNotesData.fromJson(fullResponse);
    } catch (e) {
      print("getEventsPerformanceNotes failed: $e");
      return PerformanceNotesData.fromJson({});
    }
  }
  Future<PerformanceNotesData> getMemberPerformanceNotes({
    required String memberId,
  }) async {
    try {
      final fullResponse = await _helper.get(
        "api/events/members/$memberId/performance-notes",
      );
      return PerformanceNotesData.fromJson(fullResponse);
    } catch (e) {
      print("getMemberPerformanceNotes failed: $e");
      return PerformanceNotesData.fromJson({});
    }
  }

  Future<dynamic> markNotificationRead(int notificationId) async {
    try {
      final fullResponse = await _helper.put(
        "api/notifications/$notificationId/read",
        {},
      );
      print("Mark read response: $fullResponse");
      return fullResponse;
    } catch (e) {
      print("Mark notification read failed: $e");
      return false;
    }
  }

  Future<dynamic> markAllNotificationsRead() async {
    try {
      final fullResponse = await _helper.put("api/notifications/read-all", {});
      print("Mark all read response: $fullResponse");
      return fullResponse;
    } catch (e) {
      print("Mark all notifications read failed: $e");
      return false;
    }
  }

  Future<dynamic> getUnreadCount() async {
    try {
      final fullResponse = await _helper.get("api/notifications/unread-count");
      print("Unread count response: $fullResponse");
      return fullResponse;
    } catch (e) {
      print("Get unread count failed: $e");
      return false;
    }
  }
  Future<List<ActivityData1>> getActivities1() async {
    try {
      final response = await _helper.get("api/activities");
      print("Get activities response: $response");

      if (response != null && response is List) {
        return response.map((e) => ActivityData1.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Get activities failed: $e");
      return [];
    }
  }
  Future<NotificationData> getNotifications() async {
    try {
      final fullResponse = await _helper.get("api/notifications");
      print("Notifications response: $fullResponse");
      return NotificationData.fromJson(fullResponse);
    } catch (e) {
      print("Get notifications failed: $e");
      return NotificationData.fromJson({});
    }
  }

  Future<List<GroupData>> getAllGroups() async {
    try {
      final fullResponse = await _helper.get("api/groups");
      final jsonResponse = jsonEncode(fullResponse);
      // Parse list from data array
      final List<dynamic> data = fullResponse['data'] ?? [];
      return data.map((json) => GroupData.fromJson(json)).toList();
    } catch (e) {
      print("getAllGroups failed: $e");
      rethrow;
    }
  }

  Future<bool> createStandaloneGroup(Map<String, dynamic> data) async {
    try {
      print("CreateGroupData ${data}");
      final fullResponse = await _helper.post("api/groups", data);

      return fullResponse['success'] == true;
    } catch (e) {
      print("createStandaloneGroup failed: $e");
      return false;
    }
  }

  Future<bool> updateStandaloneGroup(int groupId, Map<String, dynamic> data) async {
    try {
      final fullResponse = await _helper.put("api/groups/$groupId", data);
      return fullResponse['success'] == true;
    } catch (e) {
      print("updateStandaloneGroup failed: $e");
      return false;
    }
  }

  Future<bool> deleteStandaloneGroup(int groupId) async {
    try {
      final fullResponse = await _helper.delete("api/groups/$groupId");
      return fullResponse['success'] == true;
    } catch (e) {
      print("deleteStandaloneGroup failed: $e");
      return false;
    }
  }
  Future<SubGroupMembers> getSubGroupMembers(int subGroupId) async {
    try {
      final fullResponse = await _helper.get("api/subgroups/$subGroupId/members");
      final jsonResponse = jsonEncode(fullResponse);
      return SubGroupMembersFromJson(jsonResponse);
    } catch (e) {
      print("getSubGroupMembers failed: $e");
      rethrow;
    }
  }

  Future<bool> addMembersToSubGroup(int subGroupId, List<int> memberIds) async {
    try {
      final fullResponse = await _helper.post("api/subgroups/$subGroupId/members", {
        "memberIds": memberIds,
      });
      return fullResponse['success'] == true;
    } catch (e) {
      print("addMembersToSubGroup failed: $e");
      return false;
    }
  }

  Future<bool> removeMemberFromSubGroup(int subGroupId, int memberId) async {
    try {
      final fullResponse = await _helper.delete("api/subgroups/$subGroupId/members/$memberId");
      return fullResponse['success'] == true;
    } catch (e) {
      print("removeMemberFromSubGroup failed: $e");
      return false;
    }
  }
  Future<bool> addMembersToGroup(int groupId, List<int> memberIds) async {
    try {
      final fullResponse = await _helper.post("api/groups/$groupId/members", {
        "groupId": groupId,
        "memberIds": memberIds,
      });
      return fullResponse['success'] == true;
    } catch (e) {
      print("addMembersToGroup failed: $e");
      return false;
    }
  }

  Future<bool> addMembersToEvent(int eventId, List<int> memberIds) async {
    try {
      print("Adding members $memberIds to event $eventId");
      final fullResponse = await _helper.post("api/events/$eventId/members", {
        "memberIds": memberIds,
      });
      final jsonResponse = jsonEncode(fullResponse);
      print("addMembersToEvent response: $jsonResponse");
      return fullResponse['success'] == true;
    } catch (e) {
      print("addMembersToEvent failed: $e");
      return false;
    }
  }
  Future<bool> updateMemberMembership(int memberId, Map<String, dynamic> data) async {
    try {
      print("updateMemberMembership memberId: $memberId data: $data");
      final fullResponse = await _helper.put("api/members/$memberId", data);
      final jsonResponse = jsonEncode(fullResponse);
      print("updateMemberMembership response: $jsonResponse");
      return fullResponse['success'] == true;
    } catch (e) {
      print("updateMemberMembership failed: $e");
      return false;
    }
  }
  Future<List<membersModel.Data>> getGroupDirectMembers(int groupId) async {
    try {
      print("getGroupDirectMembers groupId: $groupId");
      final fullResponse = await _helper.get("api/groups/$groupId/members");
      final jsonResponse = jsonEncode(fullResponse);
      print("getGroupDirectMembers response: $jsonResponse");
      final List<dynamic> data = fullResponse['data'] ?? [];
      return data.map((json) => membersModel.Data.fromJson(json)).toList();
    } catch (e) {
      print("getGroupDirectMembers failed: $e");
      rethrow;
    }
  }
  Future<GetDirectGroupMembers> getGroupDirectMembers1(int groupId) async {
    try {
      print("getGroupDirectMembers groupId: $groupId");
      final fullResponse = await _helper.get("api/groups/$groupId/members");
      final jsonResponse = jsonEncode(fullResponse);
      return GetDirectGroupMembersFromJson(jsonResponse);
    } catch (e) {
      print("getGroupDirectMembers failed1: $e");
      rethrow;
    }
  }

  /// DELETE /api/groups/{groupId}/members  body: { memberIds: [...] }
  /// Removes one or more members from a standalone group
  Future<bool> removeMembersFromGroup(int groupId, List<int> memberIds) async {
    try {
      print("removeMembersFromGroup groupId: $groupId memberIds: $memberIds");
      // The API uses DELETE with a body: { "memberIds": [...] }
      final fullResponse = await _helper.deleteWithBody(
        "api/groups/$groupId/members",
        {"memberIds": memberIds},
      );
      final jsonResponse = jsonEncode(fullResponse);
      print("removeMembersFromGroup response: $jsonResponse");
      return fullResponse['success'] == true;
    } catch (e) {
      print("removeMembersFromGroup failed: $e");
      return false;
    }
  }
  Future<List<Map<String, dynamic>>> getEventMembers(int eventId) async {
    try {
      final fullResponse = await _helper.get("api/events/$eventId/members");
      final List<dynamic> data = fullResponse['data'] ?? [];
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print("getEventMembers failed: $e");
      return [];
    }
  }
  Future<bool> updateEvent(int eventId, Map<String, dynamic> data) async {
    try {
      print("Update Events");
      print("Update Events ${data}");
;      final fullResponse = await _helper.put(
        "api/events/$eventId",
        data,
      );
      return fullResponse['success'] == true;
    } catch (e) {
      print("updateEvent failed: $e");
      return false;
    }
  }
  Future<GetEventDetails> getCompletedEvents() async {
    try {
      final fullResponse = await _helper.get("api/events/completed");
      final jsonResponse = jsonEncode(fullResponse);
      return GetEventDetailsFromJson(jsonResponse);
    } catch (e) {
      print("getCompletedEvents failed: $e");
      rethrow;
    }
  }
  Future<GetClubsData> getClubsData() async {
    try {
      final fullResponse = await _helper.get("api/club-admin/clubs");
      print("getClubs success: ${fullResponse['success']}");
      jsonEncode(fullResponse);
      return getClubsDataFromJson(fullResponse);
    } catch (e) {
      print("getClubs failed: $e");
      rethrow;
    }
  }
}

class CoachApiService {
  CoachApiService();

  void initApiService(GlobalKey<NavigatorState> navigatorKey) {}

  // initApiService(GlobalKey<NavigatorState> navigatorKey) {
  //   _navigatorKey = navigatorKey;
  // }

  final ApiBaseHelper _helper = ApiBaseHelper();

  Future<MemberProfileData> getCouchProfile() async {
    try {
      final fullResponse = await _helper.get("api/profile");
      print("getMemberEvents success: ${fullResponse['success']}");
      jsonEncode(fullResponse);
      return profileDataFromJson(fullResponse);
    } catch (e) {
      print("getMemberEvents failed: $e");
      rethrow;
    }
  }

  Future<List<Club>> getCoachClubs() async {
    try {
      print("Fetching coach clubs...");
      final fullResponse = await _helper.get("api/coach/clubs");
      print("getCoachClubs response: $fullResponse");

      if (fullResponse['success'] == true) {
        final List<dynamic> clubsData = fullResponse['data'];
        return clubsData.map((json) => Club.fromJson(json)).toList();
      } else {
        print("Failed to fetch clubs: ${fullResponse['message']}");
        return [];
      }
    } catch (e) {
      print("getCoachClubs failed: $e");
      return []; // Return empty list on error
    }
  }

  Future<CoachDashboardData> getCoachDashboard(int clubId) async {
    try {
      print("Fetching coach dashboard for club: $clubId");
      final fullResponse = await _helper.get("api/dashboard/coach/$clubId");
      print("getCoachDashboard raw response: $fullResponse");

      if (fullResponse['success'] == true && fullResponse['data'] != null) {
        final data = Map<String, dynamic>.from(fullResponse['data']);
        return CoachDashboardData.fromJson(data);
      } else {
        print("Dashboard API failure: ${fullResponse['message']}");
        return CoachDashboardData.empty();
      }
    } catch (e) {
      print("getCoachDashboard failed: $e");
      return CoachDashboardData.empty();
    }
  }

  Future<List<ClubMember>> getClubMembers(int clubId) async {
    try {
      print("Fetching members for club: $clubId");
      final fullResponse = await _helper.get("api/members?clubId=$clubId");
      print("getClubMembers response: $fullResponse");

      if (fullResponse['success'] == true) {
        final List<dynamic> membersData = fullResponse['data'];
        return membersData.map((json) => ClubMember.fromJson(json)).toList();
      } else {
        print("Failed to fetch members: ${fullResponse['message']}");
        return [];
      }
    } catch (e) {
      print("getClubMembers failed: $e");
      return [];
    }
  }

  Future<List<CoachEventModel>> getAllEvents() async {
    try {
      print("Fetching all events...");
      final fullResponse = await _helper.get("api/events");
      print("getAllEvents response: $fullResponse");

      if (fullResponse['success'] == true) {
        final List<dynamic> eventsData = fullResponse['data'];
        return eventsData
            .map((json) => CoachEventModel.fromJson(json))
            .toList();
      } else {
        print("Failed to fetch events: ${fullResponse['message']}");
        return [];
      }
    } catch (e) {
      print("getAllEvents failed: $e");
      return [];
    }
  }

  Future<int> createEvent(Map<String, dynamic> eventData) async {
    try {
      print("Creating event with data: $eventData");
      final fullResponse = await _helper.post("api/events", eventData);
      print("createEvent response: $fullResponse");

      if (fullResponse['success'] == true) {
        // Extract eventId from response data
        if (fullResponse['data'] != null &&
            fullResponse['data']['eventId'] != null) {
          return fullResponse['data']['eventId'] as int;
        }
        return 0; // Success but no ID returned
      } else {
        print("Failed to create event: ${fullResponse['message']}");
        return -1;
      }
    } catch (e) {
      print("createEvent failed: $e");
      return -1;
    }
  }

  Future<bool> updateEvent(
    int clubId,
    int eventId,
    Map<String, dynamic> eventData,
  ) async {
    try {
      print("Updating event: $eventId for club: $clubId with data: $eventData");
      // Note: Using ?clubId=$clubId in the URL as per your API
      final fullResponse = await _helper.put(
        "api/events/$eventId?clubId=$clubId",
        eventData,
      );
      print("updateEvent response: $fullResponse");

      if (fullResponse['success'] == true) {
        print("Event updated successfully");
        return true;
      } else {
        print("Failed to update event: ${fullResponse['message']}");
        return false;
      }
    } catch (e) {
      print("updateEvent failed: $e");
      return false;
    }
  }

  Future<CoachEventModel?> getEventDetails(int clubId, int eventId) async {
    try {
      print("Fetching event details: $eventId for club: $clubId");
      final fullResponse = await _helper.get(
        "api/events/$eventId?clubId=$clubId",
      );
      print("getEventDetails response: $fullResponse");

      if (fullResponse['success'] == true && fullResponse['data'] != null) {
        return CoachEventModel.fromJson(fullResponse['data']);
      } else {
        print("Failed to fetch event details: ${fullResponse['message']}");
        return null;
      }
    } catch (e) {
      print("getEventDetails failed: $e");
      return null;
    }
  }

  Future<List<CoachEventModel>> getClubEvents(int clubId) async {
    try {
      print("Fetching events for club: $clubId");
      final fullResponse = await _helper.get("api/events?clubId=$clubId");
      print("getClubEvents response: $fullResponse");

      if (fullResponse['success'] == true && fullResponse['data'] != null) {
        final List<dynamic> eventsData = fullResponse['data'];
        return eventsData
            .map((json) => CoachEventModel.fromJson(json))
            .toList();
      } else {
        print("Failed to fetch events: ${fullResponse['message']}");
        return [];
      }
    } catch (e) {
      print("getClubEvents failed: $e");
      return [];
    }
  }

  Future<ClubMember?> getMemberDetails(int clubId, int memberId) async {
    try {
      print("Fetching member details: $memberId for club: $clubId");
      // Note: API might expect memberId directly without clubId in URL
      final fullResponse = await _helper.get("api/members/$memberId");
      print("getMemberDetails response: $fullResponse");

      if (fullResponse['success'] == true && fullResponse['data'] != null) {
        return ClubMember.fromJson(fullResponse['data']);
      } else {
        print("Failed to fetch member details: ${fullResponse['message']}");
        return null;
      }
    } catch (e) {
      print("getMemberDetails failed: $e");
      return null;
    }
  }

  Future<GroupMembersData> getGroupMember(String groupId) async {
    try {
      final fullResponse = await _helper.get("api/groups/$groupId/members");
      print("getMemberEvents success: ${fullResponse}");
      jsonEncode(fullResponse);
      return groupMembersDataFromJson(fullResponse);
    } catch (e) {
      print("getMemberEvents failed: $e");
      rethrow;
    }
  }

  Future<EventAttendanceData> getEventAttendance(String eventId) async {
    try {
      final fullResponse = await _helper.get("api/events/$eventId/attendance");
      print("getMemberEvents success: ${fullResponse}");
      jsonEncode(fullResponse);
      return eventAttendanceDataFromJson(fullResponse);
    } catch (e) {
      print("getMemberEvents failed: $e");
      rethrow;
    }
  }

  Future<EventAttendanceData> saveAttendance(
    final eventId,
    dynamic payload,
  ) async {
    print(payload);
    print(eventId);
    try {
      final fullResponse = await _helper.post(
        "api/events/$eventId/attendance",
        payload,
      );
      print("getMemberEvents success: ${fullResponse['success']}");
      jsonEncode(fullResponse);
      return eventAttendanceDataFromJson(fullResponse);
    } catch (e) {
      print("getMemberEvents failed: $e");
      rethrow;
    }
  }
  // Add after getClubEvents()
  Future<GetEventDetails> getCoachScheduledEvents() async {
    try {
      final fullResponse = await _helper.get("api/coach/events");
      final jsonResponse = jsonEncode(fullResponse);
      return GetEventDetailsFromJson(jsonResponse);
    } catch (e) {
      print("getCoachScheduledEvents failed: $e");
      rethrow;
    }
  }

  Future<GetEventDetails> getCoachCompletedEvents() async {
    try {
      final fullResponse = await _helper.get("api/coach/events/completed");
      final jsonResponse = jsonEncode(fullResponse);
      return GetEventDetailsFromJson(jsonResponse);
    } catch (e) {
      print("getCoachCompletedEvents failed: $e");
      rethrow;
    }
  }
}

class ParentApiService {
  ParentApiService();

  void initApiService(GlobalKey<NavigatorState> navigatorKey) {}

  // initApiService(GlobalKey<NavigatorState> navigatorKey) {
  //   _navigatorKey = navigatorKey;
  // }

  final ApiBaseHelper _helper = ApiBaseHelper();

  Future<GetYourMember> getYourMembers() async {
    try {
      final myId = SharedPreferenceHelper.getId();
      print("Guardian userId from SharedPrefs: $myId");

      final fullResponse = await _helper.get("api/guardians/members");
      print("getYourMembers response: $fullResponse");
      print("getYourMembers success: ${fullResponse['success']}");
      print("getYourMembers data: ${fullResponse['data']}");

      final jsonResponse = jsonEncode(fullResponse);
      return GetYourMemberFromJson(jsonResponse);
    } catch (e) {
      print("getYourMembers failed: $e");
      rethrow;
    }
  }

  Future<MemberProfileData> getParentProfile() async {
    try {
      final fullResponse = await _helper.get("api/profile");
      print("getMemberEvents success: ${fullResponse['success']}");
      jsonEncode(fullResponse);
      return profileDataFromJson(fullResponse);
    } catch (e) {
      print("getMemberEvents failed: $e");
      rethrow;
    }
  }
// ─────────────────────────────────────────────────────────────────────────────
// ADD THESE METHODS TO ParentApiService in api_service.dart
// ─────────────────────────────────────────────────────────────────────────────

  /// GET /api/guardian/events/{memberId}
  /// Get all events for a member (Guardian only)
  Future<dynamic> getGuardianMemberEvents(int memberId) async {
    try {
      print("getGuardianMemberEvents memberId: $memberId");
      final fullResponse = await _helper.get("api/guardian/events/$memberId");
      print("getGuardianMemberEvents response: $fullResponse");
      // Return the data array directly
      return fullResponse['data'];
    } catch (e) {
      print("getGuardianMemberEvents failed: $e");
      rethrow;
    }
  }

  Future<GuardianDashboardData> getGuardianDashboard({int? memberId}) async {
    try {
      final url =
          "api/dashboard/guardian?memberId=$memberId";
      print("getGuardianDashboard url: $url");
      final fullResponse = await _helper.get(url);
      print("getGuardianDashboard response: $fullResponse");
      return guardianDashboardDataFromJson(fullResponse);
    } catch (e) {
      print("getGuardianDashboard failed: $e");
      rethrow;
    }
  }
// ─────────────────────────────────────────────────────────────────────────────
// ADD THIS METHOD TO MemberApiService in api_service.dart
// ─────────────────────────────────────────────────────────────────────────────

  /// GET /api/members/{memberId}/metrics
  /// Get metrics for a specific member by ID (Guardian & Admin access)

  // Future<GetYourMember> getYourMembers() async {
  //   try {
  //     final myId = SharedPreferenceHelper.getId();
  //     print("Guardian userId from SharedPrefs: $myId");
  //     final fullResponse = await _helper.get("api/members/$myId/members");
  //     print("getYourMembers response: $fullResponse");
  //     print("getYourMembers success: ${fullResponse['success']}");
  //     print("getYourMembers data: ${fullResponse['data']}");
  //     final jsonResponse = jsonEncode(fullResponse);
  //     return GetYourMemberFromJson(jsonResponse);
  //   } catch (e) {
  //     print("getYourMembers failed: $e");
  //     rethrow;
  //   }
  // }
  Future<GetGuardianEvents> getGuardianPendingEvents(int memberId) async {
    try {
      print("getGuardianPendingEvents memberId: $memberId");
      final fullResponse = await _helper.get(
        "api/guardian/events/pending/$memberId",
      );
      print("getGuardianPendingEvents response: $fullResponse");
      final jsonResponse = jsonEncode(fullResponse);
      return getGuardianEventsFromJson(jsonResponse);
    } catch (e) {
      print("getGuardianPendingEvents failed: $e");
      rethrow;
    }
  }

  /// PUT /api/guardian/events/status — Accept or Reject event for a child
  /// status values: "ACCEPT" or "REJECT"
  Future<bool> updateGuardianEventStatus(
    int memberId,
    int eventId,
    String status,
  ) async {
    try {
      print(
        "updateGuardianEventStatus memberId: $memberId eventId: $eventId status: $status",
      );
      final fullResponse = await _helper.put("api/guardian/events/status", {
        "memberId": memberId,
        "eventId": eventId,
        "status": status,
      });
      print("updateGuardianEventStatus response: $fullResponse");
      if (fullResponse['success'] == true) {
        print("Update guardian status success → ${fullResponse['message']}");
        return true;
      } else {
        print("Update guardian status failure: ${fullResponse['message']}");
        return false;
      }
    } catch (e) {
      print("updateGuardianEventStatus failed: $e");
      return false;
    }
  }
}

class MemberApiService {
  MemberApiService();

  void initApiService(GlobalKey<NavigatorState> navigatorKey) {}

  // initApiService(GlobalKey<NavigatorState> navigatorKey) {
  //   _navigatorKey = navigatorKey;
  // }

  final ApiBaseHelper _helper = ApiBaseHelper();
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
  Future<GetMetrics> getMetrics() async {
    try {
      final fullResponse = await _helper.get("api/members/metrics");
      print("getMemberEvents success: ${fullResponse['success']}");
      final jsonResponse = jsonEncode(fullResponse);
      return getMemberMetricsFromJson(jsonResponse);
    } catch (e) {
      print("getMemberEvents failed: $e");
      rethrow;
    }
  }
  Future<GetMemberDashboard> getMemberDashboard(int clubId) async {
    try {
      print("Fetching member dashboard for club: $clubId");
      final fullResponse = await _helper.get("api/dashboard/member/$clubId");
      print("getMemberDashboard raw response: $fullResponse");

      if (fullResponse['success'] == true && fullResponse['data'] != null) {
        final data = Map<String, dynamic>.from(fullResponse);
        return GetMemberDashboard.fromJson(data);
      } else {
        print("Dashboard API failure: ${fullResponse['message']}");
        return GetMemberDashboard.empty();
      }
    } catch (e) {
      print("getMemberDashboard failed: $e");
      return GetMemberDashboard.empty();
    }
  }
  Future<GetMetrics> getMemberMetricsById(int memberId) async {
    try {
      print("getMemberMetricsById memberId: $memberId");
      final fullResponse = await _helper.get("api/members/$memberId/metrics");
      print("getMemberMetricsById success: ${fullResponse['success']}");
      final jsonResponse = jsonEncode(fullResponse);
      return getMemberMetricsFromJson(jsonResponse);
    } catch (e) {
      print("getMemberMetricsById failed: $e");
      rethrow;
    }
  }

  Future<MemberProfileData> getMemberProfile() async {
    try {
      final fullResponse = await _helper.get("api/profile");
      print("getMemberEvents success: ${fullResponse['success']}");
      jsonEncode(fullResponse);
      return profileDataFromJson(fullResponse);
    } catch (e) {
      print("getMemberEvents failed: $e");
      rethrow;
    }
  }

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

  Future<bool> updateMemberEventStatus(int eventId, String status) async {
    try {
      print("updateMemberEventStatus eventId: $eventId status: $status");
      final fullResponse = await _helper.put("api/member/events/status", {
        "eventId": eventId,
        "status": "$status",
      });
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

  Future<dynamic> updateProfile(dynamic payload) async {
    try {
      print(jsonEncode(payload));
      final fullResponse = await _helper.put("api/profile", payload);
      print("Profile update response: $fullResponse");
      return fullResponse;
    } catch (e) {
      print("Profile update failed: $e");
      return false;
    }
  }

  Future<GetGuardianForMembers> getMembersGuardian({int? memberId}) async {
    try {
      final url =
          "api/members/guardians";
      print("getMembersGuardian url: $url");
      final fullResponse = await _helper.get(url);
      print("getMembersGuardian response: $fullResponse");
      return getGuardianForMembersFromJson(fullResponse);
    } catch (e) {
      print("getMembersGuardian failed: $e");
      rethrow;
    }
  }
  Future<GetClubsData> getClubsDataForMember() async {
    try {
      final fullResponse = await _helper.get("api/member/clubs");
      print("getClubsMember success: ${fullResponse['success']}");
      jsonEncode(fullResponse);
      return getClubsDataFromJson(fullResponse);
    } catch (e) {
      print("getClubsMember failed: $e");
      rethrow;
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
