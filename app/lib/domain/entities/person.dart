class Person {
  const Person({
    required this.firstNames,
    required this.lastName,
    this.title,
    this.dateOfBirth,
  });

  final String? title;
  final String firstNames;
  final String lastName;
  final DateTime? dateOfBirth;
}
