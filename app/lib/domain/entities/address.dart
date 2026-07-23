class Address {
  const Address({
    required this.addressType,
    required this.line1,
    required this.town,
    required this.postcode,
    this.line2,
    this.line3,
    this.line4,
    this.county,
  });

  final String addressType;
  final String line1;
  final String? line2;
  final String? line3;
  final String? line4;
  final String town;
  final String? county;
  final String postcode;
}
