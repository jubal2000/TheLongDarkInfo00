String? converteInOutType(String inOutType) {
  const Map<String, String> index = {
    'ALL': '전체',
    'DEPOSIT': '입금',
    'SEND': '송금',
    'PAYS': '충전',
  };
  return index[inOutType];
}
