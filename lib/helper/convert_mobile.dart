String convertMobile(String mobile) {
  if (mobile.length == 11) {
    return mobile.replaceAllMapped(
        RegExp(r'(\d{3})(\d{4})(\d+)'), (Match m) => "${m[1]}-${m[2]}-${m[3]}");
  }
  if (mobile.length == 10) {
    return mobile.replaceAllMapped(
        RegExp(r'(\d{3})(\d{3})(\d+)'), (Match m) => "${m[1]}-${m[2]}-${m[3]}");
  }
  return mobile;
}
