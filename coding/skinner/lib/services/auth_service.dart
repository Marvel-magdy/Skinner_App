import 'package:dio/dio.dart';

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
}