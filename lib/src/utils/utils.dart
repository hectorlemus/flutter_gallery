bool isNumeric(final String value) {
  if (value == null || value.isEmpty) {
    return false;
  }

  return num.tryParse(value) != null;
}
