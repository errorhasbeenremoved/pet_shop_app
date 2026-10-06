String? requiredText(
  String? value, [
  String label = 'Поле',
]) {
  if (value == null || value.trim().isEmpty) {
    return '$label обязательно';
  }

  return null;
}

String? textLength(
  String? value, {
  required String label,
  int min = 2,
  int max = 120,
}) {
  final required = requiredText(
    value,
    label,
  );

  if (required != null) {
    return required;
  }

  final length = value!.trim().length;

  if (length < min) {
    return '$label: минимум $min символа';
  }

  if (length > max) {
    return '$label: максимум $max символов';
  }

  return null;
}

String? emailValidator(
  String? value,
) {
  final required =
      requiredText(value, 'Email');

  if (required != null) {
    return required;
  }

  if (!RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
  ).hasMatch(value!.trim())) {
    return 'Некорректный формат email';
  }

  return null;
}

String? positiveInt(
  String? value, {
  required String label,
}) {
  final required =
      requiredText(value, label);

  if (required != null) {
    return required;
  }

  final number =
      int.tryParse(value!.trim());

  if (number == null || number <= 0) {
    return '$label должно быть положительным целым числом';
  }

  return null;
}

String? nonNegativeInt(
  String? value, {
  required String label,
}) {
  final required =
      requiredText(value, label);

  if (required != null) {
    return required;
  }

  final number =
      int.tryParse(value!.trim());

  if (number == null || number < 0) {
    return '$label должно быть неотрицательным целым числом';
  }

  return null;
}

String? positiveDouble(
  String? value, {
  required String label,
}) {
  final required =
      requiredText(value, label);

  if (required != null) {
    return required;
  }

  final number = double.tryParse(
    value!.replaceAll(',', '.').trim(),
  );

  if (number == null || number <= 0) {
    return '$label должно быть положительным числом';
  }

  return null;
}

String? phoneValidator(
  String? value,
) {
  final required =
      requiredText(value, 'Телефон');

  if (required != null) {
    return required;
  }

  if (!RegExp(
    r'^\+?[0-9 ()-]{7,20}$',
  ).hasMatch(value!.trim())) {
    return 'Некорректный телефон';
  }

  return null;
}

String? selectionRequired(
  List<int>? value, {
  required String label,
}) {
  if (value == null || value.isEmpty) {
    return '$label: выберите хотя бы одно значение';
  }

  return null;
}