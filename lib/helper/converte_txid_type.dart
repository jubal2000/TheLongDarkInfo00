String? converteTxIdType(int txIdType) {
  const Map<int, String> index = {
    0: '처리중',
    1: '성공',
    2: '실패',
  };
  return index[txIdType];
}
