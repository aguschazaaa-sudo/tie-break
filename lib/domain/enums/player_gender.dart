enum PlayerGender {
  male,
  female;

  String get label {
    switch (this) {
      case PlayerGender.male:
        return 'Hombre';
      case PlayerGender.female:
        return 'Mujer';
    }
  }
}
