class ValidationUtils {
  // Validate non-empty field
  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Validate numeric field
  static String? validateNumeric(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Empty is allowed unless combined with required validation
    }
    if (double.tryParse(value.replaceAll(',', '')) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  // Validate positive number
  static String? validatePositiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Empty is allowed unless combined with required validation
    }
    final number = double.tryParse(value.replaceAll(',', ''));
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number < 0) {
      return 'Please enter a positive number';
    }
    return null;
  }

  // Validate integer
  static String? validateInteger(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Empty is allowed unless combined with required validation
    }
    if (int.tryParse(value) == null) {
      return 'Please enter a valid integer';
    }
    return null;
  }

  // Validate PIN
  static String? validatePin(String? value, {int minLength = 4, int maxLength = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'PIN is required';
    }
    if (value.length < minLength) {
      return 'PIN must be at least $minLength digits';
    }
    if (value.length > maxLength) {
      return 'PIN must be at most $maxLength digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'PIN must contain only digits';
    }
    return null;
  }

  // Validate name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }

  // Combined validation
  static String? validateRequiredNumeric(String? value) {
    final requiredValidation = validateRequired(value);
    if (requiredValidation != null) {
      return requiredValidation;
    }
    return validateNumeric(value);
  }

  // Combined validation for required positive number
  static String? validateRequiredPositiveNumber(String? value) {
    final requiredValidation = validateRequired(value);
    if (requiredValidation != null) {
      return requiredValidation;
    }
    return validatePositiveNumber(value);
  }
}
