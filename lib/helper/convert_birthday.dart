String convertBirthDay(String birthDay) {
  return birthDay.substring(0, 4) +
      '-' +
      birthDay.substring(4, 6) +
      '-' +
      birthDay.substring(6, 8);
}
