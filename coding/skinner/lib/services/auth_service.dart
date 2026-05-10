import 'package:dio/dio.dart';
import 'dart:io';

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

    return await dio.post(

      '/api/auth/login',

      data: {

        "role": role,
        "email": email,
        "password": password,

      },

    );
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

    '/api/auth/register/doctor',

    data: formData,

  );
}}