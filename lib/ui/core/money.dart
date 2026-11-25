String formatMoney(int amountMinor) {
  final major = amountMinor ~/ 100;
  final minor = (amountMinor % 100).toString().padLeft(2, '0');
  return 'RM $major.$minor';
}
