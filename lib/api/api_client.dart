import 'package:dio/dio.dart';
import 'package:soft_support_decktop/constants/string.dart';

import 'package:retrofit/http.dart';
import 'APIs.dart';
import 'dio_client.dart';
import 'ui_models/res_partner_ui_data.dart';
part 'api_client.g.dart';

@RestApi(baseUrl: Strings.baseUrl)
abstract class APIClient {
  factory APIClient() {
    final dio = DioClient.getDioClient();

    return _APIClient(dio);
  }

  // Exemples d'appels API à implémenter

  @GET(API.GET_REST_PARTNER)
  Future<ResPartnerUiData> getAllPartner();

  @GET(API.GET_REST_ATTENDANCE)
  Future<dynamic> getLastAttendences();

  @GET(API.GET_TIME_PARAMETER)
  Future<dynamic> getTimes();

  //  |------------------------------
  //  |
  //  | user requests
  //  |
  //  |------------------------------
}
