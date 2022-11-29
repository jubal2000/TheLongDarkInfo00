import 'package:get/get.dart';

class UserModel {
  String memberCode;
  String memberName;
  String birthday;
  String mobile;
  String email;
  String walletAddress;
  Rx<String?> profile;
  Rx<String?> recommenderCode;
  String? files;
// {membercode: RA57T5, membername: 한진희, birthday: 19880412, sex: null, mobile: 01072240578, email: hanzinhee@gmail.com, walletaddress: 0xc36b7e24a321dad03d143748e6800095b255c2df, profile: null, recommendercode: ASDFGH, files: null}
  UserModel({
    required this.memberCode,
    required this.memberName,
    required this.birthday,
    required this.mobile,
    required this.email,
    required this.walletAddress,
    required this.profile,
    required this.recommenderCode,
    required this.files,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? profile = json['profile'];
    String? recommenderCode;
    //recommendercode 가 빈문자열일 경우 null로 정의
    if (json['recommendercode'] != null) {
      if (json['recommendercode'].isEmpty) {
        recommenderCode = null;
      } else {
        recommenderCode = json['recommendercode'];
      }
    }
    return UserModel(
      memberCode: json['membercode'],
      memberName: json['membername'],
      birthday: json['birthday'],
      mobile: json['mobile'],
      email: json['email'],
      walletAddress: json['walletaddress'],
      profile: profile.obs,
      recommenderCode: recommenderCode.obs,
      files: json['files'],
    );
  }
}
