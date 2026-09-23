class ValidationUtils {
  /// Required field check. Cannot be blank or empty spaces.
  static String? validateRequired(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  /// Min character length check.
  static String? validateMinLength(String? value, int minLength, [String fieldName = 'Field']) {
    final requiredError = validateRequired(value, fieldName);
    if (requiredError != null) return requiredError;

    final trimmedValue = value!.trim();
    if (trimmedValue.length < minLength) {
      return '$fieldName must be at least $minLength characters.';
    }
    return null;
  }

  /// Max character length check.
  static String? validateMaxLength(String? value, int maxLength, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters.';
    }
    return null;
  }

  /// Name field validation:
  /// - Cannot be blank
  /// - Must be at least 2 characters (rejects single-character names)
  /// - Cannot exceed 50 characters
  /// - Should not contain digits or invalid special symbols
  static String? validateName(String? value, [String fieldName = 'Name']) {
    final requiredError = validateRequired(value, fieldName);
    if (requiredError != null) return requiredError;

    final trimmedValue = value!.trim();
    if (trimmedValue.length < 2) {
      return '$fieldName must be at least 2 characters long.';
    }

    if (trimmedValue.length > 50) {
      return '$fieldName cannot exceed 50 characters.';
    }

    // Name should not contain numbers
    if (RegExp(r'[0-9]').hasMatch(trimmedValue)) {
      return '$fieldName should only contain letters, spaces, or hyphens.';
    }

    // Name should only contain letters, spaces, hyphens, and apostrophes
    if (!RegExp(r"^[a-zA-Z\s\-\'\.]+$").hasMatch(trimmedValue)) {
      return 'Please enter a valid $fieldName.';
    }

    return null;
  }

  /// Email validation: standard RFC 5322 regex format.
  static String? validateEmail(String? value) {
    final requiredError = validateRequired(value, 'Email address');
    if (requiredError != null) return requiredError;

    final trimmedValue = value!.trim();
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid email address (e.g. user@example.com).';
    }

    return null;
  }

  /// Password validation:
  /// - Minimum 8 characters
  /// - Maximum 64 characters
  /// - At least one uppercase letter
  /// - At least one number
  /// - At least one special character
  static String? validatePassword(String? value) {
    final requiredError = validateRequired(value, 'Password');
    if (requiredError != null) return requiredError;

    final trimmedValue = value!.trim();
    if (trimmedValue.length < 8) {
      return 'Password must be at least 8 characters long.';
    }

    if (trimmedValue.length > 64) {
      return 'Password cannot exceed 64 characters.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(trimmedValue)) {
      return 'Password must contain at least one uppercase letter (A-Z).';
    }

    if (!RegExp(r'[0-9]').hasMatch(trimmedValue)) {
      return 'Password must contain at least one number (0-9).';
    }

    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(trimmedValue)) {
      return 'Password must contain at least one special character (!@#\$...).';
    }

    return null;
  }

  /// Contact phone number validation (Philippine mobile format):
  /// - Accepts 09XXXXXXXXX (11 digits) or +639XXXXXXXXX (13 chars)
  static String? validatePhone(String? value) {
    final requiredError = validateRequired(value, 'Phone number');
    if (requiredError != null) return requiredError;

    final trimmedValue = value!.trim();
    final phoneRegex = RegExp(r'^(09|\+639)\d{9}$');

    if (!phoneRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid 11-digit PH mobile number (e.g. 09123456789).';
    }

    return null;
  }

  /// Numeric range & format validation (for prices, costs, amounts).
  static String? validateNumber(
    String? value, {
    String fieldName = 'Amount',
    double? min,
    double? max,
    bool allowEmpty = false,
  }) {
    if (allowEmpty && (value == null || value.trim().isEmpty)) return null;

    final requiredError = validateRequired(value, fieldName);
    if (requiredError != null) return requiredError;

    final trimmed = value!.trim();
    final number = double.tryParse(trimmed);
    if (number == null) {
      return '$fieldName must be a valid numeric value.';
    }

    if (min != null && number < min) {
      return '$fieldName cannot be less than ₱${min.toStringAsFixed(2)}.';
    }

    if (max != null && number > max) {
      return '$fieldName cannot exceed ₱${max.toStringAsFixed(2)}.';
    }

    return null;
  }

  /// Positive price / currency validator (e.g. retail price, COGS).
  static String? validatePrice(
    String? value, {
    String fieldName = 'Price',
    double min = 0.01,
    double max = 100000.0,
    bool allowZero = false,
  }) {
    final requiredError = validateRequired(value, fieldName);
    if (requiredError != null) return requiredError;

    final trimmed = value!.trim();
    final parsed = double.tryParse(trimmed);
    if (parsed == null) {
      return '$fieldName must be a valid price (e.g. 150.00).';
    }

    if (allowZero && parsed == 0) return null;

    if (parsed < min) {
      return '$fieldName must be at least ₱${min.toStringAsFixed(2)}.';
    }

    if (parsed > max) {
      return '$fieldName cannot exceed ₱${max.toStringAsFixed(2)}.';
    }

    return null;
  }

  /// Integer / quantity validator (e.g. stock count, items).
  static String? validateQuantity(
    String? value, {
    String fieldName = 'Quantity',
    int min = 1,
    int max = 99999,
  }) {
    final requiredError = validateRequired(value, fieldName);
    if (requiredError != null) return requiredError;

    final trimmed = value!.trim();
    final parsed = int.tryParse(trimmed);
    if (parsed == null) {
      return '$fieldName must be a valid whole number.';
    }

    if (parsed < min) {
      return '$fieldName must be at least $min.';
    }

    if (parsed > max) {
      return '$fieldName cannot exceed $max.';
    }

    return null;
  }

  /// Date string validation (YYYY-MM-DD or MM/DD/YYYY).
  static String? validateDate(
    String? value, {
    String fieldName = 'Date',
    bool allowPast = true,
    bool allowFuture = true,
  }) {
    final requiredError = validateRequired(value, fieldName);
    if (requiredError != null) return requiredError;

    final trimmed = value!.trim();
    DateTime? parsedDate;

    // Try parsing ISO format (YYYY-MM-DD) or US format (MM/DD/YYYY)
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) {
      parsedDate = DateTime.tryParse(trimmed);
    } else if (RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$').hasMatch(trimmed)) {
      final parts = trimmed.split('/');
      final month = int.tryParse(parts[0]);
      final day = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (month != null && day != null && year != null) {
        parsedDate = DateTime.tryParse(
          '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
        );
      }
    }

    if (parsedDate == null) {
      return 'Enter a valid date (e.g. YYYY-MM-DD or MM/DD/YYYY).';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

    if (!allowPast && dateOnly.isBefore(today)) {
      return '$fieldName cannot be in the past.';
    }

    if (!allowFuture && dateOnly.isAfter(today)) {
      return '$fieldName cannot be in the future.';
    }

    return null;
  }
}
