import 'package:formz/formz.dart';

// Define input validation errors
enum TextFieldError { empty }

// Extend FormzInput and provide the input type and error type.
class TextField extends FormzInput<String, TextFieldError> {
  // Call super.pure to represent an unmodified form input.
  const TextField.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const TextField.dirty(String value) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == TextFieldError.empty) return 'El campo es requerido';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  TextFieldError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return TextFieldError.empty;

    return null;
  }
}
