import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:soft_support_decktop/constants/string.dart';
import 'package:logger/logger.dart';

import 'package:retrofit/http.dart';
import 'package:soft_support_decktop/models/attendances.dart';
import 'APIs.dart';
import 'dio_client.dart';
import 'ui_models/attendance_ui_data.dart';
import 'ui_models/res_partner_ui_data.dart';
import 'ui_models/time_ui_data.dart';
part 'api_client.g.dart';

final Logger logger = Logger();

@RestApi(
  baseUrl: Strings.baseUrl,
)
abstract class APIClient {
  factory APIClient() {
    final dio = DioClient.getDioClient();

    return _APIClient(dio, errorLogger: ParseErrorLogger());
  }

  // Exemples d'appels API à implémenter

  @GET(API.GET_REST_PARTNER)
  Future<ResPartnerUiData> getAllPartner();

  @GET(API.GET_REST_ATTENDANCE)
  Future<AttendanceUiData> getLastAttendences();

  @GET(API.GET_TIME_PARAMETER)
  Future<TimeUiData> getTimes();

  //  |------------------------------
  //  |
  //  | post requests
  //  |
  //  |------------------------------

  @POST(API.POST_ATTENDANCE)
  Future<AttendanceResponses> insertTime(@Body() Map<String, dynamic> timeData);

  @POST(API.LOGIN_API)
  Future<LoginResponse> login(
    @Field("login") String email,
    @Field("password") String password,
    @Field("db") String database,
  );
}

class ParseErrorLogger {
  void logError(Object error, StackTrace stackTrace, RequestOptions options) {
    // Logique pour enregistrer les erreurs
    EasyLoading.showError('Failed with Error $error');

    if (kDebugMode) {
      print('Error occurred: $error');
      print('StackTrace: $stackTrace');
      print('RequestOptions: ${options.path}');
    }
  }
}
