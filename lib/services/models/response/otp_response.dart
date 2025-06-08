class OtpResponse {
  final String message;
  final String token;

  OtpResponse({required this.message, required this.token});

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      message: json['message'],
      token: json['token'],
    );
  }
}
