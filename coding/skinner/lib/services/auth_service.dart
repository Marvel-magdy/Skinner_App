import 'package:dio/dio.dart';
import 'dart:io';

String? adminToken;
class AuthService {
  

  final Dio dio = Dio(

    BaseOptions(

      baseUrl: 'http://187.127.227.63',

      headers: {
        'Content-Type': 'application/json',
      },

    ),
  );

  Future<Response> login({

  required String email,
  required String password,
  required String role,

}) async {

  Response response = await dio.post(

    '/api/auth/login',

    data: {

      "role": role,
      "email": email,
      "password": password,

    },

  );

  adminToken = response.data["token"];

  print(adminToken);

  return response;
}

Future<Response> registerDoctor({

  required String name,
  required String email,
  required String password,
  required String phone,
  required String specialization,
  required String clinicAddress,
  required String yearsOfExperience,
  required File syndicateCardImage,

}) async {

  FormData formData = FormData.fromMap({

    "name": name,

    "email": email,

    "password": password,

    "phone": phone,

    "specialization": specialization,

    "clinic_address": clinicAddress,

    "year_of_experience":
        int.tryParse(yearsOfExperience) ?? 0,

    "medical_syndicate_id_card":
        "123456",

    "gender": "male",

    "consultation_fee": 100,

    "syndicate_card_image":
        await MultipartFile.fromFile(
      syndicateCardImage.path,
    ),
  });

  return await dio.post(

    '/api/auth/register-doctor',

    data: formData,

  );
}Future<Response> registerPatient({

  required String name,
  required String email,
  required String password,
  required String phone,
  required String address,
  required String age,

}) async {

  return await dio.post(

    '/api/auth/register-patient',

    data: {

      "name": name,

      "phone": phone,

      "gender": "male",

      "email": email,

      "password": password,

      "age": int.tryParse(age) ?? 0,

      "address": address,

    },
  );
}
Future<Response> registerAdmin({

  required String email,
  required String password,
  required String inviteCode,

}) async {

  return await dio.post(

    '/api/auth/register-admin',

    data: {

      "email": email,

      "password": password,

      "invite_code": inviteCode,

    },
  );
}
Future<Response> forgotPassword({

  required String email,

}) async {

  return await dio.post(

    '/api/auth/forgot-password',

    data: {

      "email": email,

    },
  );
}Future<Response> resetPassword({

  required String email,
  required String otp,
  required String newPassword,

}) async {

  return await dio.post(

    '/api/auth/reset-password',

    data: {

      "email": email,

      "otp": otp,

      "new_password": newPassword,

    },

  );
}

Future<Response> getPendingDoctors({
  required String token,
}) async {

  return await dio.get(

    '/api/admin/pending-doctors',

    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );
}
Future<Response> approveDoctor({

  required String token,
  required String medicalId,

}) async {

  return await dio.post(

    '/api/admin/approve-doctor',

    data: {
      "medical_syndicate_id_card": medicalId,
    },

    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );
}
Future<Response> rejectDoctor({

  required String token,
  required String medicalId,

}) async {

  return await dio.post(

    '/api/admin/reject-doctor',

    data: {
      "medical_syndicate_id_card": medicalId,
    },

    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );
}
Future<Response> getReports({

  required String token,

}) async {

  return await dio.get(

    '/api/admin/reports',

    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );
}
Future<Response> generateAdminCode({

  required String token,

}) async {

  return await dio.post(

    '/api/admin/generate-admin-code',

    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );
}
Future<Response> getPendingCases({

  required String token,

}) async {

  return await dio.get(

    '/api/doctor/pending-cases',

    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );
}
Future<Response> getReviewedCases({

  required String token,

}) async {

  return await dio.get(

    '/api/doctor/reviewed-cases',

    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );
}
Future<Response> reviewCase({

  required String token,
  required String appointmentId,
  required String diagnosis,
  required String prescription,
  required String notes,

}) async {

  return await dio.post(

    '/api/doctor/review-case',

    data: {

      "appointment_id": appointmentId,

      "diagnosis": diagnosis,

      "prescription": prescription,

      "notes": notes,

    },

    options: Options(

      headers: {

        "Authorization": "Bearer $token",

      },

    ),

  );
}
Future<Response> getAvailability({

  required String token,
  required String startDate,
  required String endDate,

}) async {

  return await dio.get(

    '/api/doctor/date-availability',

    queryParameters: {

      "start_date": startDate,
      "end_date": endDate,

    },

    options: Options(

      headers: {

        "Authorization": "Bearer $token",

      },

    ),
  );
}

Future<Response> setAvailability({

  required String token,
  required String date,
  required String startTime,
  required String endTime,

}) async {

  return await dio.put(

    '/api/doctor/date-availability',

    data: {

      "date": date,

      "slots": [

        {

          "start_time": startTime,
          "end_time": endTime,

        }

      ]

    },

    options: Options(

      headers: {

        "Authorization": "Bearer $token",

      },

    ),
  );
}

Future<Response> deleteAvailability({

  required String token,
  required String date,

}) async {

  return await dio.delete(

    '/api/doctor/date-availability/$date',

    options: Options(

      headers: {

        "Authorization": "Bearer $token",

      },

    ),
  );
}
}