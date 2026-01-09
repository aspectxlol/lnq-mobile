/// Utility for formatting Indonesian Rupiah (IDR) currency.
String formatIdr(int amount) {
  if (amount == 0) return 'Rp 0';
  final s = amount.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return 'Rp $buffer';
}
